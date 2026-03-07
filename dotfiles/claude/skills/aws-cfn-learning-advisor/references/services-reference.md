# AWSサービスリファレンス

## 目次
- [最重要サービス](#最重要サービス)
- [重要サービス](#重要サービス)
- [中級サービス](#中級サービス)
- [応用サービス](#応用サービス)

## 最重要サービス

### IAM (Identity and Access Management)

権限管理の基盤。全てのAWSサービスに関わる。

**リポジトリでの使用例**: `sso/`, 各`app-*/`内のタスクロール

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::IAM::Role` | サービスやユーザーに付与する役割 |
| `AWS::IAM::Policy` | 権限を定義するポリシードキュメント |
| `AWS::IAM::InstanceProfile` | EC2インスタンス用のロールラッパー |

**学習ポイント**:
- 最小権限の原則
- 信頼ポリシー（AssumeRolePolicy）vs 権限ポリシー
- サービスロール vs ユーザーロール

### EC2 / VPC

ネットワークとセキュリティの基盤。

**リポジトリでの使用例**: `vpc/`, `ecs/`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::EC2::VPC` | 仮想プライベートクラウド |
| `AWS::EC2::Subnet` | VPC内のネットワークセグメント |
| `AWS::EC2::SecurityGroup` | インバウンド/アウトバウンドルール |
| `AWS::EC2::RouteTable` | トラフィックのルーティング |
| `AWS::EC2::NatGateway` | プライベートサブネットからの外部アクセス |

**学習ポイント**:
- パブリック vs プライベートサブネット
- セキュリティグループ vs ネットワークACL
- ルートテーブルの仕組み

### ECS (Elastic Container Service)

コンテナ実行基盤。このリポジトリのアプリケーションの中核。

**リポジトリでの使用例**: `ecs/`, `app-*`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::ECS::Cluster` | コンテナを実行するクラスター |
| `AWS::ECS::TaskDefinition` | コンテナの設定（イメージ、CPU、メモリ等） |
| `AWS::ECS::Service` | タスクの起動・管理 |

**学習ポイント**:
- Fargate vs EC2起動タイプ
- タスク定義のコンテナ設定
- サービスとAuto Scaling

### S3 (Simple Storage Service)

オブジェクトストレージ。ログ保存、静的ファイル配信等。

**リポジトリでの使用例**: `log/`, `web-hosting/`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::S3::Bucket` | ストレージバケット |
| `AWS::S3::BucketPolicy` | バケットへのアクセス制御 |

**学習ポイント**:
- バケットポリシー vs IAMポリシー
- ライフサイクルルール
- 暗号化設定

## 重要サービス

### ALB (Application Load Balancer)

HTTPトラフィックの分散。

**リポジトリでの使用例**: `loadbalancer/`, `ecs/`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::ElasticLoadBalancingV2::LoadBalancer` | ロードバランサー本体 |
| `AWS::ElasticLoadBalancingV2::TargetGroup` | トラフィックの転送先 |
| `AWS::ElasticLoadBalancingV2::Listener` | ポートとプロトコルの設定 |
| `AWS::ElasticLoadBalancingV2::ListenerRule` | パスベースルーティング等 |

### CloudWatch

監視とログ管理。

**リポジトリでの使用例**: `ecs/`, `app-*`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::CloudWatch::Alarm` | メトリクスのしきい値アラーム |
| `AWS::Logs::LogGroup` | ログの保存先 |

### Route53

DNS管理。

**リポジトリでの使用例**: `ecs/`, `loadbalancer/`

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::Route53::RecordSet` | DNSレコード |
| `AWS::Route53::RecordSetGroup` | 複数レコードのグループ |

### Auto Scaling

自動スケーリング。

| リソースタイプ | 説明 |
|---------------|------|
| `AWS::ApplicationAutoScaling::ScalableTarget` | スケーリング対象 |
| `AWS::ApplicationAutoScaling::ScalingPolicy` | スケーリングポリシー |

## 中級サービス

### SSO / Identity Store

シングルサインオンとユーザー管理。

**リポジトリでの使用例**: `sso/`

### ECR (Elastic Container Registry)

Dockerイメージの保管。

### RDS (Relational Database Service)

マネージドデータベース。

**リポジトリでの使用例**: `rds/`

### Lambda

サーバーレス関数。

### EventBridge

イベント駆動アーキテクチャ。

## 応用サービス

### CloudFront
CDN（コンテンツ配信ネットワーク）。

### API Gateway
API管理とルーティング。

### WAF
Webアプリケーションファイアウォール。

### DynamoDB
NoSQLデータベース。

### Kinesis Firehose
ストリーミングデータ処理。

### Certificate Manager
SSL/TLS証明書管理。