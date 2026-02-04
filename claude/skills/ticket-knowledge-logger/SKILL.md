---
name: ticket-knowledge-logger
description: チケット番号（BAX-XXXX）とカテゴリ（investigations/Implementations/others）を指定して、会話ログとまとめファイルを記録するスキル。「BAX-10325のinvestigationsを記録」「Implementationsにチケット作成」「会話ログを保存」などのリクエストで使用。
---

# Ticket Knowledge Logger

チケット調査・実装の会話ログとナレッジをドキュメント化するスキル。

## 出力先ディレクトリ

ベースパス: `/Users/takano_y/ghq/github.com/kokopelli-inc/badev-knowledge-base/docs/takano`

### カテゴリ構造

| カテゴリ | 用途 | パス |
|---------|------|------|
| investigations | バグ調査、原因特定、コード解析 | `{base}/investigations/BAX-XXXX/` |
| Implementations | 機能実装、コード変更、リファクタリング | `{base}/Implementations/BAX-XXXX/` |
| others | その他の作業、ドキュメント作成など | `{base}/others/BAX-XXXX/` |

### 作成されるファイル

各チケットディレクトリに以下のファイルを作成:

- `LOG.md` - 会話ログ（時系列の詳細記録）
- `README.md` - まとめ（結論・要点のサマリー）

## ワークフロー

### 1. ユーザーからの入力を取得

ユーザーから以下の情報を受け取る:

- **カテゴリ**: `investigations` / `Implementations` / `others`
- **チケット番号**: `BAX-XXXX` 形式

### 2. ディレクトリ作成

```bash
mkdir -p /Users/takano_y/ghq/github.com/kokopelli-inc/badev-knowledge-base/docs/takano/{カテゴリ}/{チケット番号}
```

### 3. LOG.md 作成

会話ログファイルを作成:

```markdown
# {チケット番号} 会話ログ

## 基本情報

- **チケット**: {チケット番号}
- **カテゴリ**: {カテゴリ}
- **作成日時**: {YYYY-MM-DD HH:MM}

---

## 会話ログ

### {YYYY-MM-DD HH:MM} - セッション1

#### 質問/タスク
{ユーザーからの質問やタスクの内容}

#### 調査/作業内容
{調査した内容、読んだファイル、実行したコマンドなど}

#### 結果/発見
{発見した事項、結論、解決策など}

---

### {YYYY-MM-DD HH:MM} - セッション2
...
```

### 4. README.md 作成

まとめファイルを作成:

```markdown
# {チケット番号}

## 概要

{チケットの目的・背景を1-2文で}

## 結論/解決策

{最終的な結論、解決策、または実装内容}

## 関連ファイル

- `path/to/file.php:123` - {説明}

## 参考情報

- {参考にしたドキュメント、URL}
- {関連するチケット番号}

## ログ

詳細は [LOG.md](./LOG.md) を参照。
```

## 使用例

### 新規チケットの記録開始

ユーザー: 「BAX-10325のinvestigationsを記録して」

実行:
1. `investigations/BAX-10325/` ディレクトリ作成
2. `LOG.md` テンプレート作成
3. `README.md` テンプレート作成

### ログの追記

ユーザー: 「今の会話をBAX-10325に追記して」

実行:
1. 既存のLOG.mdを読み込み
2. 新しいセッションを追記

### まとめの更新

ユーザー: 「BAX-10325のREADMEを更新して」

実行:
1. LOG.mdの内容から要点を抽出
2. README.mdを更新

## カテゴリ判定の目安

| キーワード | カテゴリ |
|-----------|---------|
| 調査、バグ、原因、なぜ、エラー | investigations |
| 実装、修正、追加、変更、リファクタ | Implementations |
| ドキュメント、メモ、その他 | others |

## 注意事項

- ログは時系列で追記していく（上書きしない）
- README.mdは調査/実装が完了したタイミングで更新
- 機密情報（パスワード、API キー等）は記録しない
