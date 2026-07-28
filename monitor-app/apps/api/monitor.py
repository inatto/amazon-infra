from __future__ import annotations

import asyncio
import os
import platform
import shutil
import socket
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path

import httpx

from settings import Settings


@dataclass(slots=True)
class Check:
    name: str
    kind: str
    status: str
    detail: str
    latency_ms: int | None = None


def _run(*command: str) -> tuple[int, str]:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=3, check=False)
        output = (result.stdout or result.stderr).strip()
        return result.returncode, output
    except (OSError, subprocess.TimeoutExpired) as exc:
        return 1, str(exc)


def system_summary() -> dict:
    disk = shutil.disk_usage("/")
    load = os.getloadavg() if hasattr(os, "getloadavg") else (0.0, 0.0, 0.0)
    uptime_seconds = 0
    uptime_file = Path("/proc/uptime")
    if uptime_file.exists():
        uptime_seconds = int(float(uptime_file.read_text().split()[0]))

    memory = {"total": 0, "available": 0, "used_percent": 0.0}
    meminfo = Path("/proc/meminfo")
    if meminfo.exists():
        values = {}
        for line in meminfo.read_text().splitlines():
            key, value = line.split(":", 1)
            values[key] = int(value.strip().split()[0]) * 1024
        total = values.get("MemTotal", 0)
        available = values.get("MemAvailable", 0)
        memory = {
            "total": total,
            "available": available,
            "used_percent": round((1 - available / total) * 100, 1) if total else 0.0,
        }

    return {
        "hostname": socket.gethostname(),
        "platform": platform.platform(),
        "uptime_seconds": uptime_seconds,
        "load": [round(value, 2) for value in load],
        "disk": {
            "total": disk.total,
            "free": disk.free,
            "used_percent": round(disk.used / disk.total * 100, 1),
        },
        "memory": memory,
    }


def check_service(service: str) -> Check:
    if not shutil.which("systemctl"):
        return Check(service, "service", "unknown", "systemctl indisponível neste ambiente")
    code, output = _run("systemctl", "is-active", service)
    state = output.splitlines()[0] if output else "unknown"
    return Check(service, "service", "ok" if code == 0 and state == "active" else "error", state)


def check_port(port: int) -> Check:
    started = time.perf_counter()
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=1):
            latency = int((time.perf_counter() - started) * 1000)
            return Check(str(port), "port", "ok", "escutando em 127.0.0.1", latency)
    except OSError as exc:
        return Check(str(port), "port", "error", str(exc))


async def check_url(client: httpx.AsyncClient, url: str) -> Check:
    started = time.perf_counter()
    try:
        response = await client.get(url)
        latency = int((time.perf_counter() - started) * 1000)
        status = "ok" if response.status_code < 500 else "error"
        return Check(url, "http", status, f"HTTP {response.status_code}", latency)
    except httpx.HTTPError as exc:
        return Check(url, "http", "error", str(exc))


async def collect_checks(settings: Settings) -> list[dict]:
    service_checks = await asyncio.to_thread(lambda: [check_service(item) for item in settings.service_list])
    port_checks = await asyncio.to_thread(lambda: [check_port(item) for item in settings.port_list])
    async with httpx.AsyncClient(timeout=settings.monitor_timeout_seconds, follow_redirects=True) as client:
        url_checks = await asyncio.gather(*(check_url(client, url) for url in settings.url_list))
    return [asdict(check) for check in [*service_checks, *port_checks, *url_checks]]
