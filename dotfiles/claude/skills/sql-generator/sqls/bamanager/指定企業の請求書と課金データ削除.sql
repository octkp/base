-- 目的: 指定した企業の請求書（invoices）、請求書明細（invoice_items）、課金（charges）を削除する
-- 対象テーブル: invoices, invoice_items, charges, companies
-- データベース: bamanager
-- 注意: invoice_itemsはinvoicesへのON DELETE CASCADE制約があるため、invoices削除時に自動削除される

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '127637091';
SET v.bank_code = '1280';

-------------------------------
-- 削除対象の確認（実行前に必ず確認）
-------------------------------
-- invoicesの確認
SELECT
    invoices.*
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC;

-- chargesの確認
SELECT *
FROM charges
WHERE charge_origin_company_id = current_setting('v.company_id')::int
  AND charge_bank_code = current_setting('v.bank_code');

-------------------------------
-- 削除実行
-------------------------------
-- invoicesの削除（invoice_itemsはCASCADE削除される）
DELETE FROM invoices
WHERE invoices.id IN (
    SELECT invoices.id
    FROM invoices
    INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
    WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
      AND invoices.bank_code = current_setting('v.bank_code')
);

-- chargesの削除
DELETE FROM charges
WHERE charge_origin_company_id = current_setting('v.company_id')::int
  AND charge_bank_code = current_setting('v.bank_code');