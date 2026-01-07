# BigAdvance 課金・契約期間に関するドメイン知識

記録日時: 2026-01-20 13:06:44

## 学んだこと

### 1. 課金関連カラムの違い

| カラム | 役割 | 設定タイミング |
|--------|------|---------------|
| `company_charge_start_at` | 課金開始日（課金バッチの対象判定に使用） | 管理画面から設定/変更可能 |
| `company_charge_period_start_date` | 契約期間の開始日 | カード登録時に自動設定 |
| `company_charge_period_end_date` | 契約期間の終了日 | カード登録時に自動設定 |

**重要**: 課金開始日と契約期間は別物。管理画面から課金開始日だけをnullにしても、契約期間は変更されない。

### 2. `is_charge_free_period()` のロジック

```php
public function is_charge_free_period(): bool
{
    // 1. 契約期間中であれば無料期間ではない
    if ($this->is_in_charge_period($now)) {
        return false;
    }

    // 2. 課金開始日が未来でなければ無料期間ではない
    if (!$this->is_charge_start_in_future($now)) {
        return false;  // ← 課金開始日がnullの場合もここでfalse
    }

    // 3. 契約開始前、または契約終了後であれば無料期間
    return $this->is_before_contract_start($now)
           || $this->is_after_contract_end($now);
}
```

**無料期間の定義**: 「課金開始日がnullでない、かつ未来」かつ「契約期間外」

| 課金開始日 | 契約期間 | is_charge_free_period |
|-----------|---------|----------------------|
| 未来の日付 | 契約期間外 | **true**（無料期間） |
| 未来の日付 | 契約期間内 | false |
| 過去/今日 | - | false |
| **null** | - | **false**（無料期間ではない） |

### 3. 契約期間が設定されるタイミング

#### カード登録時
```php
// Controller_Api_V1_User::post_card()
$this->login_company->update_credircard_from_form($this->af);
$this->login_company->charge_initialized($this->login_company->company_charge_type);
```

`charge_initialized()` が呼ばれると、`charge_start_type_monthly()` または `charge_start_type_annual()` が実行され、以下が設定される：
- `company_charge_start_at`
- `company_charge_period_start_date`
- `company_charge_period_end_date`

#### 課金バッチ実行時
`update_current_charge_type_monthly()` / `update_current_charge_type_annual()` で契約期間が更新される。

#### 管理画面から課金情報更新時
`is_charge_free_period()` が true の場合のみ、`update_charge_info_for_free_period()` で契約期間も連動して更新される。

### 4. 契約期間がnullになるタイミング

1. **初期状態（カード未登録）**
2. **BAポータルへのダウングレード時** (`downgrade_normal_to_baportal()`)

### 5. 課金データが生成される条件

`get_charge_target()` の条件：
```php
->where('company_is_charge_target', 1)
->where('company_charge_start_at', '<=', $date->format('Y-m-d'))  // ← 課金開始日がnullだと対象外
```

課金開始日がnullの場合、課金バッチの対象にならないため、課金データ（chargesテーブル）は生成されない。

### 6. プラン変更ボタンの表示条件とアクセス条件の不整合

#### ボタン表示条件（index.vue）
```typescript
const isShowChangePlanButton = computed(() => {
  return appStore.appConfig.annual_charge_enable
    && !chargePlan.value.isUnsubscribed;
});
// + !userStore.isFreePeriod（セクション自体の表示条件）
```

#### 画面遷移条件（canAccessPaymentCardCreatePlan.ts）
```typescript
// 条件4: 無料期間チェック
if (userStore.isFreePeriod) { return false; }

// 条件7: 課金開始日時がない場合 ← ボタン表示条件にはない！
if (!userStore.companyChargeStartAt) { return false; }
```

**問題**: 課金開始日がnull + 契約期間内の場合
- `is_charge_free_period()` = false → ボタン表示される
- しかし `canAccessPaymentCardCreatePlan` の条件7で弾かれる
- → 「権限がありません」エラー

### 7. 退会画面の文言問題

退会画面（`/mypage/setting/unsubscribe`）では契約期間終了日を表示：
```vue
退会処理をすると、{{ formattedChargePeriodEndDate }}末ですべてのサービスが利用できなくなります。
```

契約期間がnullの場合、文言がおかしくなる：
```
退会処理をすると、末ですべてのサービスが利用できなくなります。
              ↑ 空になる
```

**発生条件**: 契約期間がnull + URL直接アクセス（`routeAccessPermissions.ts` に制御なし）

## 判明した問題点

| # | 問題 | 発生条件 |
|---|------|---------|
| 1 | プラン変更ボタンが表示されるがアクセス拒否 | 課金開始日null + 契約期間内 |
| 2 | 退会画面の文言がおかしい | 契約期間null + 直接アクセス |

## 関連ファイル

- `src/xba/packages/xbacore/classes/model/company.php` - 課金・契約期間のロジック
- `src/xba/packages/xbacore/classes/model/charge.php` - 課金バッチ処理
- `src/xba/packages/xbacore/classes/controller/api/v1/user.php` - カード登録API
- `src/xba/packages/xbacore/classes/controller/api/v1/company/charge.php` - 課金情報更新API
- `ba-xba-frontend/utils/conditions/canAccessPaymentCardCreatePlan.ts` - プラン変更画面アクセス条件
- `ba-xba-frontend/pages/mypage/payment/card/create/index.vue` - お支払い設定画面
- `ba-xba-frontend/pages/mypage/setting/unsubscribe/index.vue` - 退会画面