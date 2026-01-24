# zsh/

home-manager から読み込まれるカスタムスクリプト

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `f.zsh` | fzfを使ったインタラクティブファイルナビゲーター |
| `kokopelli_alias.zsh` | 会社固有のエイリアス（BigAdvance開発用） |

## 読み込み方法

`home/zsh.nix` の `initContent` 内で source される：

```nix
[[ -f ~/.config/zsh/kokopelli_alias.zsh ]] && source ~/.config/zsh/kokopelli_alias.zsh
```

## f.zsh の使い方

```bash
f   # インタラクティブナビゲーター起動
```

- ディレクトリを選択すると移動
- `..` で親ディレクトリ
- `@` で確定
- ファイルを選択すると nvim で開く
