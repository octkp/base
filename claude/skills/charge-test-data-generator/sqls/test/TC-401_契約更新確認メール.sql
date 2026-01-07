-- 目的: TC-401 年払い契約終了月のメール送信
-- 期待結果: 契約更新確認メールが送信される
-- 対象テーブル: companies, charges
-- 補足: 年払い契約が今月末で満了する状態

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '127637091';

-- companiesテーブル更新用
-- 年払い契約の最終月（今月末で契約満了）
SET v.charge_type = 'ANNUAL';                  -- 年払い契約中
SET v.next_charge_type = 'ANNUAL';             -- 次回も年払い
SET v.charge_amount = '33000';                 -- 年払い金額
SET v.next_charge_amount = '33000';            -- 年払い金額
SET v.charge_start_at = '2025-02-01';          -- 課金開始日 - 昨年2月
SET v.charge_period_start_date = '2025-02-01'; -- 契約期間開始日 - 昨年2月
SET v.charge_period_end_date = '2026-01-31';   -- 契約期間終了日 - 今月末（契約満了月）
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
-- 3. chargesテーブルクリア（2025年2月以降のデータを削除）
-------------------------------
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_period_start_date >= '2025-02-01';

-------------------------------
-- 4. 昨年2月の年払い課金データを作成（契約開始時）
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
    '2025-02-01',
    2025,
    2,
    '2025-02-01',
    '2026-01-31',
    33000,
    3300,
    36300,
    '2025-02-01 10:00:00'
);

-------------------------------
-- 4-2. 課金アイテムを作成（基本料金のみ）
-------------------------------
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
  AND charges.charge_month = 2;

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
-- トランザクション終了
-------------------------------
COMMIT;