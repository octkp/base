#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "note" }
# @raycast.argument2 { "type": "dropdown", "placeholder": "edit", "optional": true, "data": [{"title": "open", "value": "open"}] }
# @raycast.packageName Notes

# Documentation:
# @raycast.description クイックノートを保存

DOCS_DIR="$HOME/base/note/memos"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
FILENAME="${DOCS_DIR}/${TIMESTAMP}.md"

mkdir -p "$DOCS_DIR"

cat > "$FILENAME" << EOF
# Memo - $(date +"%Y-%m-%d %H:%M")

$1
EOF

# "開く"が選択されたらZedで開く
if [ "$2" = "open" ]; then
    zed "$FILENAME"
fi

echo "Saved: ${FILENAME}"
