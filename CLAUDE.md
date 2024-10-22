# CLAUDE.md

このファイルはこのリポジトリのコード作業時にClaude Code（claude.ai/code）のガイダンスを提供します。

## リポジトリの概要

これはmacOS開発環境用のドットファイルリポジトリで、フルスタック開発（PHP/Laravel、Go、Node.js）に焦点を当てています。このリポジトリはシンボリックリンクベースのアプローチを使用して、すべての設定をバージョン管理下に置きながら、期待されるシステムロケーションに配置します。

## セットアップとインストール

**初期セットアップ：**
```bash
cd ~/dotfiles
sh initialize.zsh
```

このコマンドは全ての設定のシンボリックリンクを作成し、Brewfileをコピーします。このスクリプトはベキ等（冪等）で、何度実行しても安全です。

**Homebrewパッケージ管理：**
```bash
brewfile-dump        # 現在のパッケージをBrewfileにエクスポート
brewfile-install     # Brewfileから全パッケージをインストール
brewfile-cleanup     # Brewfileにないパッケージを削除
update-app           # 全Homebrewパッケージを更新・アップグレード
```

## アーキテクチャ

### モジュール型設定構造

このリポジトリはレイヤー化されたモジュール方式を採用しています：

- **`zshrc`** - メインエントリーポイント。Zinit、Powerlevel10k、すべてのzshモジュールをロード
- **`zsh/common.zsh`** - コアシェル設定（履歴、補完、言語: ja_JP.UTF-8）
- **`zsh/alias.zsh`** - 汎用エイリアス（`vim ~/zalias`で編集）
- **`zsh/kokopelli_alias.zsh`** - 会社固有のエイリアス（`vim ~/kalias`で編集）
- **`zsh/zinit.zsh`** - プラグインマネージャー設定
- **`zsh/fzf.zsh`** - ファジーファインダー統合とヘルパー関数
- **`zsh/f.zsh`** - インタラクティブなファイル/ディレクトリナビゲーター

### シンボリックリンク戦略

設定は`~/dotfiles`に保持され、期待されるロケーションにシンボリックリンクされます：
- `~/.config/zsh` → `~/dotfiles/zsh/`
- `~/.zshrc` → `~/dotfiles/zshrc`
- `~/.config/git` → `~/dotfiles/git/`
- `~/.config/nvim` → `~/dotfiles/nvim/`

Brewfileは**コピー**されます（シンボリックリンクではなく）。個人的な修正を許可するためです。

## 開発環境

### 言語ツール

- **PHP**: Homebrew経由。Docker開発にはLaravel Sailを使用
- **Go**: asdfで管理
- **Node.js**: 複数のバージョンマネージャー（asdf、nodebrew）
- **Python**: Python@3.11（Homebrew経由）
- **その他**: Deno、Bun

### Docker開発

ローカル開発ではDocker Composeを頻繁に使用します。主要なエイリアス：
```bash
dc         # docker compose
dcu        # docker compose up -d
dcr        # docker compose restart
dce        # docker compose exec
dcl        # docker compose logs -f
```

データベースアクセス（PostgreSQL@12）：
```bash
dc exec db psql   # DockerでPostgreSQLにアクセス
```

### テストコマンド

```bash
# PHP/Laravelテスト
sail test                    # Laravel Sailで全テストを実行
sail artisan test --coverage # カバレッジ付きで実行

# Go テスト
go test ./...               # 全テストを実行
go test -cover ./...        # カバレッジ付きで実行
```

### AWS/会社固有の文脈

`kokopelli_alias.zsh`ファイルには、Kokopelli Inc.開発用のエイリアスが含まれます：
- 異なる環境用のAWS SSOプロファイル切り替え
- BA（BigAdvance）とXBAシステムのショートカット
- データベースマイグレーションヘルパー
- 特定サービス用のDocker Composeショートカット

これらを編集する場合は、`vim ~/kalias`で編集してください。

## キーとなるインタラクティブツール

### fzf統合

fzfを活用したいくつかのインタラクティブヘルパー関数：
- **`fbr`** - ファジー検索でGitブランチを検索・切り替え
- **`fcat`** - ファジー検索でファイルを検索・batでプレビュー
- **`fv`** - ファジー検索で複数ファイルを検索・neovimで開く
- **`f`** - インタラクティブなディレクトリナビゲーター（`zsh/f.zsh`で定義）

### プラグインマネージャー

シェルとエディタの両方のプラグインマネージャーは最初の使用時に自動インストールされます：
- **Zinit**（zsh）- 不足時に自動インストール
- **Packer**（Neovim）- 初回実行時に自動ブートストラップ

## Git設定

Git設定は`git/config`にあり、以下を含みます：
- ユーザー: octkp（Kokopelli Inc.）
- エディタ: vim
- GitHub認証情報ヘルパー（`gh` CLI経由）

グローバルgitignoreパターンは`git/ignore`にあります。

## エディタ設定

Neovim設定（`nvim/init.lua`）は以下を含みます：
- LSPサポート（mason、nvim-lspconfig）
- 構文強調表示用Treesitter
- ファジーファイン用Telescope
- Git統合（fugitive、gitsigns）
- OneDarkカラースキーム

## 重要な注意事項

- これはmacOS固有の設定です（`/opt/homebrew/`パスを使用）
- 言語設定: ja_JP.UTF-8
- PostgreSQL@12がPATHに追加されています
- シェル設定への修正は、gitで追跡されるよう`~/dotfiles`ディレクトリで行ってください