# CLAUDE.md

このファイルはこのリポジトリのコード作業時にClaude Code（claude.ai/code）のガイダンスを提供します。

## リポジトリの概要

Nix + home-manager で管理するmacOS開発環境用の個人ベースリポジトリです。
dotfiles、タスク、ドキュメントなどを一元管理しています。
フルスタック開発（PHP/Laravel、Go、Node.js）に焦点を当てています。

## セットアップ

### 新しいMacでの初期セットアップ

```bash
# 1. Nix をインストール
sh <(curl -L https://nixos.org/nix/install)

# 2. ターミナル再起動後、Flakes を有効化
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 3. base を適用
cd ~/base
nix run home-manager -- switch --flake .#takano_y -b backup
```

### 日常的な設定変更

```bash
hm-switch              # 設定を反映（エイリアス）
make switch            # 同上（preflight チェック付き）
make update            # flake.lock更新 + 適用
make clean             # ガベージコレクション + ストア最適化
make check             # flakeチェック（適用なし）
make fmt               # Nixファイルフォーマット
make generations       # home-manager世代一覧
make bootstrap         # 初期セットアップ実行
make iterm2-save       # iTerm2設定をdotfilesに保存
make iterm2-apply      # iTerm2設定を適用
```

## アーキテクチャ

### ディレクトリ構成

```
~/base/
├── flake.nix              # Nixエントリーポイント
├── flake.lock             # バージョン固定
├── Makefile               # タスクランナー（switch, update, clean等）
├── home/                  # home-manager設定
│   ├── default.nix        # ファイル配置・シンボリックリンク（mkOutOfStoreSymlink）
│   ├── packages.nix       # CLIパッケージ定義
│   ├── git.nix            # git設定
│   ├── zsh/               # zsh設定
│   │   ├── default.nix    # メイン設定（履歴、プラグイン、キーバインド）
│   │   ├── aliases.nix    # シェルエイリアス
│   │   ├── functions.nix  # カスタム関数（fzf連携、ナビゲーション等）
│   │   └── variables.nix  # 環境変数
│   └── programs/          # 個別ツール設定
│       ├── fzf.nix
│       ├── bat.nix
│       └── starship.nix
├── dotfiles/              # 設定ファイル群（シンボリックリンクで配置）
│   ├── brew/              # Homebrew（Brewfile）
│   ├── claude/            # Claude Code設定（skills, hooks, plugins）
│   ├── ghostty/           # Ghosttyターミナル設定
│   ├── gwq/               # gwq設定
│   ├── hammerspoon/       # Hammerspoon（macOS自動化）
│   ├── iterm2/            # iTerm2設定・カラースキーム
│   ├── pgcli/             # pgcli設定
│   ├── raycast/           # Raycastスクリプト
│   ├── zed/               # Zedエディタ設定
│   ├── zeno/              # zeno.zshスニペット・補完設定
│   └── zsh/               # カスタムスクリプト（kokopelli_alias.zsh等）
├── docs/                  # ドキュメント
│   └── grade/             # 等級評価関連
├── scripts/               # セットアップスクリプト（bootstrap.sh）
├── tasks/                 # タスクログ
└── note/                  # メモ（外部リポジトリへのシンボリックリンク、.gitignore対象）
```

### Nix と Homebrew の使い分け

| 用途 | 管理ツール | 設定ファイル |
|------|-----------|-------------|
| CLIツール（bat, fzf, neovim等） | Nix | `home/packages.nix` |
| GUIアプリ（Docker, Raycast等） | Homebrew | `dotfiles/brew/Brewfile` |
| PHP / Composer / asdf | Homebrew | `dotfiles/brew/Brewfile` |

### 設定変更の流れ

1. `home/*.nix` ファイルを編集
2. `hm-switch` で適用
3. 必要に応じて `git commit`

## 開発環境

### 言語ツール

- **PHP**: Homebrew経由。Docker開発にはLaravel Sailを使用
- **Go**: asdf で管理（Nix管理のgoも併用）。GOBIN=$HOME/go/bin
- **Node.js**: Nix（nodejs_20）またはasdf
- **Python**: Nix（python311）
- **その他**: Deno、Bun（Nix管理）

### Docker開発

ローカル開発ではDocker Composeを頻繁に使用します。主要なエイリアス：
```bash
dc         # docker compose
dcu        # docker compose up -d
dcr        # docker compose rm -fsv
horobi     # docker compose down --rmi all --volumes --remove-orphans
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

### 会社固有の設定

`dotfiles/zsh/kokopelli_alias.zsh` にKokopelli Inc.開発用のエイリアスが含まれます：
- AWS SSOプロファイル切り替え
- BigAdvance/XBAシステムのショートカット
- データベースマイグレーションヘルパー

`~/.config/zsh/kokopelli_alias.zsh` にシンボリックリンクされ、zsh起動時に読み込まれます。
編集: `vim ~/kalias`（home-managerがシンボリックリンクを作成）

## よく使うエイリアス

### シェルエイリアス（aliases.nix）

| エイリアス | コマンド |
|-----------|---------|
| `hm-switch` | `home-manager switch --flake ~/base` |
| `g` | `lazygit` |
| `ga` | `git add` |
| `gb` | `git branch` |
| `gl` | `git log` |
| `gcm` | `git commit` |
| `glg` | `git log --oneline --graph --decorate` |
| `ls` | `eza -la --icons` |
| `lt` | `eza --icons --git --time-style relative -al` |
| `diff` | `colordiff` |
| `z` | `zed .` |
| `b` | `cd ~/base` |
| `load` | `exec zsh` |
| `repo` | `cd ~/ghq/github.com` |

### zenoスニペット（dotfiles/zeno/config.ts）

| スニペット | 展開後 |
|-----------|--------|
| `gs` | `git status` |
| `gps` / `gpl` | `git push` / `git pull` |
| `gc` | `git commit -m '...'` |
| `gco` | `git checkout` |
| `gd` | `git diff` |
| `gst` | `git stash` |
| `dc` | `docker compose` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcl` | `docker compose logs -f` |
| `dce` | `docker compose exec` |
| `hms` | `home-manager switch --flake ~/base` |

### zeno略語展開（abbrs）

| 略語 | 展開後 |
|------|--------|
| `v` | `nvim` |
| `g` | `git`（※ エイリアスの `lazygit` が優先） |
| `d` | `docker` |
| `k` | `kubectl` |

## カスタム関数

fzfを活用したヘルパー関数（functions.nix）：
- **`f`** - インタラクティブなファイル/ディレクトリナビゲーター
- **`fbr`** - Gitブランチをファジー検索・切り替え
- **`fcat`** - ファイルをファジー検索・batでプレビュー
- **`fv`** - 複数ファイルをファジー検索・neovimで開く
- **`r`** - ghq + gwq のリポジトリ/worktreeをfzfで選択・移動
- **`wt-add`** - gwqでworktreeを新規作成（`wt-add <branch-name>`）
- **`rd`** - bigadvance-3.0-docs/references/repos 内のリポジトリを選択・移動
- **`rdb`** - 同上 + ブランチ切り替え
- **`c`** - Claude Codeをランダムな言語キャラクターで起動
- **`brewfile-dump`** - Brewfileをdotfilesに保存

## トラブルシューティング

### 設定を壊してしまった

```bash
home-manager generations        # 過去の状態を確認
home-manager switch --rollback  # 前の状態に戻す
```

### Nixコマンドが見つからない

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

## zshプラグイン

- **zsh-autosuggestions** - コマンド入力補完
- **zsh-syntax-highlighting** - シンタックスハイライト
- **zeno.zsh** - スニペット展開・fzf補完（yuki-yano/zeno.zsh）

## 重要な注意事項

- macOS固有の設定（`/opt/homebrew/`パスを使用）
- 言語設定: ja_JP.UTF-8
- home-manager は `~/` 以下のみを管理（システムには触れない）
- シンボリックリンクは `mkOutOfStoreSymlink` で管理（`home/default.nix`）
- `~/.claude` → `dotfiles/claude/` にシンボリックリンク
- 設定変更後は `hm-switch` で反映
