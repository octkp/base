---
summary: "次回契約期間開始日の計算では、契約終了日の翌月初日と課金開始日の両方を比較し、より未来の日付を使用する"
created: 2026-01-06
status: resolved
tags: [charge, annual-payment, contract-period]
related: [src/xba/packages/xbacore/classes/controller/api/v1/charge.php]
---

# 次回契約期間開始日の計算ロジック

## 問題

`next_charge_plan_info()` と `next_change_charge_plan_info()` で次回契約期間開始日を計算する際、`company_charge_period_end_date` の翌月初日のみを使用していた。

しかし、契約期間中でも `company_charge_start_at`（課金開始日）が未来に設定されているケースがある。この場合、次回契約期間開始日は課金開始日を使用すべき。

## 例

| 設定 | 値 |
|------|-----|
| 今日 | 2026-01-06 |
| 契約期間 | 2026-01-01 ~ 2026-01-31 |
| 課金開始日 | 2026-03-01 |

**修正前**: `next_period_start = 2026-02-01`（契約終了日の翌月初日）
**修正後**: `next_period_start = 2026-03-01`（課金開始日）

## 解決策

`calculate_next_period_start()` ヘルパーメソッドを追加:

```php
private function calculate_next_period_start(\Model_Company $company): \DateTime
{
    $next_period_start = (new \DateTime($company->company_charge_period_end_date))
        ->modify('first day of next month');

    // 課金開始日がそれより未来なら、課金開始日を使う
    if ($company->company_charge_start_at !== null) {
        $charge_start = new \DateTime($company->company_charge_start_at);
        if ($charge_start > $next_period_start) {
            $next_period_start = $charge_start;
        }
    }

    return $next_period_start;
}
```

## 関連カラム

| カラム | 用途 |
|--------|------|
| `company_charge_start_at` | 課金開始日（この日以降に課金処理が実行される） |
| `company_charge_period_start_date` | 契約期間開始日 |
| `company_charge_period_end_date` | 契約期間終了日 |

契約期間と課金開始日は独立して設定できるため、両方を考慮する必要がある。
