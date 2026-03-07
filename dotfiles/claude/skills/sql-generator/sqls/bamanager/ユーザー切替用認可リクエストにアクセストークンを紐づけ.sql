-- 目的: action_switchで作成された認可リクエストにアクセストークンを紐づける
-- 対象テーブル: oauth_authorization_requests, oauth_access_tokens, oauth_id_tokens
--
-- 問題の背景:
--   action_switchでユーザー切替時に認可リクエストとIDトークンは作成されるが、
--   アクセストークンが作成・紐づけされていないため、
--   action_use_idtokenでアクセストークンを取得できない

-------------------------------
-- 変数設定（実行前に値を変更）
-------------------------------
-- 特定のIDトークンを指定する場合
SET v.oit_id = '12345';

-- アクセストークンの有効期限（秒）
SET v.access_token_lifetime = '300';

-------------------------------
-- 1. 特定のIDトークンに対してアクセストークンを作成・紐づけ
-------------------------------
WITH target_id_token AS (
    -- 対象のIDトークンを取得
    SELECT
        oauth_id_tokens.oit_id,
        oauth_id_tokens.oit_request_id,
        oauth_id_tokens.oit_client_id,
        oauth_id_tokens.oit_user_id,
        oauth_id_tokens.oit_expires
    FROM oauth_id_tokens
    WHERE oauth_id_tokens.oit_id = current_setting('v.oit_id')::bigint
),
new_access_token AS (
    -- 新しいアクセストークンを作成
    INSERT INTO oauth_access_tokens (
        oat_request_id,
        oat_client_id,
        oat_user_id,
        oat_expires,
        oat_scope
    )
    SELECT
        target_id_token.oit_request_id,
        target_id_token.oit_client_id,
        target_id_token.oit_user_id,
        now() + (current_setting('v.access_token_lifetime') || ' secs')::interval,
        'openid'
    FROM target_id_token
    RETURNING oat_access_token, oat_request_id
)
-- 認可リクエストにアクセストークンを紐づけ
UPDATE oauth_authorization_requests
SET oar_access_token = new_access_token.oat_access_token
FROM new_access_token
WHERE oauth_authorization_requests.oar_id = new_access_token.oat_request_id;

-------------------------------
-- 2. 確認用クエリ
-------------------------------
/*
-- IDトークンと認可リクエストの状態を確認
SELECT
    oauth_id_tokens.oit_id,
    oauth_id_tokens.oit_request_id,
    oauth_id_tokens.oit_user_id,
    oauth_id_tokens.oit_expires,
    oauth_authorization_requests.oar_id,
    oauth_authorization_requests.oar_access_token,
    oauth_authorization_requests.oar_switch_to,
    oauth_authorization_requests.oar_switch_from
FROM oauth_id_tokens
LEFT JOIN oauth_authorization_requests
    ON oauth_authorization_requests.oar_id = oauth_id_tokens.oit_request_id
WHERE oauth_id_tokens.oit_id = current_setting('v.oit_id')::bigint;
*/

-------------------------------
-- 3. 一括修正: oar_access_tokenがNULLの切替用認可リクエストを修正
-------------------------------
/*
-- 注意: 本番環境で実行する場合は十分にテストしてください

WITH switch_requests AS (
    -- 切替用（oar_switch_to IS NOT NULL）かつアクセストークン未設定の認可リクエストを取得
    SELECT
        oauth_authorization_requests.oar_id,
        oauth_id_tokens.oit_client_id,
        oauth_id_tokens.oit_user_id
    FROM oauth_authorization_requests
    JOIN oauth_id_tokens
        ON oauth_id_tokens.oit_request_id = oauth_authorization_requests.oar_id
    WHERE oauth_authorization_requests.oar_switch_to IS NOT NULL
      AND oauth_authorization_requests.oar_access_token IS NULL
      AND oauth_authorization_requests.oar_expires > now()  -- 有効期限内のもののみ
),
new_tokens AS (
    -- アクセストークンを一括作成
    INSERT INTO oauth_access_tokens (
        oat_request_id,
        oat_client_id,
        oat_user_id,
        oat_expires,
        oat_scope
    )
    SELECT
        switch_requests.oar_id,
        switch_requests.oit_client_id,
        switch_requests.oit_user_id,
        now() + (current_setting('v.access_token_lifetime') || ' secs')::interval,
        'openid'
    FROM switch_requests
    RETURNING oat_access_token, oat_request_id
)
UPDATE oauth_authorization_requests
SET oar_access_token = new_tokens.oat_access_token
FROM new_tokens
WHERE oauth_authorization_requests.oar_id = new_tokens.oat_request_id;
*/