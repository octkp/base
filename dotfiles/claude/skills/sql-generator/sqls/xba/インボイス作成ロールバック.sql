-- 目的: 特定の課金IDにおいて、xba.charges.invoice_idを0に戻す
-- 対象テーブル: charges
-- 注意: このSQLは対象の銀行システム（yba/xba等）のDBで実行すること

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
-- xba側のcharge_idを指定
SET v.target_charge_id = '12345';

-------------------------------
-- 1. 確認クエリ（更新前に実行推奨）
-------------------------------
SELECT
    charge_id,
    charge_unique_code,
    charge_date,
    invoice_id,
    charge_status
FROM charges
WHERE charge_id = current_setting('v.target_charge_id')::int;

-------------------------------
-- 2. ロールバック実行
-------------------------------
BEGIN;

-- xba.charges.invoice_idを0に戻す
UPDATE charges
SET invoice_id = 0
WHERE charge_id = current_setting('v.target_charge_id')::int;

COMMIT;

-------------------------------
-- 3. 実行後確認
-------------------------------
SELECT
    charge_id,
    invoice_id
FROM charges
WHERE charge_id = current_setting('v.target_charge_id')::int;