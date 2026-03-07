-- 目的: 指定した企業の請求書（invoices）および請求書明細（invoice_items）を確認する
-- 対象テーブル: invoices, invoice_items, companies
-- データベース: bamanager

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '127637091';
SET v.bank_code = '1280';

-------------------------------
-- 1. 請求書一覧
-------------------------------
SELECT
    invoices.id,
    invoices.charge_id,
    invoices.charge_unique_code,
    invoices.charge_date,
    invoices.invoice_date,
    invoices.bank_code,
    invoices.bank_name,
    invoices.company_unique_code,
    invoices.company_name,
    invoices.title,
    invoices.subtotal,
    invoices.tax,
    invoices.total,
    invoices.status,
    invoices.execute_at,
    invoices.created_at
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC
LIMIT 10;

-------------------------------
-- 2. 請求書明細
-------------------------------
SELECT
    invoice_items.id,
    invoice_items.invoice_id,
    invoices.charge_id,
    invoice_items.no,
    invoice_items.type,
    invoice_items.name,
    invoice_items.charge_date,
    invoice_items.quantity,
    invoice_items.unit_price,
    invoice_items.amount,
    invoice_items.subtotal,
    invoice_items.tax_rate,
    invoice_items.sales_tax,
    invoice_items.total,
    invoice_items.status,
    invoice_items.remarks
FROM invoice_items
INNER JOIN invoices ON invoices.id = invoice_items.invoice_id
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoice_items.invoice_id DESC, invoice_items.no
LIMIT 30;