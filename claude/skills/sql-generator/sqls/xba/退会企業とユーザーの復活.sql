-- 目的: 退会した企業とその所属ユーザーを復活させる
-- 対象テーブル: companies, users

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
SET v.company_id = '12345';  -- 復活させたい企業ID

-- ユーザー情報（手動で再設定が必要）
SET v.user_last_name = '山田';
SET v.user_first_name = '太郎';
SET v.user_email = 'example@example.com';
SET v.user_login_id = 'example@example.com';
SET v.user_tel = '0300000000';

-------------------------------
-- 1. 企業の復活
-------------------------------
UPDATE companies
SET
    company_is_unsubscribed = 0,
    company_status = 'ENABLE',
    company_is_disabled = 0,
    company_unsubscribe_scheduled_at = NULL,
    company_unsubscribed_date = NULL,
    company_unsubscribe_reason = NULL,
    company_unsubscribe_requested_at = NULL,
    company_unsubscribe_error = NULL
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. ユーザー（企業オーナー）の復活
-------------------------------
-- 注意: 退会時に個人情報（メール、ログインID、電話番号等）はNULLに設定されているため、
--       手動での再設定が必要です。
UPDATE users
SET
    user_is_disabled = 0,
    user_last_name = current_setting('v.user_last_name'),
    user_first_name = current_setting('v.user_first_name'),
    user_email = current_setting('v.user_email'),
    user_login_id = current_setting('v.user_login_id'),
    user_tel = current_setting('v.user_tel')
WHERE user_company_id = current_setting('v.company_id')::int
  AND user_type = 'company_owner'
  AND user_is_disabled = 1;

-------------------------------
-- 3. 従業員ユーザーの復活（必要な場合）
-------------------------------
-- 従業員も同様に個人情報の再設定が必要です。
-- 各従業員ごとにuser_idを指定して個別に実行してください。
/*
SET v.employee_user_id = '99999';
SET v.employee_last_name = '従業員姓';
SET v.employee_first_name = '従業員名';
SET v.employee_email = 'employee@example.com';
SET v.employee_login_id = 'employee@example.com';
SET v.employee_tel = '0300000001';

UPDATE users
SET
    user_is_disabled = 0,
    user_last_name = current_setting('v.employee_last_name'),
    user_first_name = current_setting('v.employee_first_name'),
    user_email = current_setting('v.employee_email'),
    user_login_id = current_setting('v.employee_login_id'),
    user_tel = current_setting('v.employee_tel')
WHERE user_id = current_setting('v.employee_user_id')::int
  AND user_is_disabled = 1;
*/

-------------------------------
-- 確認用クエリ
-------------------------------
-- 企業の状態確認
SELECT
    companies.company_id,
    companies.company_name,
    companies.company_status,
    companies.company_is_disabled,
    companies.company_is_unsubscribed,
    companies.company_unsubscribed_date
FROM companies
WHERE companies.company_id = current_setting('v.company_id')::int;

-- ユーザーの状態確認
SELECT
    users.user_id,
    users.user_type,
    users.user_last_name,
    users.user_first_name,
    users.user_email,
    users.user_login_id,
    users.user_is_disabled
FROM users
WHERE users.user_company_id = current_setting('v.company_id')::int;