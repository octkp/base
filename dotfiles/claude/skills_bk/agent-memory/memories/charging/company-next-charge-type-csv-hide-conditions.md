---
summary: "CSVエクスポート時にcompany_next_charge_type（次回更新予定のプラン）を非表示にする条件と実装箇所"
created: 2026-01-08
status: resolved
tags: [csv-export, charging, company]
related: [src/bamanager/app/classes/logic/app.php, src/xba/packages/xbacore/classes/view/api/v1/company/search.php, src/xba/packages/xbacore/classes/model/company.php]
---

# 次回更新予定のプラン（company_next_charge_type）CSV非表示条件

## 実装箇所

| 場所 | ファイル | 行番号 |
|------|----------|--------|
| bamanager | src/bamanager/app/classes/logic/app.php | 607-611 |
| xba | src/xba/packages/xbacore/classes/view/api/v1/company/search.php | 106-109 |

## 非表示条件（3つのOR条件）

以下のいずれかに該当する場合、`company_next_charge_type`を空文字にする:

1. **退会予約中**: `company_unsubscribe_scheduled_at !== null`
2. **無料期間中**: `is_charge_free_period()` が true
3. **課金開始日がnull**: `company_charge_start_at === null`

```php
// xba（Model_Companyインスタンス使用）
if ($company->company_unsubscribe_scheduled_at !== null 
    || $company->is_charge_free_period() 
    || $company->company_charge_start_at === null) {
    $obj->company_next_charge_type = '';
}

// bamanager（配列使用）
$is_free_period = self::is_charge_free_period_from_array($obj);
if ($obj['company_unsubscribe_scheduled_at'] !== null 
    || $is_free_period 
    || $obj['company_charge_start_at'] === null) {
    $obj['company_next_charge_type'] = '';
}
```

## 無料期間ロジック（Model_Company::is_charge_free_period）

`src/xba/packages/xbacore/classes/model/company.php:2616-2633`

```
1. 契約期間中（start <= now <= end）→ 無料期間ではない（false）
2. 課金開始日が未来でない → 無料期間ではない（false）
3. 契約開始前 OR 契約終了後 → 無料期間（true）
```

### 注意点

- `charge_start_at === null` の場合、`is_charge_start_in_future()` が false を返すため、`is_charge_free_period()` は **false** を返す
- そのため、外側の条件で明示的に `company_charge_start_at === null` のチェックが必要

## bamanager用ヘルパーメソッド

bamanagerのCSVエクスポートでは配列データを扱うため、`is_charge_free_period_from_array()` を `Logic_App` に実装:

`src/bamanager/app/classes/logic/app.php:865-905`

このメソッドは `Model_Company::is_charge_free_period()` と同一のロジックを配列用に移植したもの。
