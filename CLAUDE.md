# CLAUDE.md

このファイルはこのリポジトリのコード作業時にClaude Code（claude.ai/code）のガイダンスを提供します。

## リポジトリの概要

Nix + home-manager で管理するmacOS開発環境用のドットファイルリポジトリです。
フルスタック開発（PHP/Laravel、Go、Node.js）に焦点を当てています。

## セットアップ

### 新しいMacでの初期セットアップ

```bash
# 1. Nix をインストール
sh <(curl -L https://nixos.org/nix/install)

# 2. ターミナル再起動後、Flakes を有効化
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 3. dotfiles を適用
cd ~/dotfiles
nix run home-manager -- switch --flake .#takano_y -b backup
```

### 日常的な設定変更

```bash
hm-switch              # 設定を反映（エイリアス）
make switch            # 同上
make update            # パッケージを最新版に更新
make clean             # 不要なキャッシュを削除
```

## アーキテクチャ

### ディレクトリ構成

```
~/dotfiles/
├── flake.nix              # Nixエントリーポイント
├── flake.lock             # バージョン固定
├── home/                  # home-manager設定
│   ├── default.nix        # ファイル配置・シンボリックリンク
│   ├── zsh.nix            # zsh設定（エイリアス、履歴、プラグイン）
│   ├── git.nix            # git設定
│   ├── packages.nix       # CLIパッケージ定義
│   └── programs/          # 個別ツール設定（fzf, bat）
├── zsh/                   # カスタムスクリプト
│   ├── f.zsh              # インタラクティブナビゲーター
│   └── kokopelli_alias.zsh # 会社固有エイリアス
├── zed/                   # Zedエディタ設定
├── brew/                  # Homebrew（GUIアプリ用）
├── claude/                # Claude Code設定
└── scripts/               # セットアップスクリプト
```

### Nix と Homebrew の使い分け

| 用途 | 管理ツール | 設定ファイル |
|------|-----------|-------------|
| CLIツール（bat, fzf, neovim等） | Nix | `home/packages.nix` |
| GUIアプリ（Docker, Raycast等） | Homebrew | `brew/Brewfile` |
| PHP / Composer / asdf | Homebrew | `brew/Brewfile` |

### 設定変更の流れ

1. `home/*.nix` ファイルを編集
2. `hm-switch` で適用
3. 必要に応じて `git commit`

## 開発環境

### 言語ツール

- **PHP**: Homebrew経由。Docker開発にはLaravel Sailを使用
- **Go**: asdfで管理（Nix管理のgoも併用可）
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

`zsh/kokopelli_alias.zsh` にKokopelli Inc.開発用のエイリアスが含まれます：
- AWS SSOプロファイル切り替え
- BigAdvance/XBAシステムのショートカット
- データベースマイグレーションヘルパー

編集: `vim ~/kalias`

## よく使うエイリアス

| エイリアス | コマンド |
|-----------|---------|
| `hm-switch` | `home-manager switch --flake ~/dotfiles` |
| `gs` | `git status` |
| `gps` / `gpl` | `git push` / `git pull` |
| `dc` | `docker compose` |
| `c` | `claude` |
| `v` | `nvim` |
| `ls` | `eza -la --icons` |
| `f` | インタラクティブナビゲーター |

## fzf統合

fzfを活用したヘルパー関数：
- **`fbr`** - Gitブランチをファジー検索・切り替え
- **`fcat`** - ファイルをファジー検索・batでプレビュー
- **`fv`** - 複数ファイルをファジー検索・neovimで開く
- **`f`** - インタラクティブなディレクトリナビゲーター

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

## 重要な注意事項

- macOS固有の設定（`/opt/homebrew/`パスを使用）
- 言語設定: ja_JP.UTF-8
- home-manager は `~/` 以下のみを管理（システムには触れない）
- 設定変更後は `hm-switch` で反映
