# AWS CloudFormation基礎

記録日時: 2026-01-18 15:25:00

## 学んだこと

### 1. aws-cfnリポジトリの基本構造

```
ServiceName/
├── default.yml    ← CloudFormationテンプレート本体
├── deploy.sh      ← デプロイスクリプト
└── params/        ← 環境別パラメータ（production.json, test1.jsonなど）
```

### 2. deploy.shの役割

- インフラ担当エンジニアが使用
- リソース作成・設定変更時に実行
- 実行方法: `./deploy.sh <環境名> <profile名>`

### 3. 変更セット（Change Set）が重要

- `--no-execute-changeset`オプションで変更セットを作成のみ行う
- 実際の実行は人間がAWSコンソールで確認してから行う
- **ベストプラクティス**: 常に変更セットを使う（安全装置）

### 4. CloudFormationテンプレートの基本構造

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Parameters:      # 外部から渡す値
Conditions:      # 条件分岐
Resources:       # AWSリソース定義
Outputs:         # 他スタックから参照できる値
```

### 5. 基本的な組み込み関数

| 関数 | 用途 |
|------|------|
| `!Ref` | パラメータ/リソース参照 |
| `!Sub` | 文字列の変数置換 |
| `!If` | 条件分岐 |

### 6. 最も基礎的なサービス

1. **S3** - `log/default.yml`が最もシンプルな学習教材
2. **IAM** - 権限管理の基盤
3. **CloudWatch Logs** - ログ管理

### 7. マネコンでの確認

CloudFormation → スタック → `log-<環境名>`で検索