from datetime import datetime, timezone

from fastapi import Depends, FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

from auth import begin_login, current_identity, end_session, finish_login, require_sso_user
from monitor import collect_groups, system_summary
from infra_admin import apply_redirect, infra_summary, set_domain_enabled
from oracle import oracle_status
from settings import get_settings

settings = get_settings()
app = FastAPI(title=settings.app_name, version=settings.app_version)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health() -> dict:
    return {"status": "ok", "name": settings.app_name, "version": settings.app_version}


@app.get("/api/auth/login")
def auth_login():
    return begin_login(settings)


@app.get("/api/auth/callback")
async def auth_callback(request: Request, code: str = "", state: str = ""):
    return await finish_login(request, code, state, settings)


@app.get("/api/auth/session")
def auth_session(request: Request) -> dict:
    identity = current_identity(request, settings)
    if not identity:
        raise HTTPException(status_code=401, detail="Sessão ausente.")
    if settings.sso_require_dev and not bool(identity.get("is_dev")):
        raise HTTPException(status_code=403, detail="Acesso restrito ao ambiente de desenvolvimento.")
    return {"authenticated": True, "identity": identity}


@app.post("/api/auth/logout")
def auth_logout():
    return end_session(settings)


@app.get("/api/monitor")
async def monitor(_identity: dict = Depends(require_sso_user)) -> dict:
    groups = await collect_groups(settings)
    oracle = oracle_status(settings)
    has_error = any(group["status"] == "error" for group in groups) or oracle["status"] == "error"
    return {
        "status": "error" if has_error else "ok",
        "version": settings.app_version,
        "checked_at": datetime.now(timezone.utc).isoformat(),
        "system": system_summary(),
        "oracle": oracle,
        "groups": groups,
    }


class RedirectRequest(BaseModel):
    domain: str
    target_url: str
    enable_ssl: bool = True


class DomainEnabledRequest(BaseModel):
    enabled: bool


def _require_admin_token(token: str | None) -> None:
    configured = settings.infra_admin_token.strip()
    if not configured:
        raise HTTPException(status_code=503, detail="INFRA_ADMIN_TOKEN não configurado.")
    if token != configured:
        raise HTTPException(status_code=401, detail="Token administrativo inválido.")


@app.get("/api/infra")
def infra(_identity: dict = Depends(require_sso_user)) -> dict:
    return infra_summary(settings)


@app.post("/api/infra/redirects")
def create_redirect(
    payload: RedirectRequest,
    x_infra_admin_token: str | None = Header(default=None),
    _identity: dict = Depends(require_sso_user),
) -> dict:
    _require_admin_token(x_infra_admin_token)
    try:
        return apply_redirect(settings, payload.domain, payload.target_url, payload.enable_ssl)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.post("/api/infra/domains/{domain}/enabled")
def update_domain_enabled(
    domain: str,
    payload: DomainEnabledRequest,
    x_infra_admin_token: str | None = Header(default=None),
    _identity: dict = Depends(require_sso_user),
) -> dict:
    _require_admin_token(x_infra_admin_token)
    try:
        return set_domain_enabled(settings, domain, payload.enabled)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
