# Raycast Script Commands

Raycast用のカスタムスクリプトコマンド集。

## セットアップ

1. Raycastを開く
2. `Extensions` → `Script Commands` → `Add Directories`
3. `~/base/raycast/scripts` を追加

## スクリプト一覧

| コマンド | 説明 |
|---------|------|
| `launcher` | badev-launcherをiTerm2で起動 |
| `note` | クイックノートを保存（オプションでZedで開く） |
| `AWS SSO Login` | AWS SSOログインを実行（プロファイル選択式） |

## 使い方

### launcher

Raycastで「launcher」と入力して実行。iTerm2でbadev-launcherが起動する。

### note

Raycastで「note」と入力し、メモ内容を入力して実行。

- `~/base/note/` に `YYYYMMDD-HHMMSS.md` 形式で保存
- 第2引数で「open」を選択するとZedで開く

### AWS SSO Login

Raycastで「AWS SSO Login」と入力し、プロファイルを選択して実行。

- `ba_developers`、`koko`、`xba` から選択可能
- ブラウザが開きSSOログインが実行される

## スクリプトの追加方法

`scripts/` ディレクトリに新しい `.sh` ファイルを作成し、Raycastのメタデータを記述する。

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title スクリプト名
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔧
# @raycast.packageName カテゴリ名

# Documentation:
# @raycast.description スクリプトの説明

# ここに処理を記述
```

### モード

- `silent` - バックグラウンド実行（通知のみ）
- `compact` - 結果を小さく表示
- `fullOutput` - 結果を全画面表示
