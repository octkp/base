#!/bin/bash
# Claude Code Stop Hook - Slack通知
# Claudeが応答を完了しユーザー入力待ちになった際にSlackへ通知する
# ターミナルがフォアグラウンドの場合は通知をスキップする

# ターミナルがフォアグラウンドなら通知しない
FRONTMOST_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if echo "$FRONTMOST_APP" | grep -qi "^iTerm2$"; then
  exit 0
fi

INPUT=$(cat)

WEBHOOK_URL="${CLAUDE_SLACK_WEBHOOK_URL:?CLAUDE_SLACK_WEBHOOK_URL is not set}"
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // "（メッセージなし）"')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
PROJECT_NAME=$(basename "$PROJECT_DIR")

# メッセージをクリーンアップ（markdown記号除去、プレーンテキスト化、3000文字に切り詰め）
CLEAN_MSG=$(echo "$LAST_MSG" | sed 's/\\n/ /g; s/\*\*//g; s/`//g; s/^## *//; s/^### *//' | head -c 3000)
if [ ${#LAST_MSG} -gt 3000 ]; then
  CLEAN_MSG="${CLEAN_MSG}..."
fi

PAYLOAD=$(jq -n \
  --arg project "$PROJECT_NAME" \
  --arg msg "$CLEAN_MSG" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "Claude Code のタスクが完了しました",
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
          "text": (":speech_balloon: *最後のメッセージ*\n" + $msg)
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
