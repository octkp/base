# ECSタスクへのSSMパラメータ追加とデプロイ

記録日時: 2026-01-27 09:19:46

## 学んだこと

### SSMパラメータストアへの値登録

CloudFormationテンプレートで`ValueFrom`を使ってSSMパラメータを参照する場合、先にSSMパラメータストアに値を登録する必要がある。

```bash
aws ssm put-parameter \
  --profile koko \
  --name "/global/bigadvance/test1/sentry_charge_dsn" \
  --value "値" \
  --type SecureString
```

### CloudFormationの反映

`app-ba-xba/test1.sh update`で即時反映（変更セット確認なし）できる。引数なしだと変更セットのみ作成。

### ECSタスクの更新タイミング

CloudFormationでタスク定義を更新しても、既に動いているタスクは古いタスク定義のまま動き続ける。

- **ECSサービス（常時起動型）**: 強制デプロイまたは次回アプリデプロイ時に切り替わる
- **スケジュールタスク（5分バッチなど）**: 次回のスケジュール実行時に自動的に新しいタスク定義で起動される（最大5分後）

### タスク更新の確認方法（マネジメントコンソール）

1. ECS → クラスター → 対象クラスターを選択
2. タスクタブを開く
3. 「タスク定義」列のリビジョン番号を確認

5分バッチの場合: `{スタック名}-cron5min:リビジョン番号`（例: `app-xba-test1-cron5min:123`）

### 今回のファイル構成

- SSMパラメータ登録スクリプト: `scripts/register-sentry-charge-dsn-test.sh`
- CloudFormationテンプレート: `app-ba-xba/default.yml`
- デプロイスクリプト: `app-ba-xba/test1.sh`
