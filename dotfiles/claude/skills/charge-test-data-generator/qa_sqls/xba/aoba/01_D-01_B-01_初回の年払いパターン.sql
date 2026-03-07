-- SQL No: 01
-- パターン: D-01 + B-01
-- 目的: 年払い申込後、無料期間が終了した状態を作成
-- 検証目的: 無料期間満了後の課金データ生成確認
-- 対象テーブル: companies
-- 環境: aoba7

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123714352';

-- 年払いの課金設定
SET v.charge_type = 'ANNUAL';
SET v.next_charge_type = 'ANNUAL';
SET v.charge_amount = '33000';
SET v.next_charge_amount = '33000';

-- 無料期間終了 = 検証日から課金開始
SET v.charge_start_at = '2026-01-01';           -- 課金開始日（月初のみ設定可能）
SET v.charge_period_start_date = '2026-01-01';  -- 契約期間開始日（検証日）
SET v.charge_period_end_date = '2026-12-31';    -- 契約期間終了日（12ヶ月後の月末）
SET v.is_charge_target = '1';                   -- 課金対象

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
SELECT
    *
FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. テストデータ更新
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
    *;

DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
	SELECT charges.charge_id FROM charges
	WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_date >= current_setting('v.charge_start_at')::date
	);

-- 2-2. chargesクリア（課金開始日以降の全レコード）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_date >= current_setting('v.charge_start_at')::date;

-------------------------------
-- 3. 確認: 既存の課金データがないこと
-------------------------------
SELECT
    *
FROM charges
WHERE charge_company_id = current_setting('v.company_id')::int
ORDER BY charge_id DESC;
