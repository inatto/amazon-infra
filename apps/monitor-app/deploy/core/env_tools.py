#!/usr/bin/env python3
import argparse
from pathlib import Path


def read_env(path: Path) -> list[tuple[str, str]]:
    values: list[tuple[str, str]] = []
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        values.append((key.strip(), value.strip()))
    return values


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('target', type=Path)
    parser.add_argument('--set', action='append', default=[])
    args = parser.parse_args()

    overrides = dict(item.split('=', 1) for item in args.set)
    values = read_env(args.source)
    known = {key for key, _ in values}
    output = [f"{key}={overrides.get(key, value)}" for key, value in values]
    output.extend(f"{key}={value}" for key, value in overrides.items() if key not in known)
    args.target.write_text('\n'.join(output) + '\n')


if __name__ == '__main__':
    main()
