---
name: code-to-doc
description: 指定されたコード（ファイルパス、行範囲、メソッド名など）を読み取り、DBとのやり取りを中心にした機能ドキュメントを生成する。「ドキュメント化して」「機能を説明して」「コードを解析してドキュメント作成」「この処理のDB操作をまとめて」などのリクエストでトリガー。出力先はスキルディレクトリのdocs/{feature}.md。
---

# Code to Doc

指定されたコードを解析し、DB操作を中心とした機能ドキュメントを生成するスキル。

## ワークフロー

### 1. コード特定

ユーザーから以下の形式で対象を受け取る:
- ファイルパス + 行範囲: `@src/path/to/file.php#L100-200`
- メソッド名: `Model_Charge::create_charge()`
- クラス名: `Model_Charge`
- 機能名: 「課金処理」「ユーザー登録」など

### 2. コード解析

対象コードを読み取り、以下を特定:

1. **関連テーブル**: `\DB::select()`, `\DB::insert()`, `\DB::update()`, `\DB::delete()`, ORMモデルの操作
2. **データ操作**: INSERT/UPDATE/DELETEの具体的な内容
3. **処理フロー**: 条件分岐、ループ、トランザクション
4. **依存関係**: 呼び出しているメソッド、使用しているモデル

### 3. ドキュメント生成

スキルディレクトリの `docs/{feature}.md` に以下の構造で出力:

```markdown
# {機能名}

## 概要
{機能の目的と役割を1-2文で}

## 関連テーブル

| テーブル名 | 用途 | 主なカラム |
|-----------|------|-----------|
| table_name | 説明 | col1, col2, col3 |

## データ操作

### INSERT（作成）
- **対象テーブル**: table_name
- **挿入データ**:
  - `column1`: 値の説明
  - `column2`: 値の説明
- **コード参照**: `path/to/file.php:123`

### UPDATE（更新）
- **対象テーブル**: table_name
- **更新条件**: WHERE句の説明
- **更新内容**:
  - `column1`: 新しい値の説明
- **コード参照**: `path/to/file.php:145`

### DELETE（削除）
- **対象テーブル**: table_name
- **削除条件**: WHERE句の説明
- **コード参照**: `path/to/file.php:160`

## 処理フロー

1. {ステップ1の説明}
2. {ステップ2の説明}
3. ...

## 注意点・補足

- {重要な注意点}
- {エラーハンドリングの説明}
```

## 解析のポイント

### PHPコードでのDB操作パターン

```php
// Query Builder
\DB::select('*')->from('table')->where('id', $id)->execute();
\DB::insert('table')->set(['col' => $val])->execute();
\DB::update('table')->set(['col' => $val])->where('id', $id)->execute();
\DB::delete('table')->where('id', $id)->execute();

// ORM
Model_User::find($id);
Model_User::forge($data)->save();
$model->set(['col' => $val])->save();
$model->delete();
```

### 接続先の確認

```php
// 接続先データベースの指定
->execute('bamanager')  // BAManagerデータベース
->execute('default')    // XBAデータベース
->execute('chat')       // チャットデータベース
```

### トランザクション

```php
\DB::start_transaction();
// 処理
\DB::commit_transaction();
// or \DB::rollback_transaction();
```

## 出力ルール

1. ドキュメントはスキルディレクトリの `docs/` に出力（存在しない場合は作成）
2. ファイル名は機能を表す英語のケバブケース: `code-to-doc/docs/charge-creation.md`
3. コード参照は `path/to/file.php:行番号` の形式で記載
4. 日本語で記述