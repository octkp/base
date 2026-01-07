---
summary: "課金情報更新のルール: 無料期間中/契約期間中で更新可能な項目が異なる"
created: 2026-01-06
updated: 2026-01-06
status: resolved
tags: [charge, contract-period, free-period]
related: [src/xba/packages/xbacore/classes/controller/api/v1/company/charge.php, src/xba/packages/xbacore/classes/model/company.php]
---

# 課金情報更新のルール

## 更新可否マトリクス

| 項目 | 無料期間中 | 契約期間中 |
|------|-----------|-----------|
| 課金開始日 | ✅ 変更可 | ✅ 変更可 |
| **現在の**課金金額 | ✅ 変更可 | ❌ |
| **現在の**契約プラン種類 | ❌ 変更不可 | ❌ |
| **現在の**契約期間 | ✅ 更新される | ❌ 絶対に変更しない |
| **次回の**課金金額 | ✅ 変更可 | ✅ 変更可 |
| **次回の**契約プラン種類 | ✅ 変更可 | ✅ 変更可 |

## 重要なポイント

1. **契約期間中の契約期間は絶対に変更しない**
   - 契約期間中でも課金開始日の変更は可能だが、契約期間は更新しない
   - これは意図的な仕様であり、バグではない

2. **契約プランの種類（company_charge_type）は無料期間中でも変更不可**

3. **次回の契約情報は常に変更可能**
   - `company_next_charge_amount`: 次回課金金額
   - `company_next_charge_type`: 次回契約プラン種類

## 関連カラム

| カラム | 説明 |
|--------|------|
| `company_charge_amount` | 現在の課金金額 |
| `company_charge_type` | 現在の契約プラン種類 |
| `company_charge_period_start_date` | 現在の契約期間開始日 |
| `company_charge_period_end_date` | 現在の契約期間終了日 |
| `company_next_charge_amount` | 次回の課金金額 |
| `company_next_charge_type` | 次回の契約プラン種類 |
| `company_charge_start_at` | 課金開始日 |

## 実装コミット

**コミット**: `de7336084`
**ブランチ**: `BAX-10325`

### 変更ファイル

1. `model/company.php`
   - `calculate_next_charge_period_start()`: 次回課金開始日を計算
   - `calculate_charge_period_end()`: 契約期間終了日を計算
   - `update_charge_info_for_free_period()`: 無料期間中の課金情報更新

2. `controller/api/v1/charge.php`
   - Model_Companyのメソッドを使用するようにリファクタリング

3. `controller/api/v1/company/charge.php`
   - 無料期間中の契約期間更新ロジック追加

### 実装した要件

1. 課金開始日が変更されたタイミングで契約期間も最新化する（無料期間中のみ）
2. 次回課金期間の計算を課金開始日ベースにする
3. 次回課金金額を更新した際、無料期間であれば現在の課金金額も更新する

## 無料期間の発生ケース

| ケース | 契約期間 | 無料期間判定 | 処理内容 |
|--------|----------|-------------|----------|
| 初めての契約（課金未発生） | null | `is_before_contract_start()` → true | 契約期間を**新規設定** |
| 一度課金後、課金開始日を未来に変更 | 存在する | `is_after_contract_end()` → true | 契約期間を**更新** |

両方のケースで `is_charge_free_period()` が true になり、`update_charge_info_for_free_period()` が実行される。
初めての契約の場合は「更新」というより「初期設定」だが、コード上は同じ処理で対応可能。
