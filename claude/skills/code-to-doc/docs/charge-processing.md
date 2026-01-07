# 課金処理 (5分毎タスク)

## 概要

5分毎に実行されるバッチタスク（`Task_5min`）内の`charge()`メソッドで、企業に対する月払い・年払いの課金データ作成と決済実行を行う。

## 関連テーブル

| テーブル名 | 用途 | 主なカラム |
|-----------|------|-----------|
| charges | 課金データ本体 | charge_id, charge_company_id, charge_status, charge_type, charge_date, charge_year, charge_month, charge_amount, charge_period_start_date, charge_period_end_date |
| charge_items | 課金明細 | ci_id, ci_charge_id, ci_type, ci_unit_price, ci_qty, ci_title, ci_is_annual |
| charge_histories | 課金実行履歴 | ch_charge_id, ch_result_code, ch_ng_notified_at |
| companies | 企業情報 | company_id, company_charge_type, company_next_charge_type, company_charge_amount, company_charge_period_start_date, company_charge_period_end_date |

## データ操作

### INSERT（作成）

#### 課金データ (charges)
- **対象テーブル**: charges
- **挿入データ**:
  - `charge_company_id`: 企業ID
  - `charge_type`: 課金タイプ（MONTHLY/ANNUAL）
  - `charge_date`: 課金作成日
  - `charge_execute_at`: 決済実行予定日時
  - `charge_year`: 対象年
  - `charge_month`: 対象月
  - `charge_env`: 実行環境
  - `charge_period_start_date`: 課金期間開始日
  - `charge_period_end_date`: 課金期間終了日
- **コード参照**: `model/charge.php:509-532`

#### 課金明細 (charge_items)
- **対象テーブル**: charge_items
- **挿入データ**:
  - `ci_charge_id`: 親課金ID
  - `ci_seq`: 明細順序
  - `ci_type`: 明細タイプ（subscription/pay_per_use）
  - `ci_unit_price`: 単価
  - `ci_qty`: 数量
  - `ci_title`: 明細タイトル
  - `ci_is_annual`: 年払い課金フラグ
- **コード参照**: `model/charge.php:535-553`

### UPDATE（更新）

#### 課金ステータス更新 (charges)
- **対象テーブル**: charges
- **更新条件**: charge_id で特定
- **更新内容**:
  - `charge_status`: OK/NG/NG_UNKNOWN など
  - `charge_ng_message`: エラーメッセージ（NG時）
  - `charge_amount`: 合計金額
  - `charge_tax_amount`: 税額
- **コード参照**: `model/charge.php:169-222`, `model/charge.php:952-983`

#### 課金履歴NG通知更新 (charge_histories)
- **対象テーブル**: charge_histories
- **更新条件**: ch_result_code <> 'OK' AND ch_ng_notified_at IS NULL
- **更新内容**:
  - `ch_ng_notified_at`: 通知日時（now()）
- **コード参照**: `model/charge.php:118-136`

#### 企業の契約プラン更新 (companies)
- **対象テーブル**: companies
- **更新条件**: company_id で特定
- **更新内容**:
  - `company_charge_type`: 現在の契約タイプ
  - `company_charge_amount`: 課金金額
  - `company_charge_period_start_date`: 課金期間開始日
  - `company_charge_period_end_date`: 課金期間終了日
  - `company_next_charge_type`: 次回契約タイプ（月払い移行時）
  - `company_next_charge_amount`: 次回課金金額
- **コード参照**: `model/company.php:2533-2556`

### DELETE（削除）

#### オプション課金（0件時）
- **対象テーブル**: charges
- **削除条件**: オプション課金アイテムが0件の場合
- **コード参照**: `model/charge.php:844-846`

## 処理フロー

### 1. NG通知作成 (`create_ng_notice`)
1. charge_historiesから未通知のNGレコードを取得
2. 各レコードの`ch_ng_notified_at`を更新

### 2. 年払い企業の月払い移行（年払い機能OFF時）
1. 年払い機能がOFFかチェック
2. 契約満了した年払い企業を検索
3. 該当企業を月払いに更新

### 3. 月払い課金作成 (`create_this_month_charges`)
1. 課金期間を計算（当月1日〜末日）
2. 課金対象企業を取得（company_next_charge_type = 'MONTHLY'）
3. 各企業に対して:
   - chargesレコード作成
   - 基本課金のcharge_items作成
   - オプション課金（ビジネスユーザー従量、ちゃんと請求書）作成
   - 金額計算・更新
   - 企業の契約プラン情報を更新

### 4. 年払い課金作成 (`create_this_annual_charges`)
1. 課金期間を計算（当月1日〜翌年前月末日：12ヶ月分）
2. 課金対象企業を取得（company_next_charge_type = 'ANNUAL'）
3. 各企業に対して:
   - chargesレコード作成
   - 基本課金のcharge_items作成（ci_is_annual = true）
   - オプション課金作成
   - 金額計算・更新
   - 企業の契約プラン情報を更新

### 5. 月次オプション課金作成 (`create_this_monthly_option_charges`)
1. 年払い契約中の企業を取得（今月が年払い初月でない企業）
2. 各企業に対して:
   - オプション用chargesレコード作成
   - オプション課金のcharge_items作成
   - アイテム0件なら課金データ削除

### 6. 課金実行 (`execute_charges`)
1. 実行対象課金を取得（execute_at <= 現在時刻）
2. 各課金に対して:
   - 0円の場合 → STATUS_OK
   - マイナス金額 → STATUS_NG
   - クレジットカード未登録 → STATUS_NG
   - カード決済実行
3. NGがあれば通知イベント発火

## 課金タイプ

| タイプ | 定数 | 説明 |
|--------|------|------|
| 月払い | MONTHLY | 毎月課金、期間は1ヶ月 |
| 年払い | ANNUAL | 年間一括課金、期間は12ヶ月 |

## 課金ステータス

| ステータス | 説明 |
|-----------|------|
| PROGRESS | 処理中 |
| RETRYING | リトライ中 |
| EXECUTING | 実行中 |
| OK | 決済完了 |
| NG | 決済失敗 |
| NG_UNKNOWN | 不明なエラー |
| - (CANCEL) | キャンセル |

## 課金明細タイプ

| タイプ | 定数 | 説明 |
|--------|------|------|
| subscription | TYPE_SUBSCRIPTION | 基本料金（月額/年額） |
| pay_per_use | TYPE_PAY_PER_USE | 従量課金（ビジネスユーザー等） |
| adjust | TYPE_ADJUST | 調整 |

## 注意点・補足

- トランザクション管理: 各課金作成処理はsavepointを使用して部分ロールバック可能
- 年払い機能フラグ: `Model_Charge::is_annual_charge_enable()`で有効/無効を判定
- ちゃんと請求書連携: BA Payment APIから課金対象企業リストを取得して金額を上書き
- 重複課金防止: 課金期間の重複チェックで既存課金との重複を防止
- 退会予約考慮: 退会予約日が未来の企業のみ課金対象