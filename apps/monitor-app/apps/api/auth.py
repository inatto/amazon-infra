from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
import time
from functools import lru_cache
from urllib.parse import urlencode

import httpx
from fastapi import HTTPException, Request, Response, status
from fastapi.responses import RedirectResponse

from settings import Settings, get_settings

SESSION_COOKIE = "monitor_session_v2"
STATE_COOKIE = "monitor_sso_state"


def _b64encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _b64decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


@lru_cache(maxsize=1)
def _ephemeral_session_secret() -> str:
    return secrets.token_urlsafe(48)


def _session_secret(settings: Settings) -> bytes:
    configured = settings.sso_session_secret.strip()
    return (configured or _ephemeral_session_secret()).encode("utf-8")


def _encode_session(identity: dict, settings: Settings) -> str:
    now = int(time.time())
    payload = {
        "identity": identity,
        "iat": now,
        "exp": now + settings.sso_session_ttl_seconds,
    }
    raw = json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
    signature = hmac.new(_session_secret(settings), raw, hashlib.sha256).digest()
    return f"{_b64encode(raw)}.{_b64encode(signature)}"


def _decode_session(token: str, settings: Settings) -> dict | None:
    try:
        payload_text, signature_text = token.split(".", 1)
        raw = _b64decode(payload_text)
        signature = _b64decode(signature_text)
        expected = hmac.new(_session_secret(settings), raw, hashlib.sha256).digest()
        if not hmac.compare_digest(signature, expected):
            return None
        payload = json.loads(raw)
        if int(payload.get("exp", 0)) <= int(time.time()):
            return None
        identity = payload.get("identity")
        return identity if isinstance(identity, dict) else None
    except (ValueError, TypeError, json.JSONDecodeError):
        return None


def _cookie_secure(settings: Settings) -> bool:
    return settings.sso_redirect_uri.lower().startswith("https://")


def current_identity(request: Request, settings: Settings | None = None) -> dict | None:
    selected = settings or get_settings()
    if not selected.sso_enabled:
        return {
            "person_id": 0,
            "member_id": 0,
            "name": "Local developer",
            "login": "local",
            "tenant_code": "local",
            "etype_code": "dev",
            "profile_name": "Dev",
            "company_name": "Local",
            "is_admin": True,
            "is_dev": True,
        }
    token = request.cookies.get(SESSION_COOKIE, "")
    return _decode_session(token, selected) if token else None


def require_sso_user(request: Request) -> dict:
    settings = get_settings()
    identity = current_identity(request, settings)
    if not identity:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Autenticação SSO necessária.")
    if settings.sso_require_dev and not bool(identity.get("is_dev")):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Acesso restrito ao ambiente de desenvolvimento.")
    return identity


def begin_login(settings: Settings) -> RedirectResponse:
    if not settings.sso_enabled:
        return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)
    if not settings.sso_authorize_url or not settings.sso_client_id or not settings.sso_redirect_uri:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="SSO não configurado.")

    state_value = secrets.token_urlsafe(32)
    query = urlencode({
        "client_id": settings.sso_client_id,
        "redirect_uri": settings.sso_redirect_uri,
        "response_type": "code",
        "state": state_value,
    })
    response = RedirectResponse(url=f"{settings.sso_authorize_url}?{query}", status_code=status.HTTP_302_FOUND)
    response.set_cookie(
        STATE_COOKIE,
        state_value,
        max_age=300,
        httponly=True,
        secure=_cookie_secure(settings),
        samesite="lax",
        path="/",
    )
    return response


async def finish_login(request: Request, code: str, state_value: str, settings: Settings) -> RedirectResponse:
    expected_state = request.cookies.get(STATE_COOKIE, "")
    if not expected_state or not state_value or not hmac.compare_digest(expected_state, state_value):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Estado SSO inválido ou expirado.")
    if not code:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Código SSO ausente.")
    if not settings.sso_token_url:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="SSO não configurado.")

    try:
        async with httpx.AsyncClient(timeout=5.0, follow_redirects=False) as client:
            token_response = await client.post(
                settings.sso_token_url,
                json={
                    "grant_type": "authorization_code",
                    "code": code,
                    "client_id": settings.sso_client_id,
                    "client_secret": settings.sso_client_secret,
                    "redirect_uri": settings.sso_redirect_uri,
                },
            )
        if token_response.status_code != 200:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Não foi possível concluir a autenticação SSO.")
        identity = token_response.json()
    except HTTPException:
        raise
    except (httpx.HTTPError, ValueError) as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Orbital SSO indisponível.") from exc

    required = {"person_id", "member_id", "name", "tenant_code", "etype_code", "is_dev"}
    if not isinstance(identity, dict) or not required.issubset(identity):
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Resposta SSO inválida.")
    if settings.sso_require_dev and not bool(identity.get("is_dev")):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Acesso restrito ao ambiente de desenvolvimento.")

    response = RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)
    response.set_cookie(
        SESSION_COOKIE,
        _encode_session(identity, settings),
        max_age=settings.sso_session_ttl_seconds,
        httponly=True,
        secure=_cookie_secure(settings),
        samesite="lax",
        path="/",
    )
    response.delete_cookie(STATE_COOKIE, path="/", secure=_cookie_secure(settings), samesite="lax")
    return response


def end_session(settings: Settings) -> Response:
    response = Response(status_code=status.HTTP_204_NO_CONTENT)
    response.delete_cookie(SESSION_COOKIE, path="/", secure=_cookie_secure(settings), samesite="lax")
    response.delete_cookie(STATE_COOKIE, path="/", secure=_cookie_secure(settings), samesite="lax")
    return response
