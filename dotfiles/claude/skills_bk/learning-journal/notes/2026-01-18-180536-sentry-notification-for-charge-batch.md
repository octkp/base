# 課金バッチ処理へのSentry通知実装

記録日時: 2026-01-18 18:05:36

## 学んだこと

### 1. Sentry通知の実装パターン

ba-fukuriリポジトリの`SentrySyncNotifier`を参考にした実装パターン：

```php
\Sentry\withScope(function (\Sentry\State\Scope $scope) use (...): void {
    $scope->setTag('type', 'batch');
    $scope->setTag('batch.name', 'charge-create');
    $scope->setFingerprint(['charge', $charge_type, $status]);
    $scope->setContext('extra', [...]);
    $scope->setLevel(\Sentry\Severity::info());
    \Sentry\captureMessage($message);
});
```

**ポイント:**
- `withScope`でスコープを分離して他の通知に影響を与えない
- `setTag`でフィルタリング・アラート条件に使用
- `setFingerprint`で同種のイベントをグループ化
- `setContext`で詳細情報を付加

### 2. mk1フレームワークのSentry設定

```php
// mk1/core/config/sentry.php
'enable' => (strlen(getenv('SENTRY_DSN')) > 0),
'dsn'    => getenv('SENTRY_DSN'),
```

- `SENTRY_DSN`環境変数が設定されていればSentryが有効化
- ErrorHandlerに自動登録され、例外は自動的にSentryに送信される

### 3. aws-cfnでの環境変数設定パターン

#### 個別パターン（銀行ごと）
```yaml
- Name: SENTRY_DSN_DATA_TRANSFER
  ValueFrom: !Sub "/${AWS::StackName}/sentry_dsn_data_transfer"
```
→ `/ktba-production/sentry_dsn_data_transfer` のように銀行・環境ごとに設定

#### 共通パターン（全銀行共通）
```yaml
- Name: SENTRY_DSN
  ValueFrom: !Sub "/global/bigadvance/${MkENV}/sentry_dsn"
```
→ `/global/bigadvance/production/sentry_dsn` のように環境ごとに1つ

**共通パターンのメリット:**
- SSM Parameter登録が環境ごとに1回で済む
- 銀行の区別はSentryのタグ（`system_code`）で識別可能

### 4. default.yml vs default-for-ba-dev-migration.yml

| ファイル | 用途 |
|---------|------|
| `default.yml` | 通常デプロイ用 |
| `default-for-ba-dev-migration.yml` | ba-dev環境の移行用（スタック名がパラメータ化） |

主な違い:
- Route53/S3参照がハードコード vs パラメータ化
- TLSバージョン（2021 vs 2018）
- Cbbaリダイレクトルールの有無

### 5. Slack連携の設定

Sentry → Slack連携はSentry側で設定：
1. Project Settings → Integrations → Slack
2. Alert Rulesでタグ条件を設定（例: `batch.name = charge-create`）
3. 通知先Slackチャンネルを指定

## 変更したファイル

### bigadvanceリポジトリ
- `src/xba/packages/xbacore/classes/task/5min.php` - `notify_charge_to_sentry()`メソッド追加
- `src/xba/packages/xbacore/classes/model/company.php` - 戻り値を`int`に変更

### aws-cfnリポジトリ
- `app-ba-xba/default.yml` - `SENTRY_DSN`環境変数追加
- `app-ba-xba/default-for-ba-dev-migration.yml` - 同上

## デプロイ前に必要な作業

1. Sentryでプロジェクト作成、DSN取得
2. SSM Parameter Storeに登録:
   ```bash
   aws ssm put-parameter \
     --name "/global/bigadvance/test1/sentry_dsn" \
     --value "https://xxx@xxx.ingest.sentry.io/xxx" \
     --type SecureString
   ```
3. aws-cfnをデプロイ
4. SentryでSlack連携設定