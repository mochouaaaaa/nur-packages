#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl common-updater-scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_FILE="$SCRIPT_DIR/default.nix"

ATTR_NAME="${1:-rime.lmdg}"

update-source-version $ATTR_NAME LTS \
    --file=$TARGET_FILE \
    --ignore-same-hash \
    --ignore-same-version
