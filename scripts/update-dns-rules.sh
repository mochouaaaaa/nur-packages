#!/usr/bin/env bash

AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
fi

TARGET_FILE="pkgs/dns-rules.nix"

CURRENT_VERSION=$(grep 'version =' "$TARGET_FILE" | cut -d'"' -f2)

LATEST_TAG=$(curl -s -H "$AUTH_HEADER" https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name)
echo "Latest Tag: $LATEST_TAG"

if [ "$LATEST_TAG" == "$CURRENT_VERSION" ]; then
    echo "Versions match. No update needed. Exiting..."
    exit 0
fi

GEOIP_SRI=$(nix hash to-sri --type sha256 $(nix-prefetch-url "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$LATEST_TAG/geoip.dat"))
GEOSITE_SRI=$(nix hash to-sri --type sha256 $(nix-prefetch-url "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$LATEST_TAG/geosite.dat"))

sed -i "s/version = \".*\";/version = \"$LATEST_TAG\";/" "$TARGET_FILE"

sed -i "s|hash = \".*\"; # GEOIP_HASH|hash = \"$GEOIP_SRI\"; # GEOIP_HASH|" "$TARGET_FILE"
sed -i "s|hash = \".*\"; # GEOSITE_HASH|hash = \"$GEOSITE_SRI\"; # GEOSITE_HASH|" "$TARGET_FILE"

echo "Update successful!"
