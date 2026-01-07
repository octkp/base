-- SQL No: 04
-- パターン: D-02
-- 目的: 契約満了日の23:59→0:01をまたぐ状態を作成
-- 検証目的: 日付境界での契約更新処理確認
-- 対象テーブル: companies, charges, charge_items
-- 環境: aoba7

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123583608';

-- 年払い継続の課金設定
SET v.charge_type = 'ANNUAL';
SET v.next_charge_type = 'ANNUAL';
SET v.charge_amount = '33000';
SET v.next_charge_amount = '33000';

-- 年払い契約期間
SET v.charge_start_at = '2025-01-01';           -- 課金開始日（月初のみ設定可能）
SET v.charge_period_start_date = '2025-01-01';  -- 契約期間開始日（課金開始日に合わせる）
SET v.charge_period_end_date = '2025-12-31';    -- 契約期間終了日（12ヶ月後の月末）
SET v.is_charge_target = '1';                   -- 課金対象

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

-- charges
SELECT
    *
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charges.charge_date DESC;

-- charge_items
SELECT
    *
FROM charge_items
WHERE charge_items.ci_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
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

-- 2-1. charge_historiesクリア（課金開始日以降の全レコード）
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

-- 2-3. charges作成
INSERT INTO charges (
    charge_company_id,
    charge_env,
    charge_status,
    charge_type,
    charge_date,
    charge_year,
    charge_month,
    charge_period_start_date,
    charge_period_end_date,
    charge_amount_excluding_tax,
    charge_tax_amount,
    charge_amount,
    charge_execute_at
) VALUES (
    current_setting('v.company_id')::int,
    'test7',
    'OK',
    'ANNUAL',
    current_setting('v.charge_start_at')::date,
    2025,
    1,
    current_setting('v.charge_period_start_date')::date,
    current_setting('v.charge_period_end_date')::date,
    33000,
    3300,
    36300,
    current_setting('v.charge_start_at')::timestamp
);

-- 2-4. charge_items作成
INSERT INTO charge_items (
    ci_charge_id,
    ci_seq,
    ci_type,
    ci_unit_price,
    ci_qty,
    ci_subtotal,
    ci_tax_rate,
    ci_tax_amount,
    ci_subtotal_excluding_tax,
    ci_subtotal_including_tax,
    ci_title,
    ci_is_annual
)
SELECT
    charges.charge_id,
    0,
    'subscription',
    33000,
    1,
    33000,
    10,
    3300,
    33000,
    36300,
    '基本料金',
    true
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 1;

-- 2-5. companies更新
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

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;
