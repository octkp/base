-- 目的: 指定した company_id の課金データを削除
-- 対象テーブル: charges, charge_items, charge_histories
-- 実行先: xba DB

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '123534757';

-------------------------------
-- クエリ実行
-------------------------------
BEGIN;

-- 1. 削除対象の確認
SELECT charge_id, charge_status, charge_type, charge_year, charge_month
FROM charges
WHERE charge_company_id = current_setting('v.company_id')::int
ORDER BY charge_year DESC, charge_month DESC;

-- 2. charge_histories を削除
DELETE FROM charge_histories
WHERE ch_charge_id IN (
    SELECT charge_id FROM charges WHERE charge_company_id = current_setting('v.company_id')::int
);

-- 3. charges を削除（charge_items は CASCADE で自動削除）
DELETE FROM charges
WHERE charge_company_id = current_setting('v.company_id')::int;

COMMIT;