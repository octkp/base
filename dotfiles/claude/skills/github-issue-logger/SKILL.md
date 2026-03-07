# GitHub Issue Knowledge Logger

GitHub IssueのURLを入力として、調査・実装の会話ログとナレッジをドキュメント化し、GitHub Issueにもコメントとしてナレッジを投稿するスキル。

## 出力先ディレクトリ

ベースパス: `~/base/tasks`

### 作成されるファイル

各Issueディレクトリに以下のファイルを作成:

- `LOG.md` - 会話ログ（時系列の詳細記録）
- `README.md` - まとめ（結論・要点のサマリー）

### ディレクトリ構造

```
~/base/tasks/{issueタイトル}/
├── LOG.md
└── README.md
```

## ワークフロー

### 1. ユーザーからの入力を取得

ユーザーから以下の情報を受け取る:

- **GitHub Issue URL**: `https://github.com/{owner}/{repo}/issues/{number}` 形式

### 2. GitHub Issueから情報を取得

`gh` CLIを使用してIssue情報を取得する。

```bash
gh issue view {URL} --json title,body,number,labels,state,assignees,milestone
```

取得する情報:
- **title**: Issueのタイトル（ディレクトリ名に使用）
- **number**: Issue番号
- **body**: Issueの本文（README.mdの概要に使用）
- **labels**: ラベル（カテゴリ判定の参考に）
- **state**: ステータス
- **assignees**: 担当者
- **milestone**: マイルストーン

### 3. ディレクトリ名の決定

- Issueタイトルをディレクトリ名に使用する
- ファイルシステムで使えない文字（`/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`）はアンダースコア `_` に置換する
- スペースはハイフン `-` に置換する
- ディレクトリ名が長すぎる場合（80文字超）は切り詰める

例:
- Issue: "Add dark mode support" → `~/base/tasks/Add-dark-mode-support/`
- Issue: "Fix: login bug on Safari" → `~/base/tasks/Fix_-login-bug-on-Safari/`

### 4. ディレクトリ作成

```bash
mkdir -p ~/base/tasks/{issueタイトル}
```

### 5. LOG.md 作成

会話ログファイルを作成:

**重要**: 日時は必ず `YYYY-MM-DD HH:MM` 形式で、**時刻（HH:MM）を省略せずに**記録すること。現在時刻は `date "+%Y-%m-%d %H:%M"` コマンドで取得できる。

```markdown
# {issueタイトル} 会話ログ

## 基本情報

- **Issue**: {owner}/{repo}#{number}
- **URL**: {issue URL}
- **ラベル**: {labels}
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

### 6. README.md 作成

まとめファイルを作成:

```markdown
# {issueタイトル}

## 基本情報

| 項目 | 内容 |
|------|------|
| Issue | [{owner}/{repo}#{number}]({issue URL}) |
| ラベル | {labels} |
| ステータス | {state} |
| 担当者 | {assignees} |

## 概要

{Issueのbodyから要約、またはbodyをそのまま記載}

## 結論/解決策

{最終的な結論、解決策、または実装内容 - 作業完了後に更新}

## 関連ファイル

- `path/to/file:123` - {説明}

## 参考情報

- {参考にしたドキュメント、URL}
- {関連するIssue}

## ログ

詳細は [LOG.md](./LOG.md) を参照。
```

### 7. GitHub Issueにコメント投稿

ログやREADMEを作成・更新した際、GitHub Issueにもナレッジコメントを投稿する。

#### ツール

`gh` CLIを使用する。

```bash
gh issue comment {issue URL} --body "{コメント本文}"
```

#### コメントフォーマット

```markdown
## 📝 ナレッジ記録

### 概要
{Issueの目的・背景を1-2文で}

### 結論/解決策
{最終的な結論、解決策、または実装内容}

### 関連ファイル
- `path/to/file:123` - {説明}

### 参考情報
- {参考にしたドキュメント、URL}

---
*このコメントはClaude Codeのgithub-issue-loggerスキルにより自動投稿されました*
*詳細ログ: `~/base/tasks/{issueタイトル}/`*
```

#### 注意事項

- コメントはREADME.mdの内容に基づく要約とする（LOG.mdの詳細はローカルのみ）
- 機密情報（パスワード、APIキー、内部IPアドレス等）はコメントに含めない
- コメント投稿前にユーザーに内容を確認してもらう（AskUserQuestionで「このコメントをGitHub Issueに投稿してよいですか？」と確認）
- コメント投稿に失敗した場合はエラーを表示するが、ローカルファイルの作成は完了とみなす

## 使用例

### 新規Issueの記録開始

```
/github-issue-logger https://github.com/myorg/myrepo/issues/42
```

実行:
1. `gh issue view` でIssue情報を取得
2. `~/base/tasks/{issueタイトル}/` ディレクトリ作成
3. `LOG.md` テンプレート作成（Issue情報を反映）
4. `README.md` テンプレート作成（Issue情報を反映）
5. コメント内容をユーザーに確認
6. GitHub Issueにコメント投稿

### ログの追記

ユーザー: 「今の会話を{issueタイトル}に追記して」

実行:
1. 既存のLOG.mdを読み込み
2. 新しいセッションを追記
3. README.mdを更新
4. コメント内容をユーザーに確認
5. GitHub Issueに最新のナレッジをコメント投稿

### まとめの更新

ユーザー: 「{issueタイトル}のREADMEを更新して」

実行:
1. LOG.mdの内容から要点を抽出
2. README.mdを更新
3. コメント内容をユーザーに確認
4. GitHub Issueに更新されたナレッジをコメント投稿

## 注意事項

- ログは時系列で追記していく（上書きしない）
- README.mdは調査/実装が完了したタイミングで更新
- 機密情報（パスワード、APIキー等）は記録しない
- **日時は必ず時刻（HH:MM）まで記録すること**（例: `2026-02-05 14:30`、`2026-02-05` だけはNG）
- `gh` CLIが認証済みであることが前提（`gh auth status` で確認可能）
- Issue URLのパースに失敗した場合はユーザーに確認する
- GitHub Issueコメント投稿前に必ずユーザー確認を行う
- コメントにはログの全量ではなく要約のみを投稿する
