---
name: agent-memory
description: "Use this skill when the user asks to save, remember, recall, or organize memories. Triggers on: 'remember this', 'save this', 'note this', 'what did we discuss about...', 'check your notes', 'clean up memories', 'save conversation', 'save chat log', 'save this conversation'. Also use proactively when discovering valuable findings worth preserving."
---

# Agent Memory

A persistent memory space for storing knowledge that survives across conversations.

**Location:** `.claude/skills/agent-memory/memories/`

## Proactive Usage

Save memories when you discover something worth preserving:
- Research findings that took effort to uncover
- Non-obvious patterns or gotchas in the codebase
- Solutions to tricky problems
- Architectural decisions and their rationale
- In-progress work that may be resumed later

Check memories when starting related work:
- Before investigating a problem area
- When working on a feature you've touched before
- When resuming work after a conversation break

Organize memories when needed:
- Consolidate scattered memories on the same topic
- Remove outdated or superseded information
- Update status field when work completes, gets blocked, or is abandoned

## Folder Structure

When possible, organize memories into category folders. No predefined structure - create categories that make sense for the content.

Guidelines:
- Use kebab-case for folder and file names
- Consolidate or reorganize as the knowledge base evolves

Example:
```text
memories/
├── file-processing/
│   └── large-file-memory-issue.md
├── dependencies/
│   └── iconv-esm-problem.md
└── project-context/
    └── december-2025-work.md
```

This is just an example. Structure freely based on actual content.

## Frontmatter

All memories must include frontmatter with a `summary` field. The summary should be concise enough to determine whether to read the full content.

**Required:**
```yaml
---
summary: "1-2 line description of what this memory contains"
created: 2025-01-15  # YYYY-MM-DD format
---
```

**Optional:**
```yaml
---
summary: "Worker thread memory leak during large file processing - cause and solution"
created: 2025-01-15
updated: 2025-01-20
status: in-progress  # in-progress | resolved | blocked | abandoned
tags: [performance, worker, memory-leak]
related: [src/core/file/fileProcessor.ts]
---
```

## Search Workflow

Use summary-first approach to efficiently find relevant memories:

```bash
# 1. List categories
ls .claude/skills/agent-memory/memories/

# 2. View all summaries
rg "^summary:" .claude/skills/agent-memory/memories/ --no-ignore --hidden

# 3. Search summaries for keyword
rg "^summary:.*keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 4. Search by tag
rg "^tags:.*keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 5. Full-text search (when summary search isn't enough)
rg "keyword" .claude/skills/agent-memory/memories/ --no-ignore --hidden -i

# 6. Read specific memory file if relevant
```

**Note:** Memory files are gitignored, so use `--no-ignore` and `--hidden` flags with ripgrep.

## Operations

### Save

1. Determine appropriate category for the content
2. Check if existing category fits, or create new one
3. Write file with required frontmatter (use `date +%Y-%m-%d` for current date)

```bash
mkdir -p .claude/skills/agent-memory/memories/category-name/
# Note: Check if file exists before writing to avoid accidental overwrites
cat > .claude/skills/agent-memory/memories/category-name/filename.md << 'EOF'
---
summary: "Brief description of this memory"
created: 2025-01-15
---

# Title

Content here...
EOF
```

### Maintain

- **Update**: When information changes, update the content and add `updated` field to frontmatter
- **Delete**: Remove memories that are no longer relevant
  ```bash
  trash .claude/skills/agent-memory/memories/category-name/filename.md
  # Remove empty category folders
  rmdir .claude/skills/agent-memory/memories/category-name/ 2>/dev/null || true
  ```
- **Consolidate**: Merge related memories when they grow
- **Reorganize**: Move memories to better-fitting categories as the knowledge base evolves

## Guidelines

1. **Write self-contained notes**: Include full context so the reader needs no prior knowledge to understand and act on the content
2. **Keep summaries decisive**: Reading the summary should tell you if you need the details
3. **Stay current**: Update or delete outdated information
4. **Be practical**: Save what's actually useful, not everything

## Content Reference

When writing detailed memories, consider including:
- **Context**: Goal, background, constraints
- **State**: What's done, in progress, or blocked
- **Details**: Key files, commands, code snippets
- **Next steps**: What to do next, open questions

Not all memories need all sections - use what's relevant.

## Conversation Logs

会話の流れや議論の過程を残したい場合は、要点まとめとは別に会話ログを保存できる。

### When to Save Conversation Logs

- 複雑な調査や議論を行った場合
- 結論に至るまでの思考過程が重要な場合
- 後で「なぜそうなったか」を振り返りたい場合
- ユーザーが明示的に会話ログの保存を依頼した場合

### Format

**Location:** `conversation-logs/` カテゴリ

**Filename:** `YYYY-MM-DD-{topic}.md`

**Structure:**
```markdown
---
summary: "会話の概要（何について議論したか）"
created: 2025-01-15
tags: [conversation-log, related-tags]
related: [関連ファイルパス]
---

# 会話ログ: {タイトル}

## 発端
ユーザーの最初の質問や依頼

## 調査・議論
やり取りの流れを時系列で記録
- ユーザーの発言
- Claudeの調査内容や回答
- 認識の修正や追加の質問

## 結論
最終的な結論や決定事項
```

### Best Practice

1. **要点まとめと会話ログの両方を保存する**
   - 要点まとめ: サクッと確認したいとき用
   - 会話ログ: 議論の流れを振り返りたいとき用

2. **会話ログは読みやすく整形する**
   - 生のやり取りをそのままコピペするのではなく、セクション分けして整理
   - コードブロックや箇条書きを活用

3. **重要な発言や気づきを強調する**
   - 認識の修正や重要な指摘は明確に記録
