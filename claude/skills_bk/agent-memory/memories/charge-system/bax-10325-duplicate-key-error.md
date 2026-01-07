---
summary: "BAX-10325: 年払い課金作成時のduplicate keyエラー - QA用特殊データを考慮した修正が原因で発生、charge_type絞りを削除して解決"
created: 2026-01-15
status: resolved
tags: [charge, annual-charge, duplicate-key, qa-pitfall]
related: [src/xba/packages/xbacore/classes/model/charge.php]
---

# BAX-10325: 年払い課金のduplicate keyエラー問題

## 発生した問題
- 2026-01-15 18:39:44 に年払い課金作成時にduplicate keyエラーが発生
- `charges_charge_company_id_charge_year_charge_month_key` 制約違反
- company_id=123529190, year=2026, month=1 が既に存在

## 時系列

### 本番で起きたこと
1. **12:44:43** - 2026年1月の月払い課金が作成・成功（charge_status: OK）
2. **12:44〜18:39の間** - ユーザーがプラン変更API（POST /api/v1/charge/change_plan）で年払いに変更
   - `company_next_charge_type` が 'MONTHLY' → 'ANNUAL' に変更
3. **18:39:44** - 5分バッチ（Task_5min->charge）で年払い課金を作成しようとしてエラー発生

### なぜエラーになったか
- `get_charge_target` の除外条件で `->where('charge_type', $charge_type)` があった
- これにより「同じcharge_typeで期間重複する課金」しかチェックしてなかった
- 月払い課金（MONTHLY）があっても、年払い課金（ANNUAL）を作ろうとしてしまった
- DBのユニーク制約は `(charge_company_id, charge_year, charge_month)` でcharge_typeは含まれない

## 根本原因: なぜcharge_type絞りが入っていたか

### 過去のQAでの出来事
過去に以下のようなつぶやきが残っていた：

> 2025-01-01 ~ 2026-01-13の年払い課金と2026-01-01 ~ 2026-01-31の月払い課金が同時に存在する。
> このとき、2026-01-14になったらどうなるか
> 現状、期間内の課金を一つでも持っているならば課金対象外となるので、上記のケースでは取得できない
> charge_typeで絞らないとだめだな。。

### 何が間違いだったか
- **QA用の特殊データ**（期間終了日が2026-01-13など月末でない）を考慮して修正を入れた
- しかし、本来のビジネスロジックでは課金期間は**必ず月初〜月末**
- 特殊パターンは本番では起こり得ない（DBを直接いじったテストデータ）

## 本来のビジネスロジック

### 課金期間の定義（コードで保証）
```php
// calculate_monthly_charge_period
'period_start' => $first_day_of_this_month->format('Y-m-d'),  // 必ず1日
'period_end' => ->modify('last day of this month')->format('Y-m-d'),  // 必ず月末

// calculate_annual_charge_period
'period_start' => $first_day_of_this_month->format('Y-m-d'),  // 必ず1日
'period_end' => ->modify('+11 months')->modify('last day of this month')->format('Y-m-d'),  // 必ず月末
```

### 期間重複チェックだけで十分
```php
->where('company_id', 'not in',
    \DB::select('charge_company_id')
        ->from('charges')
        ->where('charge_period_start_date', '<=', $period_end)
        ->where('charge_period_end_date', '>=', $period_start)
)
```

- 月払い課金: 2026-01-01 ~ 2026-01-31
- 年払い課金: 2026-01-01 ~ 2026-12-31
- どちらも「2026年1月」を含むので期間重複 → 片方あればもう片方は作れない
- **charge_typeで絞る必要がなかった**

## 最終的な修正

### Before（問題のあるコード）
```php
->where('company_id', 'not in',
    \DB::select('charge_company_id')
        ->from('charges')
        ->where('charge_type', $charge_type)  // ← これが問題
        ->where('charge_period_start_date', '<=', $period_end)
        ->where('charge_period_end_date', '>=', $period_start)
)
```

### After（修正後）
```php
->where('company_id', 'not in',
    \DB::select('charge_company_id')
        ->from('charges')
        // charge_typeで絞らない - 期間重複チェックだけで十分
        ->where('charge_period_start_date', '<=', $period_end)
        ->where('charge_period_end_date', '>=', $period_start)
)
```

## 教訓

1. **QA用の特殊データパターンを考慮した修正を本番ロジックに入れてしまった**
   - テストデータは本番で起こり得るパターンに限定すべき

2. **本来のビジネスロジックを理解していれば不要な修正だった**
   - 課金期間は必ず月初〜月末という制約を理解していれば、charge_type絞りは不要と判断できた

3. **DBの制約とアプリケーションロジックの整合性を確認すべき**
   - DBのユニーク制約は `(company_id, year, month)` でcharge_typeは含まれない
   - アプリケーションの除外ロジックもそれに合わせるべきだった

4. **5分バッチの影響範囲を考慮**
   - プラン変更直後に5分バッチが走ると問題が発生
   - 「プラン変更 → 次の5分バッチ」の間にエラーになる可能性があった