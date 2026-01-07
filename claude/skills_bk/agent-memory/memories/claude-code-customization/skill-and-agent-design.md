---
summary: "スキルとサブエージェントの設計パターン - code-to-rollback-sqlスキルとdb-change-analyzerエージェントの実装例"
created: 2026-01-07
status: resolved
tags: [skill, agent, design-pattern, orchestrator]
related: [~/.claude/skills/code-to-rollback-sql/SKILL.md, .claude/agents/db-change-analyzer.md]
---

# スキルとサブエージェントの設計パターン

## 作成したもの

### 1. スキル: code-to-rollback-sql
- **場所**: `~/.claude/skills/code-to-rollback-sql/SKILL.md`
- **役割**: オーケストレーター（3フェーズを制御）
- **トリガー**: 「このコードのデータ変更を解析してロールバックSQLを作って」

### 2. エージェント: db-change-analyzer
- **場所**: `.claude/agents/db-change-analyzer.md`
- **役割**: mk1フレームワークのDB操作パターンを理解した特化エージェント
- **検出対象**: Model_*クラス、\DB::操作、save()/delete()メソッド

## 設計パターン: オプションB（オーケストレーター + サブエージェント）

```
スキル（オーケストレーター）
├── Phase 1: db-change-analyzer（特化） → コード解析
│       ↓ ユーザー確認
├── Phase 2: general-purpose → agent-memory使用
│       ↓ ユーザー確認
└── Phase 3: general-purpose → sql-generator使用
```

## スキル vs サブエージェントの使い分け

| 特性 | スキル (Skill tool) | サブエージェント (Task tool) |
|------|---------------------|------------------------------|
| 実行場所 | 現在のコンテキスト内 | 独立した新コンテキスト |
| 本質 | **手順書**（Claudeが読んで実行） | **別プロセス**（結果だけ返す） |
| コンテキスト共有 | あり | なし |
| 向いているタスク | 専門知識・ワークフロー提供 | 独立した調査・探索タスク |

## 特化エージェントが有効なケース

- 繰り返し使用される特定タスク
- ドメイン固有の知識が必要
- 特定のファイルパターンや命名規則がある
- 複雑な判断ロジックがある

## カスタムエージェントの定義方法

**場所**: プロジェクトの `.claude/agents/` ディレクトリ

**形式**: Markdownファイル（`.md`）

```yaml
---
name: エージェント名
description: 説明（いつ使うか、例を含む）
model: sonnet  # sonnet, opus, haiku
tools:  # オプション
  - Bash
  - Read
color: blue  # オプション
---

# エージェントの指示内容
```

## 関連ファイル

- `~/.claude/skills/code-to-rollback-sql/SKILL.md` - スキル定義
- `.claude/agents/db-change-analyzer.md` - 特化エージェント
- `~/.claude/settings.json` - skills配列に登録が必要

## 既存の特化エージェント（参考）

| エージェント | 用途 |
|-------------|------|
| db-change-analyzer | DBデータ変更の解析 |
| sync-processor-expert | 同期処理のレビュー |
| charge-test-runner | 課金テストの実行 |