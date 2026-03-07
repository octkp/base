-- 目的: 指定した課金ID（charge_id）に関連するデータをロールバック（削除）する
-- 対象テーブル: charges, charge_items, charge_histories
--
-- 注意事項:
--   1. companiesテーブルの更新（company_charge_type, company_charge_amount,
--      company_charge_period_start_date, company_charge_period_end_date）は
--      履歴がないため自動ロールバック不可。必要に応じて手動で復元してください。
--   2. charge_items は charges に ON DELETE CASCADE が設定されているため、
--      charges 削除時に自動削除されます。
--   3. 本番実行前に必ず SELECT で対象データを確認してください。

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.charge_id = '127637091';  -- ロールバック対象の課金ID

-------------------------------
-- 1. 削除対象データの確認（実行前確認用）
-------------------------------
-- 課金データ
SELECT
    charge_id,
    charge_company_id,
    charge_status,
    charge_type,
    charge_date,
    charge_year,
    charge_month
FROM charges
WHERE charge_id = current_setting('v.charge_id')::int;

-- 課金明細データ
SELECT
    ci_id,
    ci_charge_id,
    ci_type,
    ci_title,
    ci_subtotal_including_tax
FROM charge_items
WHERE ci_charge_id = current_setting('v.charge_id')::int;

-- 決済履歴データ
SELECT
    ch_id,
    ch_charge_id,
    ch_amount,
    ch_result_code,
    ch_created_at
FROM charge_histories
WHERE ch_charge_id = current_setting('v.charge_id')::int;

-------------------------------
-- 2. ロールバック実行
-------------------------------
BEGIN;

-- 2-1. 決済履歴の削除（外部キー制約のため先に削除）
DELETE FROM charge_histories
WHERE ch_charge_id = current_setting('v.charge_id')::int;

-- 2-2. 課金データの削除（charge_itemsはCASCADEで自動削除）
DELETE FROM charges
WHERE charge_id = current_setting('v.charge_id')::int;

COMMIT;

-------------------------------
-- 3. 削除確認
-------------------------------
SELECT
    'charges' AS table_name,
    COUNT(*) AS remaining_count
FROM charges
WHERE charge_id = current_setting('v.charge_id')::int
UNION ALL
SELECT
    'charge_items',
    COUNT(*)
FROM charge_items
WHERE ci_charge_id = current_setting('v.charge_id')::int
UNION ALL
SELECT
    'charge_histories',
    COUNT(*)
FROM charge_histories
WHERE ch_charge_id = current_setting('v.charge_id')::int;