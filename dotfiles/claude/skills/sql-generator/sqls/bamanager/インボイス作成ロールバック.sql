-- 目的: 特定の課金IDにおいて、InvoiceCommandで作成されたインボイスデータをロールバック
-- 対象テーブル: invoices, invoice_items, charges, charge_blacklists

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
-- charge_origin_charge_id（xba側のcharge_id）を指定
SET v.target_charge_id = '127637091';
-- bank_codeを指定
SET v.target_bank_code = '1280';

-------------------------------
-- 1. 確認クエリ（削除前に実行推奨）
-------------------------------
-- 対象のinvoiceデータを確認
SELECT
    i.id AS invoice_id,
    i.charge_id,
    i.charge_unique_code,
    i.charge_date,
    i.bank_code,
    i.company_name,
    i.total
FROM invoices i
WHERE i.charge_id = current_setting('v.target_charge_id')::int
  AND i.bank_code = current_setting('v.target_bank_code');

-- 対象のinvoice_itemsを確認
SELECT
    ii.id,
    ii.invoice_id,
    ii.name,
    ii.quantity,
    ii.total
FROM invoice_items ii
WHERE ii.invoice_id = (
    SELECT id FROM invoices
    WHERE charge_id = current_setting('v.target_charge_id')::int
      AND bank_code = current_setting('v.target_bank_code')
);

-- 対象のchargeを確認
SELECT
    charge_id,
    charge_origin_charge_id,
    charge_bank_code,
    invoice_id
FROM charges
WHERE charge_origin_charge_id = current_setting('v.target_charge_id')::int
  AND charge_bank_code = current_setting('v.target_bank_code');

-- 対象のcharge_blacklistsを確認
SELECT *
FROM charge_blacklists
WHERE charge_origin_charge_id = current_setting('v.target_charge_id')::int
  AND bank_code = current_setting('v.target_bank_code');

-------------------------------
-- 2. ロールバック実行
-------------------------------
BEGIN;

-- 2-1. invoice_itemsを削除（invoicesに依存しているため先に削除）
DELETE FROM invoice_items
WHERE invoice_id = (
    SELECT id FROM invoices
    WHERE charge_id = current_setting('v.target_charge_id')::int
      AND bank_code = current_setting('v.target_bank_code')
);

-- 2-2. invoicesを削除
DELETE FROM invoices
WHERE charge_id = current_setting('v.target_charge_id')::int
  AND bank_code = current_setting('v.target_bank_code');

-- 2-3. charges.invoice_idを0に戻す
UPDATE charges
SET invoice_id = 0
WHERE charge_origin_charge_id = current_setting('v.target_charge_id')::int
  AND charge_bank_code = current_setting('v.target_bank_code');

-- 2-4. charge_blacklistsを削除（該当がある場合のみ）
DELETE FROM charge_blacklists
WHERE charge_origin_charge_id = current_setting('v.target_charge_id')::int
  AND bank_code = current_setting('v.target_bank_code');

COMMIT;

-------------------------------
-- 3. 実行後確認
-------------------------------
-- invoicesが削除されたことを確認
SELECT COUNT(*) AS invoice_count
FROM invoices
WHERE charge_id = current_setting('v.target_charge_id')::int
  AND bank_code = current_setting('v.target_bank_code');

-- chargesのinvoice_idが0になったことを確認
SELECT charge_id, charge_origin_charge_id, charge_bank_code, invoice_id
FROM charges
WHERE charge_origin_charge_id = current_setting('v.target_charge_id')::int
  AND charge_bank_code = current_setting('v.target_bank_code');