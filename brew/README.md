# brew/

Homebrew のパッケージ管理（GUIアプリ用）

## Nix との使い分け

| 用途 | 管理ツール |
|------|-----------|
| CLIツール（bat, fzf等） | Nix (`home/packages.nix`) |
| GUIアプリ（Docker, Raycast等） | Homebrew（ここ） |
| PHP / Composer / asdf | Homebrew（ここ） |

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `Brewfile` | パッケージ定義 |
| `Brewfile.lock.json` | バージョンロック |

## よく使うコマンド

```bash
# Brewfile からインストール
brewfile-install

# 現在のパッケージを Brewfile に出力
brewfile-dump

# Brewfile にないパッケージを削除
brewfile-cleanup

# 全パッケージを更新
update-app
```

## Brewfile の書き方

```ruby
# tap（リポジトリ追加）
tap "homebrew/bundle"

# brew（CLIツール）- 今後は Nix 推奨
brew "asdf"
brew "php"

# cask（GUIアプリ）
cask "docker"
cask "raycast"
cask "notion"
```

## 詳細なコマンドオプション

### `brew bundle dump` - リスト出力

```bash
brew bundle dump --force --global
```

- `--force` 強制上書き
- `--global` `~/.Brewfile` に出力

### `brew bundle cleanup` - 不要パッケージ削除

```bash
brew bundle cleanup --force --global
```

### `brew bundle check` - 差分確認

```bash
brew bundle check --global
```
