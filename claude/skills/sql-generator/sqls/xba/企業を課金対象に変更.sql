-- 目的: 指定した企業を課金対象に変更する
-- 対象テーブル: companies

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '12345';  -- 課金対象にする企業ID

-------------------------------
-- 現在の状態を確認
-------------------------------
SELECT
    company_id,
    company_name,
    company_status,
    company_type,
    company_is_charge_target,
    company_charge_type,
    company_charge_start_at
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 課金対象に変更
-------------------------------
UPDATE companies
SET company_is_charge_target = 1
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 変更後の確認
-------------------------------
SELECT
    company_id,
    company_name,
    company_is_charge_target,
    company_updated_at
FROM companies
WHERE company_id = current_setting('v.company_id')::int;