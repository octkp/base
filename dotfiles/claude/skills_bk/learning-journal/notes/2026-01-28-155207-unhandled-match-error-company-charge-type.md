# UnhandledMatchError: company_charge_type の調査と修正

記録日時: 2026-01-28 15:52:07

## 学んだこと

### エラー概要

企業登録申請の承認処理で以下のエラーが発生した。

```
UnhandledMatchError: Unhandled match value of type string in company.php:581
```

### 調査結果

#### 1. エラー発生箇所

`packages/xbacore/classes/model/company.php:579-582` の `charge_initialized()` メソッド内の `match` 式。

```php
match ($charge_type) {
    \Model_Charge::TYPE_MONTHLY => $this->charge_start_type_monthly(),
    \Model_Charge::TYPE_ANNUAL => $this->charge_start_type_annual(),
};
```

`MONTHLY` と `ANNUAL` のみをハンドルしており、それ以外の値（空文字列など）でエラー発生。

#### 2. 呼び出し元

`packages/xbacore/classes/model/company/register.php:854`

```php
$company->charge_initialized($data['company_charge_type'] ?? \Model_Charge::TYPE_MONTHLY);
```

`$data['company_charge_type']` が空文字列 `""` の場合、`??` 演算子は `null` のみをチェックするため、デフォルト値が適用されない。

#### 3. 空文字列が入る原因

**フロントエンドからの流れ:**

1. `pages/register/hgba/index.vue` で `company_charge_type: null` が初期値
2. `annual_charge_enable` が `false` の場合、プラン選択ページをスキップ
3. `company_charge_type` が `null` のまま送信される

**バックエンドでの変換:**

1. `register.php:500-502` で `convert_string()` が全ての値に適用される
2. `convert_string()` 内の `mb_convert_kana(null, 'asK')` が `null` を空文字列 `""` に変換
3. `cr_data` に `company_charge_type: ""` として保存される

#### 4. プラン選択をスキップする条件

| `can_register_creditcard` | `annual_charge_enable` | 結果 |
|---------------------------|------------------------|------|
| true | true | プラン選択画面へ |
| true | false | **スキップ** → 支払い画面へ |
| false | - | **スキップ** → 直接送信 |

※ `can_register_creditcard = false` の場合、クレカ情報がないため `charge_initialized()` は呼ばれない（エラー発生しない）

#### 5. 影響を受けるBA

同じコードパターンを持つファイル:

- `pages/register/hgba/index.vue`
- `pages/register/ktba/index.vue`
- `pages/register/ba/index.vue`

### 修正内容

#### バックエンド（防御的コード）

`company.php` の `match` 式に `default` ケースを追加:

```php
match ($charge_type) {
    \Model_Charge::TYPE_MONTHLY => $this->charge_start_type_monthly(),
    \Model_Charge::TYPE_ANNUAL => $this->charge_start_type_annual(),
    default => $this->charge_start_type_monthly(),  // 追加
};
```

#### フロントエンド（根本解決）

3つのファイルで、年払い無効時に `company_charge_type = ChargePlanType.MONTHLY` を設定:

```javascript
// Before
if (appStore.appConfig.can_register_creditcard) {
  appStore.appConfig.annual_charge_enable
    ? addRegisterBaPage('plan')
    : addRegisterBaPage('payment');
}

// After
if (appStore.appConfig.can_register_creditcard) {
  if (appStore.appConfig.annual_charge_enable) {
    addRegisterBaPage('plan');
  } else {
    form.value.company_charge_type = ChargePlanType.MONTHLY;  // 追加
    addRegisterBaPage('payment');
  }
}
```

### 学び

1. **`??` 演算子と `?:` 演算子の違い**
   - `??`: `null` のみをチェック（空文字列は通過する）
   - `?:`: falsy な値（`null`, `""`, `0`, `false`）をチェック

2. **`mb_convert_kana()` の挙動**
   - PHP 8.1+ で `mb_convert_kana(null, ...)` は空文字列 `""` を返す

3. **PHP 8 の `match` 式**
   - ハンドルされない値が渡されると `UnhandledMatchError` が発生
   - 防御的に `default` ケースを入れることを検討すべき

4. **調査の流れ**
   - スタックトレースから発生箇所を特定
   - 呼び出し元を追跡して値の流れを確認
   - DBに保存された実際の値を確認（`company_charge_type: ""`）
   - フロントエンドまで遡って根本原因を特定
