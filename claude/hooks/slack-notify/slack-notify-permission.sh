#!/bin/bash
# Claude Code Notification Hook - Slack通知
# Claudeが許可を求めている際にSlackへ通知する

# ターミナルがフォアグラウンドなら通知しない
FRONTMOST_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if echo "$FRONTMOST_APP" | grep -qi "^iTerm2$"; then
  exit 0
fi

WEBHOOK_URL="${CLAUDE_SLACK_WEBHOOK_URL:?CLAUDE_SLACK_WEBHOOK_URL is not set}"

INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
PROJECT_NAME=$(basename "$PROJECT_DIR")
RAW_MESSAGE=$(echo "$INPUT" | jq -r '.message // "（メッセージなし）"')

# 英語のシステムメッセージを日本語に変換
if echo "$RAW_MESSAGE" | grep -qi "needs your approval for the plan"; then
  MESSAGE="プランの承認が必要です"
elif echo "$RAW_MESSAGE" | grep -qi "wants to execute"; then
  MESSAGE="コマンドの実行許可が必要です"
elif echo "$RAW_MESSAGE" | grep -qi "wants to edit"; then
  MESSAGE="ファイル編集の許可が必要です"
elif echo "$RAW_MESSAGE" | grep -qi "wants to write"; then
  MESSAGE="ファイル書き込みの許可が必要です"
elif echo "$RAW_MESSAGE" | grep -qi "wants to delete"; then
  MESSAGE="ファイル削除の許可が必要です"
else
  MESSAGE="$RAW_MESSAGE"
fi

PAYLOAD=$(jq -n \
  --arg project "$PROJECT_NAME" \
  --arg message "$MESSAGE" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":warning: Claude Code が許可を求めています",
          "emoji": true
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": (":file_folder: *プロジェクト*\n" + $project)
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": (":speech_balloon: *メッセージ*\n" + $message)
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":computer: *<claude-terminal://activate|ターミナルに戻る>*"
        }
      }
    ]
  }')

curl -s -X POST "$WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "$PAYLOAD" > /dev/null 2>&1

exit 0
