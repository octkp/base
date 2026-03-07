# データ修復用SQL

## 不整合データの検出

### 孤立したグループ経由メンバーを検出

グループが削除されているのに、グループ経由メンバーが有効のまま残っているレコードを検出。

```sql
-- 孤立したグループ経由メンバーを検出
SELECT
    cm.chatmember_unique_code,
    cm.chatmember_chatroom_unique_code,
    cm.chatmember_target_unique_code,
    cm.chatmember_related_to,
    u.user_name as member_name,
    cr.chatroom_name
FROM chat_members cm
JOIN users u ON u.user_unique_code = cm.chatmember_target_unique_code
JOIN chat_rooms cr ON cr.chatroom_unique_code = cm.chatmember_chatroom_unique_code
WHERE cm.chatmember_related_to IS NOT NULL
  AND cm.chatmember_is_disabled = 0
  AND NOT EXISTS (
    SELECT 1 FROM users ug
    WHERE ug.user_unique_code = cm.chatmember_related_to
      AND ug.user_is_disabled = 0
  );
```

### 特定ルームの不整合を確認

```sql
-- 特定ルームのメンバー状況を確認
SELECT
    cm.chatmember_unique_code,
    cm.chatmember_target_unique_code,
    cm.chatmember_related_to,
    cm.chatmember_is_disabled,
    cm.chatmember_type,
    u.user_name
FROM chat_members cm
LEFT JOIN users u ON u.user_unique_code = cm.chatmember_target_unique_code
WHERE cm.chatmember_chatroom_unique_code = '<ルームのunique_code>'
ORDER BY cm.chatmember_is_disabled, cm.chatmember_related_to NULLS FIRST;
```

## データ修復

### 孤立したグループ経由メンバーを無効化

```sql
-- 孤立したグループ経由メンバーを無効化（DRY RUN）
SELECT
    cm.chatmember_unique_code,
    cm.chatmember_target_unique_code,
    cm.chatmember_related_to
FROM chat_members cm
WHERE cm.chatmember_related_to IS NOT NULL
  AND cm.chatmember_is_disabled = 0
  AND NOT EXISTS (
    SELECT 1 FROM users ug
    WHERE ug.user_unique_code = cm.chatmember_related_to
      AND ug.user_is_disabled = 0
  );

-- 実行確認後、UPDATE文を実行
UPDATE chat_members cm
SET chatmember_is_disabled = 1
WHERE cm.chatmember_related_to IS NOT NULL
  AND cm.chatmember_is_disabled = 0
  AND NOT EXISTS (
    SELECT 1 FROM users ug
    WHERE ug.user_unique_code = cm.chatmember_related_to
      AND ug.user_is_disabled = 0
  );
```

### 特定ルームのみ修復

```sql
-- 特定ルームの孤立メンバーを無効化
UPDATE chat_members cm
SET chatmember_is_disabled = 1
WHERE cm.chatmember_chatroom_unique_code = '<ルームのunique_code>'
  AND cm.chatmember_related_to IS NOT NULL
  AND cm.chatmember_is_disabled = 0
  AND NOT EXISTS (
    SELECT 1 FROM users ug
    WHERE ug.user_unique_code = cm.chatmember_related_to
      AND ug.user_is_disabled = 0
  );
```

## 注意事項

- 本番実行前に必ずDRY RUN（SELECT文）で対象件数を確認すること
- バックアップを取得してから実行すること
- 大量データの場合はLIMIT付きで分割実行を検討
