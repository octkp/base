-- SQL No: 01
-- パターン: D-01 + B-01
-- 目的: 年払い申込後、無料期間が終了した状態を作成するための事前確認
-- 検証目的: 無料期間満了後の課金データ生成確認（初回課金のため既存データは存在しないはず）
-- 対象テーブル: invoices, charges
-- データベース: bamanager
-- 環境: cuba7
-- 注意: 初回課金パターンのため、通常は削除対象データは存在しない

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123902124';
SET v.bank_code = '0542';

-------------------------------
-- 1. 既存データの確認（初回課金のため存在しないことを確認）
-------------------------------
-- 対象のinvoicesを確認
SELECT
    *
FROM invoices
INNER JOIN companies ON companies.company_unique_code::text = invoices.company_unique_code
WHERE companies.company_origin_company_id = current_setting('v.company_id')::int
  AND invoices.bank_code = current_setting('v.bank_code')
ORDER BY invoices.id DESC;

-- 対象のchargesを確認
SELECT
    *
FROM charges
WHERE charges.charge_origin_company_id = current_setting('v.company_id')::int
  AND charges.charge_bank_code = current_setting('v.bank_code')
ORDER BY charges.charge_id DESC;
