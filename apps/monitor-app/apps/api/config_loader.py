from __future__ import annotations

import os
from pathlib import Path

from dotenv import dotenv_values

API_DIR = Path(__file__).resolve().parent
INFRA_DIR = API_DIR.parents[3]
CONFIG_CONTEXT = "local" if "/home/daniel/" in INFRA_DIR.as_posix() else "production"
CONFIG_FILES = ("app.env", "services.env")


def load_config_environment() -> dict[str, str]:
    directory = INFRA_DIR / ".config" / "api" / CONFIG_CONTEXT
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

    external_files = (
        API_DIR / "config" / CONFIG_CONTEXT / "services.env.external",
        directory / "services.env.external",
    )
    for external in external_files:
        if not external.is_file():
            continue
        for key, raw_value in dotenv_values(external).items():
            if raw_value is not None:
                values[key] = str(raw_value)

    for key, value in values.items():
        os.environ[key] = value
    return values
