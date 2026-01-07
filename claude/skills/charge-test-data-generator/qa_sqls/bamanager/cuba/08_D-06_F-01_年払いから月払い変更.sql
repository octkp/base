-- SQL No: 08
-- パターン: D-06 + F-01
-- 目的: 年払いから月払い変更後、月払い初回課金待ちのためのインボイスデータを削除
-- 検証目的: 課金タイプ変更後の初回月払い課金処理確認
-- 対象テーブル: invoices, invoice_items, charges
-- データベース: bamanager
-- 環境: cuba7
-- 注意: 2企業分のデータを削除（年払いON企業 + 年払いOFF企業）

-------------------------------
-- 変数設定（年払いON企業）
-------------------------------
SET v.company_id_1 = '123566220';
SET v.bank_code = '0542';

-- 変数設定（年払いOFF企業）
SET v.company_id_2 = '123573857';

-- 削除対象の期間
SET v.charge_start_at = '2025-01-01';
SET v.charge_period_start_date = '2025-01-01';
SET v.charge_period_end_date = '2025-12-31';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 削除対象の確認（年払いON企業）
-------------------------------
SELECT
    '年払いON企業' as type,
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id_1')::int
  AND invoices.bank_code = current_setting('v.bank_code')
  AND invoices.charge_date >= current_setting('v.charge_start_at')::date
ORDER BY invoices.id DESC;

SELECT
    '年払いON企業' as type,
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id_1')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

-------------------------------
-- 2. 削除対象の確認（年払いOFF企業）
-------------------------------
SELECT
    '年払いOFF企業' as type,
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id_2')::int
  AND invoices.bank_code = current_setting('v.bank_code')
  AND invoices.charge_date >= current_setting('v.charge_start_at')::date
ORDER BY invoices.id DESC;

SELECT
    '年払いOFF企業' as type,
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id_2')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

-------------------------------
-- 3. 削除実行（年払いON企業）
-------------------------------
DELETE FROM invoices
WHERE invoices.id IN (
    SELECT invoices.id
    FROM invoices
    INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
    WHERE companies.company_origin_company_id = current_setting('v.company_id_1')::int
      AND invoices.bank_code = current_setting('v.bank_code')
      AND invoices.charge_date >= current_setting('v.charge_start_at')::date
);

UPDATE charges
SET invoice_id = 0
WHERE charges.charge_origin_company_id = current_setting('v.company_id_1')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

DELETE FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id_1')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

-------------------------------
-- 4. 削除実行（年払いOFF企業）
-------------------------------
DELETE FROM invoices
WHERE invoices.id IN (
    SELECT invoices.id
    FROM invoices
    INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
    WHERE companies.company_origin_company_id = current_setting('v.company_id_2')::int
      AND invoices.bank_code = current_setting('v.bank_code')
      AND invoices.charge_date >= current_setting('v.charge_start_at')::date
);

UPDATE charges
SET invoice_id = 0
WHERE charges.charge_origin_company_id = current_setting('v.company_id_2')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

DELETE FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id_2')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
  AND charges.charge_period_start_date >= current_setting('v.charge_start_at')::date;

-------------------------------
-- 5. 実行後確認
-------------------------------
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id IN (
    current_setting('v.company_id_1')::int,
    current_setting('v.company_id_2')::int
)
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC;

SELECT
    *
FROM charges
WHERE charges.charge_origin_company_id IN (
    current_setting('v.company_id_1')::int,
    current_setting('v.company_id_2')::int
)
  AND charges.charge_bank_code = current_setting('v.bank_code')
ORDER BY charges.charge_id DESC;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;
