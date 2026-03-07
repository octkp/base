-- SQL No: 07
-- パターン: D-05 + F-01
-- 目的: 月払い→年払い変更予約後、契約満了の状態を作成
-- 検証目的: 年払いへの切替処理確認
-- 対象テーブル: companies, charges, charge_items
-- 環境: cuba7
-- 備考: 123535186（年払いONのまま→年払いになる）, 123555135（年払いOFF→強制月払いになる）

-------------------------------
-- 変数設定
-------------------------------
-- 1企業目: 年払いONのままパターン（年払いになる）
SET v.company_id = '123535186';

-- 月払い→年払い変更の課金設定
SET v.charge_type = 'MONTHLY';
SET v.next_charge_type = 'ANNUAL';
SET v.charge_amount = '3000';
SET v.next_charge_amount = '33000';

-- 月払い契約期間
SET v.charge_start_at = '2025-01-01';           -- 課金開始日（月初のみ設定可能）
SET v.charge_period_start_date = '2025-12-01';  -- 契約期間開始日（12月から）
SET v.charge_period_end_date = '2025-12-31';    -- 契約期間終了日（月末）
SET v.is_charge_target = '1';                   -- 課金対象

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 現在の状態を確認（1企業目）
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

-------------------------------
-- 2. テストデータ更新（1企業目: 年払いONのまま）
-------------------------------
-- 2-0. 既存chargesのcharge_envをtest7に統一
UPDATE charges
SET charge_env = 'test7'
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_env != 'test7';

-- 2-1. charge_historiesクリア（2025年12月〜2026年1月の課金）
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
      AND ((charges.charge_year = 2025 AND charges.charge_month = 12)
        OR (charges.charge_year = 2026 AND charges.charge_month = 1))
);

-- 2-2. chargesクリア（2025年12月〜2026年1月の課金）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND ((charges.charge_year = 2025 AND charges.charge_month = 12)
    OR (charges.charge_year = 2026 AND charges.charge_month = 1));

-- 2-3. charges作成（月払い：12月〜1月13日）
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
    'MONTHLY',
    '2025-12-01'::date,
    2025,
    12,
    current_setting('v.charge_period_start_date')::date,
    current_setting('v.charge_period_end_date')::date,
    3000,
    300,
    3300,
    '2025-12-01'::timestamp
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
    3000,
    1,
    3000,
    10,
    300,
    3000,
    3300,
    '基本料金',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

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
-- 3. 2企業目の処理: 年払いOFFパターン（強制月払いになる）
-------------------------------
SET v.company_id = '123555135';
-- 強制月払いパターンは年払いOFF設定が必要
SET v.charge_period_end_date = '2025-12-31';

-- 3-0. 既存chargesのcharge_envをtest7に統一
UPDATE charges
SET charge_env = 'test7'
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_env != 'test7';

-- 3-1. charge_historiesクリア（2025年12月〜2026年1月の課金）
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
      AND ((charges.charge_year = 2025 AND charges.charge_month = 12)
        OR (charges.charge_year = 2026 AND charges.charge_month = 1))
);

-- 3-2. chargesクリア（2025年12月〜2026年1月の課金）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND ((charges.charge_year = 2025 AND charges.charge_month = 12)
    OR (charges.charge_year = 2026 AND charges.charge_month = 1));

-- 3-3. charges作成
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
    'MONTHLY',
    '2025-12-01'::date,
    2025,
    12,
    current_setting('v.charge_period_start_date')::date,
    current_setting('v.charge_period_end_date')::date,
    3000,
    300,
    3300,
    '2025-12-01'::timestamp
);

-- 3-4. charge_items作成
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
    3000,
    1,
    3000,
    10,
    300,
    3000,
    3300,
    '基本料金',
    false
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025
  AND charges.charge_month = 12;

-- 3-5. companies更新（2企業目は課金無効）
UPDATE companies
SET
    company_charge_type = current_setting('v.charge_type'),
    company_next_charge_type = current_setting('v.next_charge_type'),
    company_charge_amount = current_setting('v.charge_amount')::int,
    company_next_charge_amount = current_setting('v.next_charge_amount')::int,
    company_charge_start_at = current_setting('v.charge_start_at')::date,
    company_charge_period_start_date = current_setting('v.charge_period_start_date')::date,
    company_charge_period_end_date = current_setting('v.charge_period_end_date')::date,
    company_is_charge_target = 0  -- 年払いOFF企業は課金無効
WHERE company_id = current_setting('v.company_id')::int
RETURNING
    *;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;
