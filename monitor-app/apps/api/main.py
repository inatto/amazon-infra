from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from monitor import collect_checks, system_summary
from oracle import oracle_status
from settings import get_settings

settings = get_settings()
app = FastAPI(title=settings.app_name, version=settings.app_version)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health() -> dict:
    return {"status": "ok", "name": settings.app_name, "version": settings.app_version}


@app.get("/api/monitor")
async def monitor() -> dict:
    checks = await collect_checks(settings)
    oracle = oracle_status(settings)
    has_error = any(item["status"] == "error" for item in checks) or oracle["status"] == "error"
    return {
        "status": "error" if has_error else "ok",
        "version": settings.app_version,
        "checked_at": datetime.now(timezone.utc).isoformat(),
        "system": system_summary(),
        "oracle": oracle,
        "checks": checks,
    }
