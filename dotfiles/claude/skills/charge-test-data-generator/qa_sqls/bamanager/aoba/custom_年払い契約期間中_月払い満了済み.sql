-- カスタムパターン
-- 目的: 年払い契約満了前に月払い課金を満了していた状態を作成
-- シナリオ: 過去に月払い契約（2025年1月〜12月）が満了し、現在は年払い契約期間中（2026年1月〜12月）
-- 対象テーブル: companies, charges, charge_items
-- 環境: aoba7

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '123721303';

-- 現在の年払い契約設定
SET v.charge_type = 'ANNUAL';
SET v.next_charge_type = 'ANNUAL';
SET v.charge_amount = '33000';
SET v.next_charge_amount = '33000';

-- 年払い契約期間（現在進行中）
SET v.charge_start_at = '2025-01-01';              -- 課金開始日（月払い開始時点）
SET v.charge_period_start_date = '2026-01-01';     -- 年払い契約期間開始日
SET v.charge_period_end_date = '2026-12-31';       -- 年払い契約期間終了日
SET v.is_charge_target = '1';                      -- 課金対象

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
-- 2-1. charge_historiesクリア（2025年以降の全レコード）
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
      AND charges.charge_date >= '2025-01-01'::date
);

-- 2-2. chargesクリア（2025年以降の全レコード）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_date >= '2025-01-01'::date;

-- 2-3. 過去の月払い課金を作成（2025年1月〜12月の12ヶ月分）
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
)
SELECT
    current_setting('v.company_id')::int,
    'test7',
    'OK',
    'MONTHLY',
    ('2025-' || LPAD(m::text, 2, '0') || '-01')::date,
    2025,
    m,
    ('2025-' || LPAD(m::text, 2, '0') || '-01')::date,
    (('2025-' || LPAD(m::text, 2, '0') || '-01')::date + INTERVAL '1 month' - INTERVAL '1 day')::date,
    3000,
    300,
    3300,
    ('2025-' || LPAD(m::text, 2, '0') || '-01')::timestamp
FROM generate_series(1, 12) AS m;

-- 2-4. 過去の月払いcharge_items作成（2025年1月〜12月分）
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
  AND charges.charge_type = 'MONTHLY';

-- 2-5. 現在の年払い課金を作成（2026年1月〜）
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
    '2026-01-01'::date,
    2026,
    1,
    current_setting('v.charge_period_start_date')::date,
    current_setting('v.charge_period_end_date')::date,
    33000,
    3300,
    36300,
    '2026-01-01'::timestamp
);

-- 2-6. 現在の年払いcharge_items作成
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
  AND charges.charge_year = 2026
  AND charges.charge_month = 1
  AND charges.charge_type = 'ANNUAL';

-- 2-7. companies更新（現在は年払い契約期間中）
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
-- 3. 作成後の状態を確認
-------------------------------
-- charges（月払い12ヶ月 + 年払い1件）
SELECT
    *
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charges.charge_date;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;