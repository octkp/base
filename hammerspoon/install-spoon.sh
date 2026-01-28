#!/bin/bash
# Hammerspoon Spoon インストーラー
# Usage: ./install-spoon.sh SpoonName

set -e

SPOON_NAME="$1"
SPOONS_DIR="$(dirname "$0")/Spoons"

if [ -z "$SPOON_NAME" ]; then
    echo "Usage: $0 <SpoonName>"
    echo "Example: $0 InputMethodIndicator"
    exit 1
fi

mkdir -p "$SPOONS_DIR"

URL="https://github.com/Hammerspoon/Spoons/raw/master/Spoons/${SPOON_NAME}.spoon.zip"
TMP_FILE="/tmp/${SPOON_NAME}.spoon.zip"

echo "Downloading ${SPOON_NAME}..."
curl -L "$URL" -o "$TMP_FILE"

echo "Installing to ${SPOONS_DIR}..."
unzip -o "$TMP_FILE" -d "$SPOONS_DIR"

rm "$TMP_FILE"
echo "Done! ${SPOON_NAME} installed."
