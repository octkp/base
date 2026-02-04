# パスワードを変更するSQL

記録日時: 2026-01-20 08:59:39

## 学んだこと

BAMとXBAでユーザーのパスワードを変更する方法。

### BAM (oauth_users テーブル)

```sql
UPDATE oauth_users
SET    ou_login_password = '$2y$10$yd2ku4NkbRNuKeWrnkTiZODNZ.NFpqF6CjugFeCa.SQik.M.5ceLe'
WHERE ou_login_id = 'kokopelli';
```

### XBA (user_passwords テーブル)

最新のパスワードレコードを対象に更新する。

```sql
UPDATE user_passwords
SET up_hash = '$2y$10$yd2ku4NkbRNuKeWrnkTiZODNZ.NFpqF6CjugFeCa.SQik.M.5ceLe'
WHERE up_user_id = (
    SELECT user_id
    FROM users
    WHERE user_login_id = 'kokopelli'
)
  AND up_created_at = (
    SELECT MAX(up_created_at)
    FROM user_passwords
    WHERE up_user_id = (
        SELECT user_id
        FROM users
        WHERE user_login_id = 'kokopelli'
    )
);
```

### 備考

- ハッシュ値 `$2y$10$yd2ku4NkbRNuKeWrnkTiZODNZ.NFpqF6CjugFeCa.SQik.M.5ceLe` は bcrypt 形式
- `kokopelli` の部分を変更したいユーザーのログインIDに置き換えて使用する
