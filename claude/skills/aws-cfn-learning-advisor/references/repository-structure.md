# aws-cfnリポジトリ構造

## 目次
- [ディレクトリ構成](#ディレクトリ構成)
- [サービス一覧](#サービス一覧)
- [共通ファイル](#共通ファイル)
- [デプロイの流れ](#デプロイの流れ)

## ディレクトリ構成

各サービスは以下の標準構造に従う：

```
ServiceName/
├── default.yml          # CloudFormationテンプレート（必須）
├── deploy.sh            # デプロイスクリプト（必須）
├── params/              # 環境別パラメータ（必須）
│   ├── production.json
│   └── test1-10.json
└── secrets/             # シークレット管理（オプション）
    ├── secretsmanager/
    │   ├── createsecret.sh
    │   └── secretparams.json
    └── ssm/
        ├── putparam.sh
        └── ssmparams.json
```

## サービス一覧

### インフラ基盤

| ディレクトリ | 説明 | 難易度 |
|-------------|------|--------|
| `vpc/` | VPCとサブネット | 中級 |
| `ecs/` | ECSクラスター、JumpHost | 上級 |
| `loadbalancer/` | ALB | 中級 |
| `rds/` | RDSインスタンス | 中級 |
| `log/` | ログ用S3バケット | 初級 |

### アプリケーション

| ディレクトリ | 説明 |
|-------------|------|
| `app-ba-*` | Big Advance関連アプリケーション |
| `app-ba2-*` | Big Advance v2関連 |
| `app-docs` | ドキュメント関連 |

### 管理・セキュリティ

| ディレクトリ | 説明 |
|-------------|------|
| `sso/` | AWS SSO設定 |
| `account/` | AWSアカウント設定 |
| `security-audit/` | セキュリティ監査 |

### ユーティリティ

| ディレクトリ | 説明 |
|-------------|------|
| `00.template/` | 新規サービス作成用テンプレート |
| `utility/` | 各種ユーティリティ |
| `cost-check/` | コスト監視 |

## 共通ファイル

| ファイル | 説明 |
|----------|------|
| `deploy-function.sh` | 全deploy.shで使用する共通関数 |
| `diff.py` | 既存スタックとの差分表示（VSCode連携） |
| `.cfnlintrc` | cfn-lintの設定 |
| `.pre-commit-config.yaml` | コミット時の自動Lint |

## デプロイの流れ

```
1. ./deploy.sh <環境名> <profile名>
   │
   ├─→ params/<環境名>.json を読み込み
   │
   ├─→ deploy-function.sh の関数を呼び出し
   │
   ├─→ diff.py で既存スタックとの差分を表示
   │
   └─→ aws cloudformation deploy で変更セット作成
       │
       └─→ AWSコンソールで変更セットを実行
```

### 環境一覧

| 環境名 | 用途 |
|--------|------|
| `production` | 本番環境 |
| `test1` - `test10` | テスト環境 |

### deploy.shの設定項目

```bash
STACK_NAME="xxx-$ENV"                    # スタック名
DIFF_EXECUTE="$DIR_PATH/../diff.py"      # diff.pyへのパス
FUNCTION_EXECUTE="$DIR_PATH/../deploy-function.sh"  # 共通関数
REGION="ap-northeast-1"                  # デプロイ先リージョン
```