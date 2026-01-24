# scripts/

セットアップ用スクリプト

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `bootstrap.sh` | 新しいMac用の初期セットアップスクリプト |

## bootstrap.sh

新しいMacで環境を構築するためのスクリプト。

### 前提条件

- Nix がインストール済み
- Flakes が有効化済み

### 実行方法

```bash
cd ~/dotfiles
./scripts/bootstrap.sh
```

### 処理内容

1. Xcode Command Line Tools の確認
2. Nix のインストール確認
3. Flakes の有効化
4. 既存設定のバックアップ
5. home-manager の適用
