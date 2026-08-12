from __future__ import annotations

from settings import Settings


def oracle_status(settings: Settings) -> dict:
    if not settings.oracle_enabled:
        return {"enabled": False, "status": "disabled", "detail": "Oracle preparado e desativado"}

    if not all((settings.oracle_user, settings.oracle_password, settings.oracle_dsn)):
        return {"enabled": True, "status": "error", "detail": "Configuração Oracle incompleta"}

    try:
        import oracledb

        connection = oracledb.connect(
            user=settings.oracle_user,
            password=settings.oracle_password,
            dsn=settings.oracle_dsn,
            wallet_location=settings.oracle_wallet_location or None,
            wallet_password=settings.oracle_wallet_password or None,
        )
        connection.ping()
        connection.close()
        return {"enabled": True, "status": "ok", "detail": "Oracle acessível"}
    except Exception as exc:  # diagnóstico de infraestrutura
        return {"enabled": True, "status": "error", "detail": str(exc)}
