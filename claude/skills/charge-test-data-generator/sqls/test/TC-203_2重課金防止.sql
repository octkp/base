-- 目的: TC-203 2重課金防止（同月に2回バッチ実行）
-- 期待結果: 2件目の課金は作成されない
-- 対象テーブル: companies, charges
-- 補足: 既に今月の課金が存在する状態で、再度バッチを実行

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '127637091';

-- companiesテーブル更新用
-- 今月既に課金済みの状態
SET v.charge_type = 'MONTHLY';                 -- 月払い
SET v.next_charge_type = 'MONTHLY';            -- 次回も月払い
SET v.charge_amount = '3000';                  -- 月払い金額
SET v.next_charge_amount = '3000';             -- 月払い金額
SET v.charge_start_at = '2025-12-01';          -- 課金開始日 - 先月
SET v.charge_period_start_date = '2026-01-01'; -- 契約期間開始日 - 今月（既に更新済み）
SET v.charge_period_end_date = '2026-01-31';   -- 契約期間終了日 - 今月末
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
  AND charges.charge_period_start_date >= '2026-01-01';

-------------------------------
-- 4. 今月の課金データを作成（既に課金済み状態を再現）
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
    'MONTHLY',
    '2026-01-01',
    2026,
    1,
    '2026-01-01',
    '2026-01-31',
    4900,   -- 3000 + 0 + 900 + 1000
    490,    -- 300 + 0 + 90 + 100
    5390,   -- 3300 + 0 + 990 + 1100
    '2026-01-01 10:00:00'
);

-------------------------------
-- 4-2. 課金アイテムを作成
-------------------------------
-- 基本料金（月払い）: 3000 × 1 = 3000, 税額 300, 税込 3300
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
    3000,
    1,
    3000,
    10,
    300,
    3000,
    3300,
    '基本料金',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2026
  AND charges.charge_month = 1;

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
  AND charges.charge_year = 2026
  AND charges.charge_month = 1;

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
  AND charges.charge_year = 2026
  AND charges.charge_month = 1;

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
  AND charges.charge_year = 2026
  AND charges.charge_month = 1;

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
-- 6. 今月の課金が存在することを確認
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
  AND charges.charge_period_start_date = '2026-01-01'
ORDER BY charges.charge_date DESC;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;