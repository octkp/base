-- ============================================================
-- BAX-10325 Rollback SQL (xba)
-- ============================================================
-- 対象マイグレーション:
--   1573-BAX-10325_add_ci_annual_flag_charge_items_table.sql
--   1572-BAX-10325_add_company_charge_period_date.sql
--   1571-BAX-10325_add_event_code_contract_renewal_confirmation.sql
--   1570-BAX-10325_add_company_next_charge_amount.sql
--   1569-BAX-10325_add_company_next_charge_type.sql
--   1568-BAX-10325_add_charge_period_date_to_charges.sql
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1573: charge_itemsテーブルからci_is_annualカラムを削除
-- ------------------------------------------------------------
ALTER TABLE charge_items DROP COLUMN IF EXISTS ci_is_annual;

-- ------------------------------------------------------------
-- 1572: companiesテーブルから契約期間カラムを削除
-- ------------------------------------------------------------
ALTER TABLE companies DROP COLUMN IF EXISTS company_charge_period_start_date;
ALTER TABLE companies DROP COLUMN IF EXISTS company_charge_period_end_date;

-- ------------------------------------------------------------
-- 1571: event_codesから契約更新確認イベントを削除
-- ------------------------------------------------------------
DELETE FROM event_codes WHERE event_code = 'notify_user_of_contract_renewal_confirmation';

-- ------------------------------------------------------------
-- 1570: companiesテーブルからcompany_next_charge_amountカラムを削除
-- ------------------------------------------------------------
ALTER TABLE companies DROP COLUMN IF EXISTS company_next_charge_amount;

-- ------------------------------------------------------------
-- 1569: companiesテーブルからcompany_next_charge_typeカラムを削除
-- ------------------------------------------------------------
ALTER TABLE companies DROP COLUMN IF EXISTS company_next_charge_type;

-- ------------------------------------------------------------
-- 1568: chargesテーブルから課金期間カラムと制約を削除
-- ------------------------------------------------------------
-- 重複防止制約を削除
ALTER TABLE charges DROP CONSTRAINT IF EXISTS charges_no_overlapping_periods;

-- カラムを削除
ALTER TABLE charges DROP COLUMN IF EXISTS charge_period_start_date;
ALTER TABLE charges DROP COLUMN IF EXISTS charge_period_end_date;

-- ------------------------------------------------------------
-- migrationsテーブルからBAX-10325のレコードを削除
-- ------------------------------------------------------------
DELETE FROM migrations WHERE migration_name LIKE '%BAX-10325%';

COMMIT;
