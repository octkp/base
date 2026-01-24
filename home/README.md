# home/

home-manager の設定ファイル

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `default.nix` | エントリーポイント。シンボリックリンク、ファイル配置を定義 |
| `zsh.nix` | zsh設定（エイリアス、履歴、プラグイン、補完） |
| `git.nix` | git設定（user, credential, delta） |
| `packages.nix` | インストールするCLIパッケージ一覧 |
| `programs/fzf.nix` | fzfの詳細設定 |
| `programs/bat.nix` | batの詳細設定 |

## パッケージを追加したいとき

`packages.nix` を編集：

```nix
home.packages = with pkgs; [
  bat
  fzf
  # ↓ 追加
  htop
];
```

## エイリアスを追加したいとき

`zsh.nix` の `shellAliases` を編集：

```nix
shellAliases = {
  gs = "git status";
  # ↓ 追加
  glog = "git log --oneline";
};
```

## 設定を反映

```bash
hm-switch
```
