-- 目的: TC-106 年払い機能OFFの場合、次回年払いを予定している契約満了企業が自動的に月払いに移行することを確認
-- 期待結果: バッチ(5min)実行後、company_next_charge_typeがMONTHLYに変更される
-- 対象テーブル: companies, settings
-- 対象コード: Model_Company::convert_expired_annual_company_charge_type_to_monthly()

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '127637091';

-- companiesテーブル更新用
-- 年払い契約中で、次回も年払いを予定しているが、契約期間は終了している状態
SET v.charge_type = 'ANNUAL';                  -- 現在は年払い
SET v.next_charge_type = 'ANNUAL';             -- 次回も年払いを予定
SET v.charge_amount = '33000';                 -- 年払い金額
SET v.next_charge_amount = '33000';            -- 次回の年払い金額
SET v.charge_start_at = '2025-01-01';          -- 課金開始日 - 昨年1月
SET v.charge_period_start_date = '2025-01-01'; -- 契約期間開始日 - 昨年1月
SET v.charge_period_end_date = '2025-12-31';   -- 契約期間終了日 - 先月末（契約満了）
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
-- 3. charge_historiesテーブルクリア（先に削除）
-------------------------------
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
);

-------------------------------
-- 4. chargesテーブルクリア（今月以降のデータを削除）
-------------------------------
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_period_start_date >= '2026-01-01';

-------------------------------
-- 5. テストデータ更新（年払い契約満了、次回年払いを予定している状態）
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
-- トランザクション終了
-------------------------------
COMMIT;

-------------------------------
-- テスト手順
-------------------------------
-- 1. 上記SQLを実行してテストデータを準備
-- 2. 5minバッチを実行: xba/packages/xbacore/classes/task/5min.php
--    または直接メソッド呼び出し: Model_Company::convert_expired_annual_company_charge_type_to_monthly($date)
-- 3. 以下のSQLで結果を確認

-- 確認用SQL（バッチ実行後に確認）
-- SELECT
--     company_id,
--     company_name,
--     company_charge_type,
--     company_next_charge_type,          -- ← 'MONTHLY' に変更されているはず
--     company_charge_amount,
--     company_next_charge_amount,        -- ← 3000（月払いデフォルト金額）に変更されているはず
--     company_charge_period_start_date,
--     company_charge_period_end_date
-- FROM companies
-- WHERE company_id = 127637091;