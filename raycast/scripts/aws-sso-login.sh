#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AWS SSO Login
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ☁️
# @raycast.argument1 { "type": "dropdown", "placeholder": "profile", "data": [{"title": "ba_developers", "value": "ba_developers"}, {"title": "koko", "value": "koko"}, {"title": "xba", "value": "xba"}] }
# @raycast.packageName AWS

# Documentation:
# @raycast.description AWS SSOログインを実行
# @raycast.author takano_y

PROFILE="$1"

aws sso login --profile "$PROFILE"

echo "AWS SSO login completed for profile: $PROFILE"
