# iTerm2 設定管理

## 設定を適用（新しいMacで）

```bash
# iTerm2を閉じた状態で実行
cp ~/base/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/
defaults read com.googlecode.iterm2
```

## 設定を保存（設定変更後）

```bash
# iTerm2を閉じた状態で実行
plutil -convert xml1 ~/Library/Preferences/com.googlecode.iterm2.plist -o ~/base/dotfiles/iterm2/com.googlecode.iterm2.plist
```

または `make iterm2-save` を使用
