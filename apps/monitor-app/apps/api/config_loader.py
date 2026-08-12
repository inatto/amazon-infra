from __future__ import annotations

import os
from pathlib import Path

from dotenv import dotenv_values

API_DIR = Path(__file__).resolve().parent
CONFIG_CONTEXT = "local" if "/home/daniel/" in API_DIR.as_posix() else "production"
CONFIG_FILES = ("app.env", "services.env")


def load_config_environment() -> dict[str, str]:
    directory = API_DIR / "config" / CONFIG_CONTEXT
    values: dict[str, str] = {}
    origins: dict[str, Path] = {}
    for name in CONFIG_FILES:
        path = directory / name
        if not path.is_file():
            raise RuntimeError(f"Arquivo de configuração ausente: {path}")
        for key, raw_value in dotenv_values(path).items():
            if raw_value is None:
                continue
            if key in values:
                raise RuntimeError(f"Variável duplicada {key} em {origins[key]} e {path}.")
            values[key] = str(raw_value)
            origins[key] = path

    external = directory / "services.env.external"
    if external.is_file():
        for key, raw_value in dotenv_values(external).items():
            if raw_value is not None:
                values[key] = str(raw_value)

    for key, value in values.items():
        os.environ[key] = value
    return values
