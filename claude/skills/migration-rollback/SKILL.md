---
name: migration-rollback
description: JIRAチケット番号（BAX-XXXXなど）とプロジェクト（bamanager/xba）を指定して、関連するマイグレーションファイルをロールバックするSQLを生成するスキル。「BAX-10325のbamanagerをロールバックして」「xbaのBAX-10325を戻して」などのリクエストで使用。
---

# Migration Rollback

JIRAチケット番号とプロジェクトを指定して、関連するマイグレーションをロールバックするSQLファイルを生成する。

## マイグレーションファイルの場所

| プロジェクト | パス |
|------------|------|
| bamanager | `src/bamanager/migration/` |
| xba | `src/xba/packages/xbacore/migration/` |

## 作成したロールバックファイルの出力先

出力先: `/Users/takano_y/.claude/skills/migration-rollback/rollback-{チケット番号}.sql`

例: `/Users/takano_y/.claude/skills/migration-rollback/rollback-BAX-10325.sql`

## ワークフロー

1. プロジェクト（bamanager/xba）とチケット番号（例: BAX-10325）を特定
2. 対応するディレクトリでマイグレーションファイルを検索
3. 見つかったファイルをプレフィックス（実行順）でソート
4. 各ファイルの内容を読み込み
5. 逆順（降順）でロールバックSQLを生成

## 実行手順

### 1. マイグレーションファイルの検索

bamanagerの場合:
```bash
find src/bamanager/migration/ -name "*BAX-10325*.sql" | sort -t'-' -k1 -n
```

xbaの場合:
```bash
find src/xba/packages/xbacore/migration/ -name "*BAX-10325*.sql" | sort -t'-' -k1 -n
```

### 2. ファイルの読み込みと解析

各SQLファイルを読み込み、実行された操作を特定：
- `CREATE TABLE` → `DROP TABLE`
- `ALTER TABLE ... ADD COLUMN` → `ALTER TABLE ... DROP COLUMN`
- `INSERT INTO` → `DELETE FROM`
- `UPDATE ... SET` → 元の値に戻すUPDATE（可能な場合）

### 3. ロールバックSQL生成

プレフィックスの降順（大きい番号から小さい番号）でロールバックSQLを生成。

例: BAX-10325の場合
```
1770 → 1769 → 1768 → 1767 → 1766 の順でロールバック
```

### 4. migrationsテーブルのレコード削除

**重要**: ロールバックSQLの最後（COMMIT前）に、必ずmigrationsテーブルから該当チケットのレコードを削除する処理を追加すること。

```sql
DELETE FROM migrations WHERE migration_name LIKE '%BAX-XXXXX%';
```

## ロールバックSQL変換ルール

| 元の操作 | ロールバック操作 |
|---------|----------------|
| `CREATE TABLE table_name` | `DROP TABLE IF EXISTS table_name;` |
| `ALTER TABLE t ADD COLUMN col` | `ALTER TABLE t DROP COLUMN col;` |
| `INSERT INTO t (cols) VALUES (vals)` | `DELETE FROM t WHERE {条件};` |
| `CREATE INDEX idx ON t` | `DROP INDEX idx;` |

## 注意事項

- 生成されたSQLは必ずレビューしてから実行
- UPDATE文の逆操作は元データが不明な場合は手動対応が必要
- 本番環境での実行前にバックアップを取得