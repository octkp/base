#!/bin/bash
# AskUserQuestion時に通知を送るスクリプト

# stdinからJSONを読み取る
input=$(cat)

# 質問内容を抽出
questions=$(echo "$input" | jq -r '.tool_input.questions // empty')

if [ -n "$questions" ]; then
    # 最初の質問のヘッダーを取得
    header=$(echo "$questions" | jq -r '.[0].header // "質問"')
    question=$(echo "$questions" | jq -r '.[0].question // "Claude Codeからの質問があります"')

    # macOS通知を送信
    osascript -e "display notification \"$question\" with title \"Claude Code\" subtitle \"$header\" sound name \"Glass\""
fi

exit 0