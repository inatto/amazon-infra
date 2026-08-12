from __future__ import annotations

import asyncio
import json
import os
import platform
import shutil
import socket
import subprocess
import time
from pathlib import Path

import httpx

from config_loader import CONFIG_CONTEXT
from settings import Settings

INVENTORY_FILE = Path(__file__).with_name("inventory.json")


def _run(*command: str) -> tuple[int, str]:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=4, check=False)
        return result.returncode, (result.stdout or result.stderr).strip()
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
        "disk": {"total": disk.total, "free": disk.free, "used_percent": round(disk.used / disk.total * 100, 1)},
        "memory": memory,
    }


def _listeners() -> dict[int, str]:
    code, output = _run("ss", "-ltnpH")
    if code != 0:
        return {}
    listeners: dict[int, str] = {}
    for line in output.splitlines():
        parts = line.split()
        if len(parts) < 4:
            continue
        address = parts[3]
        try:
            port = int(address.rsplit(":", 1)[1])
        except (ValueError, IndexError):
            continue
        process = " ".join(parts[5:]) if len(parts) > 5 else "processo não identificado"
        listeners[port] = process
    return listeners


def check_service(service: str) -> dict:
    if not shutil.which("systemctl"):
        return {"name": service, "kind": "service", "status": "unknown", "detail": "systemctl indisponível"}
    code, output = _run("systemctl", "is-active", service)
    state = output.splitlines()[0] if output else "unknown"
    return {"name": service, "kind": "service", "status": "ok" if code == 0 and state == "active" else "error", "detail": state}


def check_port(port: int, role: str, listeners: dict[int, str]) -> dict:
    started = time.perf_counter()
    try:
        with socket.create_connection(("127.0.0.1", port), timeout=1):
            latency = int((time.perf_counter() - started) * 1000)
            process = listeners.get(port, "processo não identificado")
            return {"name": f"{role} · Porta {port}", "kind": "port", "status": "ok", "detail": process, "latency_ms": latency}
    except OSError as exc:
        return {"name": f"{role} · Porta {port}", "kind": "port", "status": "error", "detail": str(exc), "latency_ms": None}


async def check_url(client: httpx.AsyncClient, item: dict) -> dict:
    url = item["url"]
    started = time.perf_counter()
    try:
        response = await client.get(url)
        latency = int((time.perf_counter() - started) * 1000)
        status = "ok" if 200 <= response.status_code < 400 else "error"
        return {"name": item.get("role", "HTTP"), "kind": "http", "status": status, "detail": f"HTTP {response.status_code}", "url": url, "latency_ms": latency}
    except httpx.HTTPError as exc:
        return {"name": item.get("role", "HTTP"), "kind": "http", "status": "error", "detail": str(exc), "url": url, "latency_ms": None}


async def collect_groups(settings: Settings) -> list[dict]:
    inventory = json.loads(INVENTORY_FILE.read_text(encoding="utf-8"))
    listeners = await asyncio.to_thread(_listeners)
    groups = []
    async with httpx.AsyncClient(timeout=settings.monitor_timeout_seconds, follow_redirects=True) as client:
        for group in inventory["groups"]:
            service_items = group["services"] if CONFIG_CONTEXT == "production" or group["type"] == "infra" else []
            services = await asyncio.to_thread(lambda items=service_items: [check_service(item) for item in items])
            ports = await asyncio.to_thread(lambda items=group["ports"]: [check_port(item["port"], item["role"], listeners) for item in items])
            urls = await asyncio.gather(*(check_url(client, item) for item in group["urls"]))
            checks = [*services, *ports, *urls]
            status = "error" if any(item["status"] == "error" for item in checks) else "ok"
            groups.append({**group, "status": status, "checks": checks})
    return groups
