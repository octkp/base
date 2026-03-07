# AWS学習ガイド

## 目次
- [CloudFormationの基礎](#cloudformationの基礎)
- [推奨学習順序](#推奨学習順序)
- [テンプレート構造](#テンプレート構造)
- [組み込み関数](#組み込み関数)

## CloudFormationの基礎

CloudFormationはAWSリソースをコードで定義・管理するInfrastructure as Code (IaC) サービス。

### 基本概念

| 概念 | 説明 |
|------|------|
| Template | YAMLまたはJSONで記述されたリソース定義ファイル |
| Stack | テンプレートからデプロイされたリソースの集合 |
| Change Set | スタック更新前に変更内容を確認するためのプレビュー |
| Parameter | テンプレートに外部から渡す値 |
| Output | 他のスタックから参照できる値 |

## 推奨学習順序

### 初級（基礎を理解）

| ディレクトリ | 学べる内容 |
|-------------|-----------|
| `log/` | S3バケット作成、バケットポリシー、Glueデータベース |
| `sso/` | IAMロール、サービスロール、権限設定 |

### 中級（ネットワークとデータ）

| ディレクトリ | 学べる内容 |
|-------------|-----------|
| `vpc/` | VPC、サブネット、ルートテーブル、NAT Gateway |
| `rds/` | RDSインスタンス、パラメータグループ |
| `loadbalancer/` | ALB、ターゲットグループ、リスナー |

### 上級（アプリケーション基盤）

| ディレクトリ | 学べる内容 |
|-------------|-----------|
| `ecs/` | ECSクラスター、タスク定義、サービス、Auto Scaling |
| `app-*` | 実際のアプリケーション構成パターン |

## テンプレート構造

```yaml
AWSTemplateFormatVersion: '2010-09-09'  # 必須：バージョン指定

Parameters:                              # オプション：外部パラメータ
  Environment:
    Type: String
    Default: "test"

Conditions:                              # オプション：条件分岐
  IsProduction:
    Fn::Equals: [!Ref Environment, "production"]

Resources:                               # 必須：AWSリソース定義
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "my-bucket-${Environment}"

Outputs:                                 # オプション：出力値
  BucketName:
    Value: !Ref MyBucket
    Export:
      Name: !Sub "${AWS::StackName}-BucketName"
```

## 組み込み関数

| 関数 | 用途 | 例 |
|------|------|-----|
| `!Ref` | パラメータやリソースの参照 | `!Ref MyBucket` |
| `!Sub` | 文字列の変数置換 | `!Sub "prefix-${Environment}"` |
| `!If` | 条件分岐 | `!If [IsProduction, 365, 90]` |
| `!GetAtt` | リソース属性の取得 | `!GetAtt MyBucket.Arn` |
| `!Join` | 文字列の結合 | `!Join ["-", [a, b, c]]` |
| `!ImportValue` | 他スタックの出力値参照 | `!ImportValue VPC-ID` |
| `!Select` | リストから要素選択 | `!Select [0, !Ref MyList]` |
| `!Split` | 文字列の分割 | `!Split [",", "a,b,c"]` |

## 実践的な学習方法

1. **テンプレートを読む**: `default.yml`を読み、リソースの関係性を理解
2. **パラメータを確認**: `params/*.json`で環境差異を確認
3. **デプロイを試す**: `./deploy.sh test1 <profile>`で変更セット作成
4. **コンソールで確認**: AWSコンソールで実際のリソースを確認