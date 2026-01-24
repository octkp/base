#!/bin/bash
set -e

echo "=== Nix + home-manager セットアップ ==="

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# macOS チェック
if [[ "$(uname)" != "Darwin" ]]; then
    error "このスクリプトは macOS 専用です"
fi

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    info "Xcode Command Line Tools をインストール中..."
    xcode-select --install
    echo "インストール完了後、このスクリプトを再実行してください"
    exit 0
fi

# Nix チェック
if ! command -v nix &>/dev/null; then
    error "Nix がインストールされていません。先に以下のコマンドでインストールしてください:

    sh <(curl -L https://nixos.org/nix/install)

インストール後、ターミナルを再起動してからこのスクリプトを再実行してください。"
fi

# Flakes を有効化
info "Nix Flakes を有効化中..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# dotfiles ディレクトリに移動
DOTFILES_DIR="${HOME}/dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    error "dotfiles ディレクトリが見つかりません: $DOTFILES_DIR"
fi
cd "$DOTFILES_DIR"

# ユーザー名を取得
USERNAME=$(whoami)
info "ユーザー名: $USERNAME"

# 既存の設定をバックアップ
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
info "既存の設定をバックアップ中: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    if [[ -e "$1" && ! -L "$1" ]]; then
        cp -R "$1" "$BACKUP_DIR/" 2>/dev/null || true
        info "バックアップ: $1"
    fi
}

backup_if_exists ~/.zshrc
backup_if_exists ~/.config/zsh
backup_if_exists ~/.config/git
backup_if_exists ~/.gitconfig

# home-manager をインストール
info "home-manager をインストール中..."
nix run home-manager -- init --switch --flake .#${USERNAME}

info "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "1. ターミナルを再起動してください"
echo "2. 'hm-switch' で設定を更新できます"
echo ""
echo "便利なコマンド:"
echo "  hm-switch           - 設定を再ビルド（エイリアス）"
echo "  home-manager switch --flake ~/dotfiles  - 同上（フルコマンド）"
echo "  home-manager generations  - 世代一覧"
