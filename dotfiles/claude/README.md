# claude/

Claude Code の設定とスキル

## ディレクトリ構成

| パス | 説明 |
|------|------|
| `settings.json` | Claude Code の設定 |
| `skills/` | カスタムスキル定義 |
| `hooks/` | フック（コマンド実行時の処理） |
| `plans/` | 実行計画 |
| `projects/` | プロジェクト別の会話履歴 |

## シンボリックリンク

home-manager により以下のリンクが作成される：

```
~/.claude → ~/base/dotfiles/claude
```

## スキル一覧

- `sql-generator` - SQLクエリ生成
- `migration-rollback` - マイグレーションロールバック
- `charge-test-data-generator` - 課金テストデータ生成
- その他多数
