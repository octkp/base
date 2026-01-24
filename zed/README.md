# zed/

Zed エディタの設定ファイル

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `settings.json` | エディタ設定（テーマ、フォント、オートセーブ） |
| `keymap.json` | キーバインド（JetBrains風） |
| `tasks.json` | タスク定義（LazyGit起動など） |

## シンボリックリンク

home-manager により以下のリンクが作成される：

```
~/.config/zed/settings.json → ~/dotfiles/zed/settings.json
~/.config/zed/keymap.json   → ~/dotfiles/zed/keymap.json
~/.config/zed/tasks.json    → ~/dotfiles/zed/tasks.json
```

## 設定を変更したとき

Zed内で変更 → 自動的にこのディレクトリに反映される
