#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title launcher
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description badev-launcherをターミナルで起動する
# @raycast.author takano_y

LAUNCHER_PATH="/Users/takano_y/ghq/github.com/kokopelli-inc/badev-launcher/launcher.sh"

# iTerm2で実行
osascript <<EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "cd /Users/takano_y/ghq/github.com/kokopelli-inc/badev-launcher && $LAUNCHER_PATH"
    end tell
end tell
EOF
