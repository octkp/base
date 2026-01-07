-- 目的: TC-102 年払い2ヶ月目のオプション課金のみ作成
-- 期待結果: オプション課金のみ作成、プラン料金は含まれない
-- 対象テーブル: companies, charges

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '127637091';

-- companiesテーブル更新用
-- 年払い契約中の2ヶ月目（契約期間の途中）
SET v.charge_type = 'ANNUAL';                  -- 年払い契約中
SET v.next_charge_type = 'ANNUAL';             -- 次回も年払い
SET v.charge_amount = '33000';                 -- 年払い金額
SET v.next_charge_amount = '33000';            -- 年払い金額
SET v.charge_start_at = '2025-12-01';          -- 課金開始日 - 先月（年払い開始月）
SET v.charge_period_start_date = '2025-12-01'; -- 契約期間開始日
SET v.charge_period_end_date = '2026-11-30';   -- 契約期間終了日（+11ヶ月末）
SET v.is_charge_target = '1';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
SELECT
    company_id,
    company_name,
    company_charge_type,
    company_next_charge_type,
    company_charge_amount,
    company_next_charge_amount,
    company_charge_start_at,
    company_charge_period_start_date,
    company_charge_period_end_date,
    company_is_charge_target
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. charge_historiesテーブルクリア（先に削除）
-------------------------------
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
);

-------------------------------
-- 3. chargesテーブルクリア（今月以降のデータを削除）
-------------------------------
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_period_start_date >= '2025-12-01';

-------------------------------
-- 4. 先月の年払い課金データを作成（初月）
-------------------------------
INSERT INTO charges (
    charge_company_id,
    charge_env,
    charge_status,
    charge_type,
    charge_date,
    charge_year,
    charge_month,
    charge_period_start_date,
    charge_period_end_date,
    charge_amount_excluding_tax,
    charge_tax_amount,
    charge_amount,
    charge_execute_at
) VALUES (
    current_setting('v.company_id')::int,
    'test7',
    'OK',
    'ANNUAL',
    '2025-12-01',
    2025,
    12,
    '2025-12-01',
    '2026-11-30',
    34900,  -- 33000 + 0 + 900 + 1000
    3490,   -- 3300 + 0 + 90 + 100
    38390,  -- 36300 + 0 + 990 + 1100
    '2025-12-01 10:00:00'
);

-------------------------------
-- 4-2. 課金アイテムを作成
-------------------------------
-- 基本料金（年払い）: 33000 × 1 = 33000, 税額 3300, 税込 36300
INSERT INTO charge_items (
    ci_charge_id,
    ci_seq,
    ci_type,
    ci_unit_price,
    ci_qty,
    ci_subtotal,
    ci_tax_rate,
    ci_tax_amount,
    ci_subtotal_excluding_tax,
    ci_subtotal_including_tax,
    ci_title,
    ci_is_annual
)
SELECT
    charges.charge_id,
    0,
    'subscription',
    33000,
    1,
    33000,
    10,
    3300,
    33000,
    36300,
    '基本料金',
    true
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

-- ビジネスユーザー無料枠: 0 × 5 = 0, 税額 0, 税込 0
INSERT INTO charge_items (
    ci_charge_id,
    ci_seq,
    ci_type,
    ci_unit_price,
    ci_qty,
    ci_subtotal,
    ci_tax_rate,
    ci_tax_amount,
    ci_subtotal_excluding_tax,
    ci_subtotal_including_tax,
    ci_title,
    ci_is_annual
)
SELECT
    charges.charge_id,
    1,
    'pay_per_use',
    0,
    5,
    0,
    10,
    0,
    0,
    0,
    'ビジネスユーザー無料枠',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

-- ビジネスユーザー有料枠: 300 × 3 = 900, 税額 90, 税込 990
INSERT INTO charge_items (
    ci_charge_id,
    ci_seq,
    ci_type,
    ci_unit_price,
    ci_qty,
    ci_subtotal,
    ci_tax_rate,
    ci_tax_amount,
    ci_subtotal_excluding_tax,
    ci_subtotal_including_tax,
    ci_title,
    ci_is_annual
)
SELECT
    charges.charge_id,
    2,
    'pay_per_use',
    300,
    3,
    900,
    10,
    90,
    900,
    990,
    'ビジネスユーザー',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

-- ちゃんと請求書: 1000 × 1 = 1000, 税額 100, 税込 1100
INSERT INTO charge_items (
    ci_charge_id,
    ci_seq,
    ci_type,
    ci_unit_price,
    ci_qty,
    ci_subtotal,
    ci_tax_rate,
    ci_tax_amount,
    ci_subtotal_excluding_tax,
    ci_subtotal_including_tax,
    ci_title,
    ci_is_annual
)
SELECT
    charges.charge_id,
    3,
    'subscription',
    1000,
    1,
    1000,
    10,
    100,
    1000,
    1100,
    'ちゃんと請求書',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

-------------------------------
-- 5. テストデータ更新
-------------------------------
UPDATE companies
SET
    company_charge_type = current_setting('v.charge_type'),
    company_next_charge_type = current_setting('v.next_charge_type'),
    company_charge_amount = current_setting('v.charge_amount')::int,
    company_next_charge_amount = current_setting('v.next_charge_amount')::int,
    company_charge_start_at = current_setting('v.charge_start_at')::date,
    company_charge_period_start_date = current_setting('v.charge_period_start_date')::date,
    company_charge_period_end_date = current_setting('v.charge_period_end_date')::date,
    company_is_charge_target = current_setting('v.is_charge_target')::int
WHERE company_id = current_setting('v.company_id')::int
RETURNING
    company_id,
    company_name,
    company_charge_type,
    company_next_charge_type,
    company_charge_amount,
    company_next_charge_amount,
    company_charge_start_at,
    company_charge_period_start_date,
    company_charge_period_end_date,
    company_is_charge_target;

-------------------------------
-- 6. 作成した課金データを確認
-------------------------------
SELECT
    charges.charge_id,
    charges.charge_company_id,
    charges.charge_status,
    charges.charge_type,
    charges.charge_date,
    charges.charge_year,
    charges.charge_month,
    charges.charge_period_start_date,
    charges.charge_period_end_date,
    charges.charge_tax_amount,
    charges.charge_amount
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charges.charge_date DESC
LIMIT 5;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;