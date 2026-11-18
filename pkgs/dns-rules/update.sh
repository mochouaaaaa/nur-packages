#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_FILE="$SCRIPT_DIR/default.nix"

CURRENT_VERSION=$(grep 'version =' "$TARGET_FILE" | cut -d'"' -f2)

LATEST_TAG=$(curl -s -H "$AUTH_HEADER" https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name)
echo "Latest Tag: $LATEST_TAG"

ATTR_NAME="${1:-dns-rules}"

update-source-version $ATTR_NAME $LATEST_TAG \
    --file=$TARGET_FILE \
    --ignore-same-version

update-source-version $ATTR_NAME $LATEST_TAG \
    --file=$TARGET_FILE \
    --source-key=geoip \
    --ignore-same-version

echo "Update $CURRENT_VERSION -> $LATEST_TAG"
echo "Update successful!"
