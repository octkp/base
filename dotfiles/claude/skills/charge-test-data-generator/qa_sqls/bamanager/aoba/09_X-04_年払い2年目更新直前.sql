-- SQL No: 09
-- パターン: X-04
-- 目的: 年払い2年目更新直前のためのインボイスデータを削除
-- 検証目的: 年払い契約更新処理確認
-- 対象テーブル: invoices, invoice_items, charges
-- データベース: bamanager
-- 環境: aoba7

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123560480';
SET v.bank_code = '0117';

-- 削除対象の期間（1年目と2年目の両方を削除）
-- 1年目: 2024-01-01〜2024-12-31
-- 2年目: 2025-01-01〜2025-12-31
SET v.charge_start_at = '2024-01-01';
SET v.charge_period_start_date = '2024-01-01';
SET v.charge_period_end_date = '2025-12-31';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 削除対象の確認
-------------------------------
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
  AND invoices.charge_date >= current_setting('v.charge_start_at')::date
  AND invoices.charge_date <= current_setting('v.charge_period_end_date')::date
ORDER BY invoices.id DESC;

SELECT
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date <= current_setting('v.charge_period_end_date')::date
  AND charges.charge_period_end_date >= current_setting('v.charge_period_start_date')::date;

-------------------------------
-- 2. 削除実行
-------------------------------
DELETE FROM invoices
WHERE invoices.id IN (
    SELECT invoices.id
    FROM invoices
    INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
    WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
      AND invoices.bank_code = current_setting('v.bank_code')
      AND invoices.charge_date >= current_setting('v.charge_start_at')::date
      AND invoices.charge_date <= current_setting('v.charge_period_end_date')::date
);

UPDATE charges
SET invoice_id = 0
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date <= current_setting('v.charge_period_end_date')::date
  AND charges.charge_period_end_date >= current_setting('v.charge_period_start_date')::date;

DELETE FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date <= current_setting('v.charge_period_end_date')::date
  AND charges.charge_period_end_date >= current_setting('v.charge_period_start_date')::date;

-------------------------------
-- 3. 実行後確認
-------------------------------
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC;

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
