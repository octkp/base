---
name: bax-10684-chat-member-display-bug
description: BAX-10684（チャットメンバー表示の不整合バグ）の調査・修正に関するナレッジ。メンバー一覧画面と編集画面で表示が異なる問題、グループ削除後もメンバーがルームにアクセスできる問題に対応。「BAX-10684」「チャットメンバー表示の不整合」「グループ削除後もメンバーが見える」などの問題で使用。
---

# BAX-10684: チャットメンバー表示の不整合バグ

## 問題概要

ビジネスチャットのルームで、メンバー一覧画面に表示されているメンバーがメンバー編集画面に表示されず、かつそのメンバーがルームを閲覧できてしまう問題。

### 症状
- メンバー一覧画面：174人表示
- メンバー編集画面：それより少ない人数
- 削除されたはずのメンバーがルームにアクセス可能

## 原因

### 2つのAPIの実装差異

| 画面 | API | フィルタ条件 |
|-----|-----|------------|
| メンバー一覧 | `/api/v1/chat/room/users` | `chatmember_is_disabled = 0` のみ |
| メンバー編集 | `/api/v1/chat/room/members` | `chatmember_is_disabled = 0` AND `chatmember_related_to is null` |

### 根本原因

`USER_DELETED`タスク（ユーザーグループ削除時）で、`DisableMemberByUserUniqueCode`関数が`chatmember_related_to IS NULL`条件を持っていたため、**グループ経由で追加されたメンバーが無効化されていなかった**。

## 修正内容（2026-01-15実施済み）

### 修正ファイル
`backend/task/user_deleted.go`

### 修正内容
ユーザーグループが削除された場合、`DisableChatMembersRelatedToUserGroup`も呼んでグループ経由メンバーを無効化するように修正。

```go
// ユーザーグループが削除された場合、グループ経由のメンバーも無効化する
if user.Type == model.UserTypeUserGroup {
    members, err := t.ctr.BackgroundTaskRepo.DisableChatMembersRelatedToUserGroup(ctx, uuc, nil)
    if err != nil {
        return err
    }
}
```

## 既存データの修復

修正は今後の新規削除に対して有効。過去に発生した不整合データは別途修復が必要。

データ修復用SQLは `references/data-repair-sql.md` を参照。

## 関連ファイル

### バックエンド
- `backend/task/user_deleted.go` - **修正済み**
- `backend/task/user_group_chat_member_deleted.go` - グループがルームから削除された時
- `backend/task/user_group_member_deleted_task.go` - グループからメンバーが削除された時
- `backend/infrastructure/postgresql/background_task.go:306` - `DisableChatMembersRelatedToUserGroup`
- `backend/infrastructure/postgresql/room.go:281-303` - `getChatMembers`（編集画面用）

### フロントエンド
- `frontend/composables/useMemberStore.ts` - メンバーデータ取得
- `frontend/components/dialog/MemberEdit.vue` - メンバー編集画面

## chat_memberテーブル構造

| カラム | 説明 |
|-------|------|
| `chatmember_unique_code` | メンバーの一意コード |
| `chatmember_chatroom_unique_code` | ルームの一意コード |
| `chatmember_target_unique_code` | ユーザーまたはグループの一意コード |
| `chatmember_related_to` | グループ経由の場合、グループの一意コード。直追加はNULL |
| `chatmember_is_disabled` | 0=有効、1=無効（論理削除） |
| `chatmember_type` | `user` または `user_group` |
| `chatmember_role` | メンバーのロール |
