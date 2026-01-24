# dotfiles

Nix + home-manager で管理するモダンな dotfiles

## 概要

```
~/dotfiles/
├── flake.nix           # Nixのエントリーポイント
├── home/               # home-manager設定
│   ├── default.nix     # ファイル配置・シンボリックリンク
│   ├── zsh.nix         # zsh設定（エイリアス、履歴、プラグイン）
│   ├── git.nix         # git設定
│   ├── packages.nix    # CLIパッケージ定義
│   └── programs/       # 個別ツール設定（fzf, bat）
├── zsh/                # カスタムスクリプト
├── zed/                # Zedエディタ設定
├── claude/             # Claude Code設定
├── brew/               # Homebrew Brewfile
├── scripts/            # セットアップスクリプト
└── Makefile            # 便利コマンド
```

## セットアップ（新しいMac）

### 1. Nix をインストール

```bash
sh <(curl -L https://nixos.org/nix/install)
```

インストール後、ターミナルを再起動。

### 2. Flakes を有効化

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. dotfiles を適用

```bash
cd ~/dotfiles
nix run home-manager -- switch --flake .#takano_y -b backup
```

これで完了！

## 日常の使い方

### 設定を変更したとき

```bash
# home/ 内の .nix ファイルを編集後
hm-switch       # エイリアス
# または
make switch
```

### パッケージを追加したいとき

`home/packages.nix` を編集：

```nix
home.packages = with pkgs; [
  bat
  fzf
  # ↓ 追加
  htop
];
```

その後 `hm-switch` を実行。

### パッケージを最新版に更新

```bash
make update     # flake.lock を更新して適用
```

### 不要なキャッシュを削除

```bash
make clean
```

### 設定を壊してしまったとき

```bash
home-manager generations        # 過去の状態を確認
home-manager switch --rollback  # 前の状態に戻す
```

## Nix と Homebrew の使い分け

| 用途 | 管理ツール | 設定ファイル |
|------|-----------|-------------|
| CLIツール（bat, fzf, neovim等） | Nix | `home/packages.nix` |
| GUIアプリ（Docker, Raycast等） | Homebrew | `brew/Brewfile` |
| PHP / Composer | Homebrew | `brew/Brewfile` |
| asdf | Homebrew | `brew/Brewfile` |

## ファイルの役割

| ファイル | 説明 |
|---------|------|
| `flake.nix` | 依存関係の定義（nixpkgs, home-manager） |
| `flake.lock` | バージョン固定（自動生成） |
| `home/default.nix` | シンボリックリンク、ファイル配置 |
| `home/zsh.nix` | zsh設定、エイリアス、プラグイン |
| `home/git.nix` | git設定（user, credential等） |
| `home/packages.nix` | インストールするCLIパッケージ |
| `home/programs/*.nix` | 個別ツールの詳細設定 |

## よく使うエイリアス

| エイリアス | コマンド |
|-----------|---------|
| `hm-switch` | `home-manager switch --flake ~/dotfiles` |
| `gs` | `git status` |
| `gps` | `git push` |
| `gpl` | `git pull` |
| `dc` | `docker compose` |
| `c` | `claude` |
| `v` | `nvim` |
| `ls` | `eza -la --icons` |

## トラブルシューティング

### `compaudit` の警告が出る

会社PCでJamf管理のファイルがある場合に発生。
`home/zsh.nix` の `completionInit` で `-u` オプションを付けて対処済み。

### Nixコマンドが見つからない

ターミナルを再起動するか、以下を実行：

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
