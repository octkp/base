---
name: code-to-rollback-sql
description: 指定されたコード（メソッド、関数）を解析し、INSERT/UPDATE/DELETEされるテーブル・カラムを洗い出し、agent-memoryに記憶し、ロールバック用SQLを生成する。「このコードで作成されるデータを解析してロールバックSQLを作って」「@ファイルパス#行番号 のデータ変更を調べてSQL生成して」「このメソッドのロールバックSQLを作成」などのリクエストでトリガー。
---

# Code to Rollback SQL Generator

指定されたコードを解析し、3つのフェーズでロールバックSQLを生成するスキル。
このスキルはオーケストレーターとして機能し、各フェーズはサブエージェント（Task tool）で実行する。

## 入力

- ファイルパスと行番号（例: `@src/xba/packages/xbacore/classes/task/5min.php#L123-161`）
- または、解析対象のメソッド/関数名

## ワークフロー

### Phase 1: コード解析

**使用ツール:** Task tool (subagent_type: db-change-analyzer)

このプロジェクト専用の特化エージェントを使用。mk1フレームワーク（FuelPHPベース）のパターンを理解している。

```
description: "コード解析とデータ変更洗い出し"
subagent_type: "db-change-analyzer"
prompt: |
  指定されたコード [ファイルパス:行番号] を解析し、以下を特定してください：

  1. このコードが呼び出すメソッド・関数を特定
  2. 各メソッドでINSERT/UPDATE/DELETEされるテーブルを特定
  3. 変更されるカラムを一覧化
  4. 外部キー制約（ON DELETE CASCADE等）を確認
  5. 結果をテーブル形式でまとめる

  出力形式:
  | テーブル | 操作 | 主要カラム |
  |---------|------|-----------|
  | table_name | INSERT/UPDATE/DELETE | column1, column2, ... |
```

**Phase 1完了後:** AskUserQuestionで確認を取る

```
質問: 「解析結果を確認してください。この内容を記憶に保存しますか？」
選択肢:
- はい、記憶に保存する
- いいえ、Phase 3に進む（記憶をスキップ）
- 修正が必要
```

### Phase 2: 記憶保存

**使用ツール:** Task tool (subagent_type: general-purpose)

```
description: "解析結果をメモリに保存"
subagent_type: "general-purpose"
prompt: |
  agent-memoryスキルを使用して、以下の解析結果を保存してください：

  [Phase 1の解析結果をここに渡す]

  保存要件:
  - 保存先: .claude/skills/agent-memory/memories/ 配下の適切なカテゴリ
  - ファイル名: 解析対象に基づいて命名
  - frontmatter: summary, created, tags, related を設定

  保存が完了したらファイルパスを報告してください。
```

**Phase 2完了後:** AskUserQuestionで確認を取る

```
質問: 「記憶に保存しました。ロールバックSQLを生成しますか？」
選択肢:
- はい、SQLを生成する
- いいえ、ここで終了
```

### Phase 3: SQL生成

**使用ツール:** Task tool (subagent_type: general-purpose)

```
description: "ロールバックSQL生成"
subagent_type: "general-purpose"
prompt: |
  sql-generatorスキルを使用して、以下のテーブルをロールバックするSQLを作成してください：

  [Phase 1で特定したテーブル一覧と操作]

  要件:
  - 外部キー制約を考慮した削除順序
  - 変数設定（SET v.xxx）による柔軟なID指定
  - 確認用SELECT文を含める
  - ON DELETE CASCADEがある場合は親テーブル削除のみで可

  出力先: .claude/skills/sql-generator/sqls/xba/ または bamanager/

  生成が完了したらファイルパスを報告してください。
```

**Phase 3完了後:** 生成されたSQLファイルのパスを報告

## コンテキストの受け渡し

各フェーズ間でコンテキストを渡す際は、前フェーズの結果を次フェーズのpromptに含める：

```
Phase 1 結果 → Phase 2 promptに含める → Phase 2 結果 → Phase 3 promptに含める
```

## 注意事項

- companiesテーブル等の更新は履歴がないためロールバック不可（コメントで警告を含める）
- ON DELETE CASCADEがある場合は親テーブル削除のみで可
- 本番実行前に必ずSELECTで確認することを推奨
- charge_histories.ch_ng_notified_at のような通知フラグ更新はロールバック不要

## 使用例

```
ユーザー: @src/xba/packages/xbacore/classes/task/5min.php#L123-161 のデータ変更を解析してロールバックSQLを作成して

Claude（オーケストレーター）:
1. Task tool (db-change-analyzer) でコード解析 → 結果取得
2. 解析結果を表示 → AskUserQuestion で確認
3. Task tool (general-purpose) で記憶保存 → 結果取得
4. 記憶完了を表示 → AskUserQuestion で確認
5. Task tool (general-purpose) でSQL生成 → 結果取得
6. 完了報告（SQLファイルパス）
```

## 使用するエージェント

| Phase | エージェント | 特化内容 |
|-------|-------------|---------|
| 1 | db-change-analyzer | mk1フレームワークのDB操作パターンを理解 |
| 2 | general-purpose | agent-memoryスキルを使用 |
| 3 | general-purpose | sql-generatorスキルを使用 |