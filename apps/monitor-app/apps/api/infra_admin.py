from __future__ import annotations

import re
import shutil
import socket
import subprocess
from pathlib import Path
from urllib.parse import urlparse

from settings import Settings

DOMAIN_RE = re.compile(r"^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$")
NGINX_AVAILABLE = Path("/etc/nginx/sites-available")
NGINX_ENABLED = Path("/etc/nginx/sites-enabled")
LETSENCRYPT_LIVE = Path("/etc/letsencrypt/live")
COMMON_SECOND_LEVEL_SUFFIXES = {
    "com.br", "org.br", "net.br", "gov.br", "edu.br", "mil.br",
    "co.uk", "org.uk", "ac.uk", "com.au", "net.au", "org.au",
}


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


def _root_domain(domain: str) -> str:
    labels = domain.lower().rstrip(".").split(".")
    if len(labels) <= 2:
        return domain.lower().rstrip(".")
    suffix2 = ".".join(labels[-2:])
    if suffix2 in COMMON_SECOND_LEVEL_SUFFIXES and len(labels) >= 3:
        return ".".join(labels[-3:])
    return ".".join(labels[-2:])


def _parse_shell_scalar(text: str, name: str) -> str | None:
    match = re.search(rf'^\s*{re.escape(name)}\s*=\s*["\']?([^"\'\n#]+)["\']?\s*$', text, re.MULTILINE)
    return match.group(1).strip() if match else None


def _parse_domains(text: str) -> list[str]:
    block = re.search(r"DOMAINS\s*=\s*\((.*?)\)", text, re.DOTALL)
    if not block:
        site = _parse_shell_scalar(text, "SITE_NAME")
        return [site] if site else []
    values = re.findall(r'["\']([^"\']+)["\']', block.group(1))
    return [value.strip().lower() for value in values if DOMAIN_RE.fullmatch(value.strip().lower())]


def _parse_proxy_locations(text: str, name: str) -> list[dict]:
    block = re.search(rf"{re.escape(name)}\s*=\s*\((.*?)\)", text, re.DOTALL)
    if not block:
        return []
    items: list[dict] = []
    for raw in re.findall(r'["\']([^"\']+)["\']', block.group(1)):
        parts = raw.split("|")
        if len(parts) >= 3:
            items.append({"location": parts[0], "target": f"http://{parts[1]}:{parts[2]}"})
    return items


def _dns_status(domain: str, expected_ip: str) -> dict:
    try:
        ips = sorted({item[4][0] for item in socket.getaddrinfo(domain, 443, type=socket.SOCK_STREAM) if ":" not in item[4][0]})
    except socket.gaierror:
        ips = []
    if not ips:
        return {"status": "missing", "ips": [], "expected_ip": expected_ip, "message": f"DNS ainda não resolve. Cadastre um A para {expected_ip}."}
    if expected_ip and expected_ip not in ips:
        return {"status": "wrong", "ips": ips, "expected_ip": expected_ip, "message": f"DNS aponta para {', '.join(ips)}, mas esta EC2 é {expected_ip}."}
    return {"status": "ok", "ips": ips, "expected_ip": expected_ip, "message": f"DNS apontando para {expected_ip}."}


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
        sites.append({
            "site": path.name,
            "domains": domains,
            "enabled": (NGINX_ENABLED / path.name).exists(),
            "ssl": cert_path.exists(),
            "redirect_url": _redirect_target(text),
            "routes": _upstreams(text),
        })
    return sites


def configured_domains(settings: Settings) -> list[dict]:
    source_dir = Path(settings.infra_domains_dir)
    nginx_by_domain: dict[str, dict] = {}
    for site in nginx_sites():
        for domain in site["domains"]:
            nginx_by_domain[domain] = site
        nginx_by_domain.setdefault(site["site"], site)

    items: list[dict] = []
    if not source_dir.exists():
        return items
    for path in sorted(source_dir.glob("*.conf"), key=lambda item: item.name):
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        domains = _parse_domains(text)
        primary = domains[0] if domains else path.stem
        if not DOMAIN_RE.fullmatch(primary):
            continue
        redirect_url = _parse_shell_scalar(text, "REDIRECT_URL")
        app_name = _parse_shell_scalar(text, "APP_NAME")
        routes = _parse_proxy_locations(text, "WEB_PROXY_LOCATIONS") + _parse_proxy_locations(text, "API_PROXY_LOCATIONS")
        web_port = _parse_shell_scalar(text, "WEB_UPSTREAM_PORT")
        api_port = _parse_shell_scalar(text, "API_UPSTREAM_PORT")
        if not routes:
            if web_port:
                routes.append({"location": "/", "target": f"http://127.0.0.1:{web_port}"})
            if api_port:
                routes.append({"location": "/api/", "target": f"http://127.0.0.1:{api_port}"})
        nginx = nginx_by_domain.get(primary)
        items.append({
            "domain": primary,
            "root_domain": _root_domain(primary),
            "source_file": path.name,
            "source_present": True,
            "app_name": app_name,
            "redirect_url": redirect_url,
            "routes": routes,
            "enabled": bool(nginx and nginx["enabled"]),
            "applied": nginx is not None,
            "ssl": bool(nginx and nginx["ssl"]),
            "dns": _dns_status(primary, settings.infra_public_ip),
        })
    return items


def grouped_domains(settings: Settings) -> list[dict]:
    grouped: dict[str, list[dict]] = {}
    for item in configured_domains(settings):
        grouped.setdefault(item["root_domain"], []).append(item)
    return [
        {"root_domain": root, "count": len(items), "domains": sorted(items, key=lambda item: item["domain"])}
        for root, items in sorted(grouped.items())
    ]


def systemd_services() -> list[dict]:
    if not shutil.which("systemctl"):
        return []
    code, output = _run("systemctl", "list-units", "--type=service", "--all", "--no-legend", "--no-pager", "--plain", timeout=8)
    if code != 0:
        return []
    services = []
    for line in output.splitlines():
        parts = line.split(None, 4)
        if len(parts) < 4:
            continue
        name, load, active, sub = parts[:4]
        if not any(token in name for token in ("orbital", "inst-app", "station-app", "asaclub-app", "monitor-app", "amazon-infra", "nginx")):
            continue
        services.append({"name": name, "load": load, "active": active, "sub": sub})
    return services


def infra_summary(settings: Settings) -> dict:
    sites = nginx_sites()
    services = systemd_services()
    domain_groups = grouped_domains(settings)
    configured_count = sum(group["count"] for group in domain_groups)
    return {
        "nginx": {"sites": sites, "site_count": len(sites), "enabled_count": sum(1 for site in sites if site["enabled"]), "ssl_count": sum(1 for site in sites if site["ssl"])},
        "domain_source": {"path": settings.infra_domains_dir, "groups": domain_groups, "configured_count": configured_count},
        "services": services,
        "service_count": len(services),
    }


def validate_domain(domain: str) -> str:
    clean_domain = domain.strip().lower().rstrip(".")
    if not DOMAIN_RE.fullmatch(clean_domain):
        raise ValueError("Domínio inválido.")
    return clean_domain


def validate_redirect(domain: str, target_url: str) -> tuple[str, str]:
    clean_domain = validate_domain(domain)
    clean_target = target_url.strip()
    parsed = urlparse(clean_target)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc or parsed.username or parsed.password:
        raise ValueError("Destino deve ser uma URL http/https válida.")
    if any(char in clean_target for char in "\r\n;{}"):
        raise ValueError("Destino contém caracteres inválidos.")
    return clean_domain, clean_target


def _call_helper(settings: Settings, *args: str, timeout: int = 120) -> str:
    helper = settings.infra_admin_helper
    if not Path(helper).exists():
        raise RuntimeError(f"Helper administrativo não instalado: {helper}")
    code, output = _run("sudo", helper, *args, timeout=timeout)
    if code != 0:
        raise RuntimeError(output or "Falha ao aplicar alteração de infraestrutura.")
    return output


def apply_redirect(settings: Settings, domain: str, target_url: str, enable_ssl: bool) -> dict:
    domain, target_url = validate_redirect(domain, target_url)
    command = ["apply-redirect", domain, target_url, settings.infra_ssl_email]
    if enable_ssl:
        command.append("--ssl")
    output = _call_helper(settings, *command)
    return {"status": "ok", "domain": domain, "target_url": target_url, "ssl": enable_ssl, "detail": output}


def set_domain_enabled(settings: Settings, domain: str, enabled: bool) -> dict:
    domain = validate_domain(domain)
    output = _call_helper(settings, "set-enabled", domain, "on" if enabled else "off", settings.infra_ssl_email)
    return {"status": "ok", "domain": domain, "enabled": enabled, "detail": output}
