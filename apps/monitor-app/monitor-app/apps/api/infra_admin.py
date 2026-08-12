from __future__ import annotations

import re
import shutil
import subprocess
from pathlib import Path
from urllib.parse import urlparse

from settings import Settings

DOMAIN_RE = re.compile(r"^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$")
NGINX_AVAILABLE = Path("/etc/nginx/sites-available")
NGINX_ENABLED = Path("/etc/nginx/sites-enabled")
LETSENCRYPT_LIVE = Path("/etc/letsencrypt/live")


def _run(*command: str, timeout: int = 20) -> tuple[int, str]:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout, check=False)
        return result.returncode, ((result.stdout or "") + (result.stderr or "")).strip()
    except (OSError, subprocess.TimeoutExpired) as exc:
        return 1, str(exc)


def _server_names(text: str) -> list[str]:
    values: list[str] = []
    for match in re.finditer(r"^\s*server_name\s+([^;]+);", text, re.MULTILINE):
        for value in match.group(1).split():
            if value not in {"_", "localhost"} and value not in values:
                values.append(value)
    return values


def _redirect_target(text: str) -> str | None:
    match = re.search(r"^\s*return\s+(?:301|302|307|308)\s+(https?://[^;\s]+)\s*;", text, re.MULTILINE)
    return match.group(1) if match else None


def _upstreams(text: str) -> list[dict]:
    items: list[dict] = []
    location = "/"
    for line in text.splitlines():
        location_match = re.match(r"\s*location(?:\s+\^~)?\s+([^\s{]+)", line)
        if location_match:
            location = location_match.group(1)
            continue
        proxy_match = re.search(r"proxy_pass\s+(https?://[^;]+);", line)
        if proxy_match:
            item = {"location": location, "target": proxy_match.group(1)}
            if item not in items:
                items.append(item)
    return items


def nginx_sites() -> list[dict]:
    if not NGINX_AVAILABLE.exists():
        return []
    sites = []
    for path in sorted(NGINX_AVAILABLE.iterdir(), key=lambda item: item.name):
        if not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        domains = _server_names(text)
        primary = domains[0] if domains else path.name
        cert_path = LETSENCRYPT_LIVE / primary / "fullchain.pem"
        sites.append(
            {
                "site": path.name,
                "domains": domains,
                "enabled": (NGINX_ENABLED / path.name).exists(),
                "ssl": cert_path.exists(),
                "redirect_url": _redirect_target(text),
                "routes": _upstreams(text),
            }
        )
    return sites


def systemd_services() -> list[dict]:
    if not shutil.which("systemctl"):
        return []
    code, output = _run(
        "systemctl",
        "list-units",
        "--type=service",
        "--all",
        "--no-legend",
        "--no-pager",
        "--plain",
        timeout=8,
    )
    if code != 0:
        return []
    services = []
    for line in output.splitlines():
        parts = line.split(None, 4)
        if len(parts) < 4:
            continue
        name, load, active, sub = parts[:4]
        if not any(token in name for token in ("orbital", "inst-app", "station-app", "amazon-infra", "nginx")):
            continue
        services.append({"name": name, "load": load, "active": active, "sub": sub})
    return services


def infra_summary() -> dict:
    sites = nginx_sites()
    services = systemd_services()
    return {
        "nginx": {
            "sites": sites,
            "site_count": len(sites),
            "enabled_count": sum(1 for site in sites if site["enabled"]),
            "ssl_count": sum(1 for site in sites if site["ssl"]),
        },
        "services": services,
        "service_count": len(services),
    }


def validate_redirect(domain: str, target_url: str) -> tuple[str, str]:
    clean_domain = domain.strip().lower().rstrip(".")
    if not DOMAIN_RE.fullmatch(clean_domain):
        raise ValueError("Domínio inválido.")
    clean_target = target_url.strip()
    parsed = urlparse(clean_target)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc or parsed.username or parsed.password:
        raise ValueError("Destino deve ser uma URL http/https válida.")
    if any(char in clean_target for char in "\r\n;{}"):
        raise ValueError("Destino contém caracteres inválidos.")
    return clean_domain, clean_target


def apply_redirect(settings: Settings, domain: str, target_url: str, enable_ssl: bool) -> dict:
    domain, target_url = validate_redirect(domain, target_url)
    helper = settings.infra_admin_helper
    if not Path(helper).exists():
        raise RuntimeError(f"Helper administrativo não instalado: {helper}")
    command = ["sudo", helper, "apply-redirect", domain, target_url, settings.infra_ssl_email]
    if enable_ssl:
        command.append("--ssl")
    code, output = _run(*command, timeout=120)
    if code != 0:
        raise RuntimeError(output or "Falha ao aplicar Nginx.")
    return {"status": "ok", "domain": domain, "target_url": target_url, "ssl": enable_ssl, "detail": output}
