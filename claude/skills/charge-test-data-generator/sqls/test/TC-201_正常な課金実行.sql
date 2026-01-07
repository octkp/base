-- 目的: TC-201 正常な課金実行
-- 期待結果: charge_status = 'OK'に更新
-- 対象テーブル: companies, charges

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '127637091';

-- companiesテーブル更新用
SET v.charge_type = 'MONTHLY';                 -- 月払い
SET v.next_charge_type = 'MONTHLY';            -- 次回も月払い
SET v.charge_amount = '3000';                  -- 月払い金額
SET v.next_charge_amount = '3000';             -- 月払い金額
SET v.charge_start_at = '2025-12-01';          -- 課金開始日 - 先月
SET v.charge_period_start_date = '2025-12-01'; -- 契約期間開始日
SET v.charge_period_end_date = '2025-12-31';   -- 契約期間終了日
SET v.is_charge_target = '1';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
SELECT
    company_id,
    company_name,
    company_charge_type,
    company_next_charge_type,
    company_charge_amount,
    company_next_charge_amount,
    company_charge_start_at,
    company_charge_period_start_date,
    company_charge_period_end_date,
    company_is_charge_target
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. charge_historiesテーブルクリア（先に削除）
-------------------------------
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
);

-------------------------------
-- 3. chargesテーブルクリア（今月以降のデータを削除）
-------------------------------
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_period_start_date >= '2026-01-01';

-------------------------------
-- 4. テストデータ更新
-------------------------------
UPDATE companies
SET
    company_charge_type = current_setting('v.charge_type'),
    company_next_charge_type = current_setting('v.next_charge_type'),
    company_charge_amount = current_setting('v.charge_amount')::int,
    company_next_charge_amount = current_setting('v.next_charge_amount')::int,
    company_charge_start_at = current_setting('v.charge_start_at')::date,
    company_charge_period_start_date = current_setting('v.charge_period_start_date')::date,
    company_charge_period_end_date = current_setting('v.charge_period_end_date')::date,
    company_is_charge_target = current_setting('v.is_charge_target')::int
WHERE company_id = current_setting('v.company_id')::int
RETURNING
    company_id,
    company_name,
    company_charge_type,
    company_next_charge_type,
    company_charge_amount,
    company_next_charge_amount,
    company_charge_start_at,
    company_charge_period_start_date,
    company_charge_period_end_date,
    company_is_charge_target;

-------------------------------
-- 3. 課金作成後、chargesテーブルのステータス確認用
-------------------------------
-- SELECT
--     charges.charge_id,
--     charges.company_id,
--     charges.charge_status,
--     charges.charge_type,
--     charges.charge_date,
--     charges.charge_amount,
--     charges.charge_fail_count
-- FROM charges
-- WHERE charges.company_id = current_setting('v.company_id')::int
-- ORDER BY charges.charge_date DESC
-- LIMIT 5;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;