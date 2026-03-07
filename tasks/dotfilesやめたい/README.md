# dotfilesやめたい

## 基本情報

| 項目 | 内容 |
|------|------|
| Issue | [octkp/dotfiles#5](https://github.com/octkp/dotfiles/issues/5) |
| ラベル | なし |
| ステータス | CLOSED |
| 担当者 | 未割当 |

## 概要

dotfilesに関係のないファイル（メモなど）もあるので、もっと汎用的にして、その中にdotfilesがある構成にしたい。
トップレベルがdotfilesだが、dotfilesは下の階層にして、トップレベルにdotfiles以外のファイルも配置したい。

## 結論/解決策

リポジトリを `~/dotfiles` から `~/base` にリネームし、設定ファイル群を `dotfiles/` サブディレクトリに集約した。

### Before
```
~/dotfiles/
├── brew/
├── claude/
├── zed/
├── zeno/
├── ...（設定ファイルがトップレベルに散在）
├── home/
├── flake.nix
└── scripts/
```

### After
```
~/base/
├── flake.nix
├── home/
├── dotfiles/          # 設定ファイルはここに集約
│   ├── brew/
│   ├── claude/
│   ├── zed/
│   ├── zeno/
│   └── ...
├── tasks/             # タスクログ（NEW）
├── note/              # メモ（NEW）
└── scripts/
```

### 主な変更ファイル

- `flake.nix` - `repoDir = "base"` パラメータ追加
- `home/default.nix` - `repoDir` を使ったシンボリックリンクパスに変更
- `home/zsh/aliases.nix` - `hm-switch`, `d` エイリアスのパス更新
- `home/zsh/functions.nix` - `brewfile-dump` のパス更新
- `home/zsh/default.nix` - `secrets.zsh` 読み込み追加
- `CLAUDE.md`, `README.md`, `Makefile`, `scripts/bootstrap.sh` - パス・説明文更新

## 関連ファイル

- `flake.nix:33` - `repoDir = "base"` の定義
- `home/default.nix:1` - `repoDir` 引数の受け取り
- `home/default.nix:28-56` - シンボリックリンク定義（全パス更新）
- `home/zsh/aliases.nix:28,33` - エイリアス定義

## 参考情報

- Nix `extraSpecialArgs` でカスタム引数をモジュールに渡すパターンを活用

## ログ

詳細は [LOG.md](./LOG.md) を参照。
