#!/bin/bash
# ClaudeTerminalActivator.app を作成・登録するセットアップスクリプト
# claude-terminal:// URLスキームを処理し、ターミナルアプリをフォアグラウンドにする

APP_DIR="$HOME/Applications/ClaudeTerminalActivator.app"

# 既存アプリがあれば削除して再作成
if [ -d "$APP_DIR" ]; then
  rm -rf "$APP_DIR"
fi

# 1. AppleScriptアプリを作成
# ターミナルアプリを変更する場合:
#   1. 下記の "Ghostty" を使用したいアプリ名に変更する
#      例: "iTerm", "Terminal", "WezTerm", "Alacritty" など
#   2. このスクリプトを再実行してアプリを再作成する
#      bash ~/.claude/hooks/slack-notify/setup-terminal-activator.sh
osacompile -o "$APP_DIR" -e '
on open location theURL
    tell application "iTerm2" to activate
end open location
'

if [ ! -d "$APP_DIR" ]; then
  echo "アプリの作成に失敗しました"
  exit 1
fi

# 2. Info.plistにURLスキームを登録
plutil -insert CFBundleURLTypes -xml \
    '<array><dict><key>CFBundleURLName</key><string>Claude Terminal Activator</string><key>CFBundleURLSchemes</key><array><string>claude-terminal</string></array></dict></array>' \
    "$APP_DIR/Contents/Info.plist"

# 3. Dockに表示しない（バックグラウンドアプリ化）
plutil -insert LSUIElement -bool true \
    "$APP_DIR/Contents/Info.plist"

# 4. Gatekeeperの隔離属性を除去
xattr -dr com.apple.quarantine "$APP_DIR" 2>/dev/null

# 5. Launch Servicesに登録
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR"

echo "ClaudeTerminalActivator.app を作成・登録しました: $APP_DIR"
echo "  URLスキーム: claude-terminal://activate"
echo ""
echo "検証: open claude-terminal://activate"
