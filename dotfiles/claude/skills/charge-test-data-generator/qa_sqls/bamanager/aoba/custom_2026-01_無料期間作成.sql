-- 目的: 2026年1月の課金データを削除
-- 対象テーブル: invoices, charges
-- データベース: bamanager
-- 環境: aoba7
-- 企業ID: 123694281

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123694281';
SET v.bank_code = '0117';

-- 削除対象期間（2026年1月）
SET v.delete_target_start = '2026-01-01';
SET v.delete_target_end = '2026-01-31';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 削除対象の確認
-------------------------------
-- invoices（2026年1月分）
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
  AND invoices.charge_date >= current_setting('v.delete_target_start')::date
  AND invoices.charge_date <= current_setting('v.delete_target_end')::date
ORDER BY invoices.id DESC;

-- charges（2026年1月分）
SELECT
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.delete_target_start')::date
  AND charges.charge_period_end_date <= current_setting('v.delete_target_end')::date;

-------------------------------
-- 2. 削除実行
-------------------------------
-- 2-1. invoices削除
DELETE FROM invoices
WHERE invoices.id IN (
    SELECT invoices.id
    FROM invoices
    INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
    WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
      AND invoices.bank_code = current_setting('v.bank_code')
      AND invoices.charge_date >= current_setting('v.delete_target_start')::date
      AND invoices.charge_date <= current_setting('v.delete_target_end')::date
);

-- 2-2. chargesのinvoice_idをクリア
UPDATE charges
SET invoice_id = 0
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.delete_target_start')::date
  AND charges.charge_period_end_date <= current_setting('v.delete_target_end')::date;

-- 2-3. charges削除
DELETE FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.delete_target_start')::date
  AND charges.charge_period_end_date <= current_setting('v.delete_target_end')::date;

-------------------------------
-- 3. 実行後確認
-------------------------------
-- invoices
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC;

-- charges
SELECT
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
ORDER BY charges.charge_id DESC;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;