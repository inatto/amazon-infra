#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
APP_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
INFRA_ROOT="$(cd -- "$APP_ROOT/../.." && pwd -P)"
KEY_FILE="${AMAZON_INFRA_GIT_CRYPT_KEY:-/home/daniel/static/git-reverse-crypt-2.key}"
DEST_ROOT="$INFRA_ROOT/.config"

unlock_with_expected_key() {
    git -C "$INFRA_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    command -v git-crypt >/dev/null 2>&1 || { echo "git-crypt não instalado." >&2; exit 1; }
    [[ -r "$KEY_FILE" ]] || { echo "Chave git-crypt ausente ou ilegível: $KEY_FILE" >&2; exit 1; }

    local exported
    exported="$(mktemp)"
    trap 'rm -f -- "$exported"' RETURN
    if git -C "$INFRA_ROOT" crypt export-key "$exported" >/dev/null 2>&1; then
        cmp -s -- "$exported" "$KEY_FILE" || {
            echo "Amazon Infra está desbloqueado com outra chave git-crypt; não alterado." >&2
            exit 1
        }
    else
        git -C "$INFRA_ROOT" crypt unlock "$KEY_FILE"
        git -C "$INFRA_ROOT" crypt export-key "$exported" >/dev/null 2>&1 || {
            echo "Não foi possível confirmar o unlock do git-crypt." >&2
            exit 1
        }
        cmp -s -- "$exported" "$KEY_FILE" || {
            echo "A chave git-crypt ativa não corresponde a $KEY_FILE." >&2
            exit 1
        }
    fi
    rm -f -- "$exported"
    trap - RETURN
}

move_file_preserving_value() {
    local source="$1" destination="$2"
    [[ -e "$source" ]] || return 0
    mkdir -p -- "$(dirname -- "$destination")"
    if [[ -e "$destination" ]]; then
        if cmp -s -- "$source" "$destination"; then
            rm -f -- "$source"
            return 0
        fi
        echo "Conflito de configuração: existem valores diferentes em:" >&2
        echo "  origem:  $source" >&2
        echo "  destino: $destination" >&2
        exit 1
    fi
    mv -- "$source" "$destination"
}

migrate_tree() {
    local component="$1"
    local source_root="$APP_ROOT/apps/$component/config"
    local context source destination relative
    [[ -d "$source_root" ]] || return 0
    for context in local production; do
        [[ -d "$source_root/$context" ]] || continue
        while IFS= read -r -d '' source; do
            relative="${source#"$source_root/$context/"}"
            destination="$DEST_ROOT/$component/$context/$relative"
            move_file_preserving_value "$source" "$destination"
        done < <(find "$source_root/$context" -type f -print0)
        find "$source_root/$context" -depth -type d -empty -delete 2>/dev/null || true
    done
    find "$source_root" -depth -type d -empty -delete 2>/dev/null || true
}

unlock_with_expected_key
mkdir -p -- "$DEST_ROOT/api/local" "$DEST_ROOT/api/production" "$DEST_ROOT/web/local" "$DEST_ROOT/web/production"
migrate_tree api
migrate_tree web

ATTRIBUTES_FILE="$INFRA_ROOT/.gitattributes"
if [[ -f "$ATTRIBUTES_FILE" ]]; then
    attrs_tmp="$(mktemp)"
    grep -v -F \
        -e 'apps/monitor-app/apps/api/config/** filter=git-crypt diff=git-crypt' \
        -e 'apps/monitor-app/apps/web/config/** filter=git-crypt diff=git-crypt' \
        -e '# Transitional protection: removed automatically after deploy/migrate-config.sh moves the real files.' \
        "$ATTRIBUTES_FILE" > "$attrs_tmp"
    mv -- "$attrs_tmp" "$ATTRIBUTES_FILE"
fi

echo "Configuração centralizada em $DEST_ROOT"
