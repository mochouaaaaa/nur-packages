#!/usr/bin/env bash

AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
fi

TARGET_FILE="pkgs/dns-rules.nix"

CURRENT_VERSION=$(grep 'version =' "$TARGET_FILE" | cut -d'"' -f2)

GEOIP_SRI=$(nix hash to-sri --type sha256 $(nix-prefetch-url "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$CURRENT_VERSION/geoip.dat"))

sed -i "s|hash = \".*\"; # GEOIP_HASH|hash = \"$GEOIP_SRI\"; # GEOIP_HASH|" "$TARGET_FILE"

echo "Update successful!"
