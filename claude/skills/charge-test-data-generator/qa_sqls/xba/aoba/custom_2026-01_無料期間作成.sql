-- 目的: 2026年1月を無料期間にする（契約期間終了日変更 + 課金データ削除）
-- 対象テーブル: companies, charges, charge_items, charge_histories
-- データベース: xba
-- 環境: aoba7
-- 企業ID: 123694281

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123694281';

-- 契約期間を2025年12月に変更
SET v.charge_period_start_date = '2025-12-01';
SET v.charge_period_end_date = '2025-12-31';

-- 削除対象期間（2026年1月）
SET v.delete_target_start = '2026-01-01';
SET v.delete_target_end = '2026-01-31';

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
-- companies
SELECT
    *
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-- charges（2026年1月分）
SELECT
    *
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_date >= current_setting('v.delete_target_start')::date
  AND charges.charge_date <= current_setting('v.delete_target_end')::date
ORDER BY charges.charge_date DESC;

-- charge_items（2026年1月分）
SELECT
    *
FROM charge_items
WHERE charge_items.ci_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
      AND charges.charge_date >= current_setting('v.delete_target_start')::date
      AND charges.charge_date <= current_setting('v.delete_target_end')::date
)
ORDER BY charge_items.ci_charge_id DESC, charge_items.ci_seq;

-------------------------------
-- 2. テストデータ更新
-------------------------------
-- 2-0. 既存chargesのcharge_envをtest7に統一
UPDATE charges
SET charge_env = 'test7'
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_env != 'test7';

-- 2-1. charge_historiesクリア（2026年1月分）
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
      AND charges.charge_date >= current_setting('v.delete_target_start')::date
      AND charges.charge_date <= current_setting('v.delete_target_end')::date
);

-- 2-2. chargesクリア（2026年1月分）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_date >= current_setting('v.delete_target_start')::date
  AND charges.charge_date <= current_setting('v.delete_target_end')::date;

-- 2-3. companies更新（契約期間開始日・終了日を変更）
UPDATE companies
SET
    company_charge_period_start_date = current_setting('v.charge_period_start_date')::date,
    company_charge_period_end_date = current_setting('v.charge_period_end_date')::date
WHERE company_id = current_setting('v.company_id')::int
RETURNING
    *;

-------------------------------
-- 3. 実行後確認
-------------------------------
-- charges（2026年1月分が削除されていることを確認）
SELECT
    *
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charges.charge_date DESC;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;
