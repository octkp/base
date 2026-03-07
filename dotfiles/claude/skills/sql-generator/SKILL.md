---
name: sql-generator
description: アプリケーションのDBスキーマやコードを解析して、ユーザーの要求に応じたSQLクエリを生成する。「○○を取得するSQL」「○○を更新するSQL」「○○のデータを集計したい」などのリクエストでトリガーする。PostgreSQL向け。
---

# SQL Generator

DBスキーマとアプリケーションコードを解析し、目的のSQLを生成する。

## 作成したファイルの出力先

SQLファイル
- 対応するDB（bamanager or xba）によってディレクトリを分ける。

- `/Users/takano_y/.claude/skills/sql-generator/sqls/bamanager/{任意の名前（日本語）}.sql`
- `/Users/takano_y/.claude/skills/sql-generator/sqls/xba/{任意の名前（日本語）}.sql`

※ QA検証用のテストデータSQLは `charge-test-data-generator` スキルを使用すること。

## ワークフロー

### 1. スキーマの特定

プロジェクト内のスキーマ定義を探す:

```bash
# SQLファイルを検索
find . -name "*.sql" -type f | head -20

# マイグレーションディレクトリを探す
find . -type d -name "migrations" -o -name "migrate" -o -name "db" 2>/dev/null
```

よくある場所:
- `db/migrations/`
- `migrations/`
- `sql/`
- `schema/`
- `database/`

### 2. スキーマ解析

CREATE TABLE文からテーブル構造を把握:
- テーブル名とカラム
- 主キー・外部キー
- インデックス
- 制約（NOT NULL, UNIQUE, CHECK等）

関連テーブルのリレーションを理解するために外部キー制約を確認。

### 3. アプリコード参照（必要に応じて）

複雑なクエリの場合、既存の実装を参照:

```bash
# リポジトリ/DAOパターンを探す
find . -name "*Repository*" -o -name "*DAO*" -o -name "*Query*" 2>/dev/null

# SQLを含むコードを検索
grep -r "SELECT\|INSERT\|UPDATE\|DELETE" --include="*.ts" --include="*.py" --include="*.go" .
```

### 4. SQL生成

ユーザーの要求に基づいてSQLを生成。以下を考慮:

**SELECT文**
- すべてのカラムを明示的に列挙する（`SELECT *` は使わない）
- 適切なJOIN（INNER/LEFT/RIGHT）
- WHERE条件の最適化
- ORDER BY, LIMIT

**INSERT/UPDATE/DELETE文**
- トランザクション境界の考慮
- RETURNING句の活用（PostgreSQL）
- ON CONFLICT（UPSERT）

**集計クエリ**
- GROUP BY
- 集計関数（COUNT, SUM, AVG, MAX, MIN）
- HAVING
- ウィンドウ関数

## 変数の扱い方

PostgreSQLの `SET` と `current_setting` を使用して変数を管理する。

### 変数の設定方法

```sql
-- 数値
SET v.変数名 = '値';

-- 文字列
SET v.変数名 = '文字列値';
```

### 変数の参照方法

```sql
-- 数値として使用（キャストが必要）
WHERE column = current_setting('v.変数名')::int

-- 文字列として使用
WHERE column = current_setting('v.変数名')

-- UUIDとして使用
WHERE column = current_setting('v.変数名')::uuid
```

## PostgreSQL固有機能

活用すべき機能:
- `RETURNING` - INSERT/UPDATE/DELETE結果の取得
- `ON CONFLICT DO UPDATE` - UPSERT
- `WITH (CTE)` - 複雑なクエリの分解
- `LATERAL JOIN` - サブクエリの相関
- `ARRAY`, `JSONB` - 構造化データ型
- `COALESCE`, `NULLIF` - NULL処理

## 出力フォーマット

```sql
-- 目的: [クエリの目的を簡潔に説明]
-- 対象テーブル: [使用するテーブル]

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.変数名1 = '値1';
SET v.変数名2 = '値2';

-------------------------------
-- クエリ実行
-------------------------------
SELECT ...
FROM ...
WHERE column = current_setting('v.変数名1')::型;
```

必要に応じて:
- インデックス推奨
- パフォーマンス注意点
- 代替アプローチ

## 重要なルール

- **SELECTはすべてのカラムを出力**: SELECT文では対象テーブルのすべてのカラムを明示的に列挙する。`SELECT *` は使わない
- **ASでのカラム名変更禁止**: カラム名はそのまま出力する。`AS "日本語名"` や `AS alias_name` でのリネームはしない
- **日本語名への変換禁止**: カラム名を日本語に変換して表示しない。元のカラム名をそのまま使用する
- **テーブルエイリアス禁止**: `FROM invoices i` のようなエイリアスは使わず、フルテーブル名を使用する

悪い例:
```sql
SELECT i.charge_date, i.charge_amount FROM invoices i;
```

良い例:
```sql
SELECT invoices.charge_date, invoices.charge_amount FROM invoices;
```