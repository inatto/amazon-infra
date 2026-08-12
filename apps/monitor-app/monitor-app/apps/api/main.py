from datetime import datetime, timezone

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

from monitor import collect_groups, system_summary
from infra_admin import apply_redirect, infra_summary
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


@app.get("/api/monitor")
async def monitor() -> dict:
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


def _require_admin_token(token: str | None) -> None:
    configured = settings.infra_admin_token.strip()
    if not configured:
        raise HTTPException(status_code=503, detail="INFRA_ADMIN_TOKEN não configurado.")
    if token != configured:
        raise HTTPException(status_code=401, detail="Token administrativo inválido.")


@app.get("/api/infra")
def infra() -> dict:
    return infra_summary()


@app.post("/api/infra/redirects")
def create_redirect(payload: RedirectRequest, x_infra_admin_token: str | None = Header(default=None)) -> dict:
    _require_admin_token(x_infra_admin_token)
    try:
        return apply_redirect(settings, payload.domain, payload.target_url, payload.enable_ssl)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
