-- 目的: 指定した企業の課金情報を確認する
-- 対象テーブル: companies, charges, charge_items

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '127637091';

-------------------------------
-- 1. 企業の課金設定
-------------------------------
SELECT
    company_name,
    company_charge_type,
    company_next_charge_type,
    company_charge_amount,
    company_next_charge_amount,
    company_charge_start_at,
    company_charge_period_start_date,
    company_charge_period_end_date,
    company_is_charge_target,
    company_unsubscribe_scheduled_at
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. 課金データ一覧
-------------------------------
SELECT
    charge_id,
    charge_status,
    charge_type,
    charge_date,
    charge_year,
    charge_month,
    charge_amount,
    charge_tax_amount,
    charge_period_start_date,
    charge_period_end_date,
    charge_execute_at,
    charge_fail_count
FROM charges
WHERE charge_company_id = current_setting('v.company_id')::int
ORDER BY charge_id DESC
LIMIT 10;

-------------------------------
-- 3. 課金明細（charge_items）
-------------------------------
SELECT
    charge_items.ci_id,
    charge_items.ci_charge_id,
    charge_items.ci_seq,
    charge_items.ci_type,
    charge_items.ci_title,
    charge_items.ci_unit_price,
    charge_items.ci_qty,
    charge_items.ci_unit_price * charge_items.ci_qty,
    charge_items.ci_is_annual
FROM charge_items
INNER JOIN charges ON charges.charge_id = charge_items.ci_charge_id
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charge_items.ci_charge_id DESC, charge_items.ci_seq, charge_items.ci_id
LIMIT 30;