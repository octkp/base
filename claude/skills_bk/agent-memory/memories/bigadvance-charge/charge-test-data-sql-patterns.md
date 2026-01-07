---
summary: "Big Advance課金テストデータSQL作成パターン - SQLスタイルルール、変数管理、chargesテーブル構造、charge_items構造、テストケース構成"
created: 2026-01-07
updated: 2026-01-08
status: resolved
tags: [charge, test-data, sql, postgresql, charge_items]
related: [/Users/takano_y/.claude/skills/charge-test-data-generator/sqls/test/]
---

# Big Advance課金テストデータSQL作成の重要ポイント

## SQLスタイルルール

- ASエイリアス禁止
- 日本語カラム名禁止
- テーブルエイリアス禁止（フルテーブル名を使用）

## PostgreSQL変数管理

```sql
-- 設定
SET v.変数名 = '値';

-- 参照（型キャスト必須）
current_setting('v.変数名')::int
current_setting('v.変数名')::date
current_setting('v.変数名')  -- 文字列の場合
```

## chargesテーブル

### 主要カラム
- `charge_company_id` - 企業ID
- `charge_env` - 環境（'test7'を指定）**※デフォルト値なし、必須**
- `charge_status` - ステータス（OK, FAILED等）
- `charge_type` - 課金タイプ（MONTHLY, ANNUAL）
- `charge_date` - 課金日
- `charge_year` - 課金年
- `charge_month` - 課金月
- `charge_period_start_date` - 課金期間開始日
- `charge_period_end_date` - 課金期間終了日
- `charge_amount_excluding_tax` - 税抜金額 **※デフォルト値なし、必須**
- `charge_tax_amount` - 消費税額（10%）**※デフォルト値なし、必須**
- `charge_amount` - 合計金額（税込）**※デフォルト値なし、必須**
- `charge_execute_at` - 課金実行日時（TIMESTAMP）**※デフォルト値なし、必須**

**注意**: `charge_base_amount`カラムは存在しない

### 制約
- UNIQUE制約: `(charge_company_id, charge_year, charge_month)`
- EXCLUDE制約: 重複期間防止

## テストデータSQL構成

```sql
-- 1. 変数設定
SET v.company_id = '127637091';
SET v.charge_type = 'MONTHLY';
-- ...

BEGIN;

-- 2. 現在状態確認
SELECT ... FROM companies WHERE company_id = current_setting('v.company_id')::int;

-- 3. charge_historiesテーブルクリア（chargesより先に削除必須！FK制約）
DELETE FROM charge_histories
WHERE charge_histories.ch_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
);

-- 4. chargesテーブルクリア（今月以降を削除）
DELETE FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_period_start_date >= '2026-01-01';

-- 5. 必要に応じてcharges INSERT（TC-102, TC-115, TC-203等）
INSERT INTO charges (...) VALUES (...);

-- 6. charge_items INSERT（charges INSERT後に実行）
INSERT INTO charge_items (...) SELECT ... FROM charges WHERE ...;

-- 7. companiesテーブルUPDATE
UPDATE companies SET ... WHERE company_id = current_setting('v.company_id')::int;

COMMIT;
```

**重要**: chargesを削除する前に必ずcharge_historiesを削除すること（外部キー制約）

## charge_itemsテーブル（課金明細）

### 主要カラム
- `ci_id` - 自動採番（PRIMARY KEY）
- `ci_charge_id` - 課金ID（charges.charge_idへのFK）**※必須**
- `ci_seq` - シーケンス番号（デフォルト0）
- `ci_type` - 明細タイプ **※必須**
  - `'subscription'` - サブスクリプション（基本料金、ちゃんと請求書）
  - `'pay_per_use'` - 従量課金（ビジネスユーザー）
  - `'adjust'` - 調整
- `ci_unit_price` - 単価
- `ci_qty` - 数量
- `ci_subtotal` - 小計（単価 × 数量）
- `ci_tax_rate` - 消費税率（10）
- `ci_tax_amount` - 消費税額
- `ci_subtotal_excluding_tax` - 税抜小計
- `ci_subtotal_including_tax` - 税込小計
- `ci_title` - 明細名
- `ci_is_annual` - 年払いフラグ（デフォルトfalse）

### ci_seqの使い方
| ci_seq | 用途 | ci_type | ci_is_annual |
|--------|------|---------|--------------|
| 0 | 基本料金 | subscription | 年払い=true, 月払い=false |
| 1 | ビジネスユーザー無料枠 | pay_per_use | false |
| 2 | ビジネスユーザー有料枠 | pay_per_use | false |
| 3 | ちゃんと請求書 | subscription | false |

### INSERTパターン（chargesのINSERT後にSELECTで紐付け）

```sql
-- 基本料金（年払い）: 33000 × 1 = 33000, 税額 3300, 税込 36300
INSERT INTO charge_items (
    ci_charge_id, ci_seq, ci_type, ci_unit_price, ci_qty,
    ci_subtotal, ci_tax_rate, ci_tax_amount,
    ci_subtotal_excluding_tax, ci_subtotal_including_tax,
    ci_title, ci_is_annual
)
SELECT
    charges.charge_id, 0, 'subscription', 33000, 1,
    33000, 10, 3300, 33000, 36300,
    '基本料金', true
FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025 AND charges.charge_month = 12;

-- ビジネスユーザー無料枠: 0 × 5 = 0
INSERT INTO charge_items (
    ci_charge_id, ci_seq, ci_type, ci_unit_price, ci_qty,
    ci_subtotal, ci_tax_rate, ci_tax_amount,
    ci_subtotal_excluding_tax, ci_subtotal_including_tax,
    ci_title, ci_is_annual
)
SELECT charges.charge_id, 1, 'pay_per_use', 0, 5, 0, 10, 0, 0, 0, 'ビジネスユーザー無料枠', false
FROM charges WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025 AND charges.charge_month = 12;

-- ビジネスユーザー有料枠: 300 × 3 = 900, 税額 90, 税込 990
INSERT INTO charge_items (
    ci_charge_id, ci_seq, ci_type, ci_unit_price, ci_qty,
    ci_subtotal, ci_tax_rate, ci_tax_amount,
    ci_subtotal_excluding_tax, ci_subtotal_including_tax,
    ci_title, ci_is_annual
)
SELECT charges.charge_id, 2, 'pay_per_use', 300, 3, 900, 10, 90, 900, 990, 'ビジネスユーザー', false
FROM charges WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025 AND charges.charge_month = 12;

-- ちゃんと請求書: 1000 × 1 = 1000, 税額 100, 税込 1100
INSERT INTO charge_items (
    ci_charge_id, ci_seq, ci_type, ci_unit_price, ci_qty,
    ci_subtotal, ci_tax_rate, ci_tax_amount,
    ci_subtotal_excluding_tax, ci_subtotal_including_tax,
    ci_title, ci_is_annual
)
SELECT charges.charge_id, 3, 'subscription', 1000, 1, 1000, 10, 100, 1000, 1100, 'ちゃんと請求書', false
FROM charges WHERE charges.charge_company_id = current_setting('v.company_id')::int
  AND charges.charge_year = 2025 AND charges.charge_month = 12;
```

## 課金タイプと金額

| タイプ | 金額 | 期間 |
|--------|------|------|
| MONTHLY | 3,000円/月 | 月末まで |
| ANNUAL | 33,000円/年 | +11ヶ月末まで |

## テストケースパターン

| パターン | charge_period_start/end_date | chargesテーブル |
|----------|------------------------------|-----------------|
| 初回課金 | NULL | DELETE（クリア状態） |
| 継続課金 | 前月末までの期間設定済み | DELETE |
| 年払い2ヶ月目以降 | 契約期間設定済み | DELETE + INSERT（初月分） |
| 二重課金防止テスト | 前月末までの期間設定済み | DELETE + INSERT（当月分） |

## ファイル保存先

```
/Users/takano_y/.claude/skills/charge-test-data-generator/sqls/test/TC-XXX_テスト名.sql
```

## 作成済みテストケース

- TC-001: 月払い初月
- TC-002: 月払い継続
- TC-003: 月払い→年払い切替
- TC-101: 年払い初月
- TC-102: 年払い2ヶ月目オプションのみ
- TC-103: 年払い初月オプションあり
- TC-104: 年払い→月払い切替
- TC-105: 年払い継続更新
- TC-115: オプションなし空課金防止
- TC-201: 正常な課金実行
- TC-203: 二重課金防止
- TC-301: 課金開始日当日
- TC-302: 課金開始日前日
- TC-401: 契約更新確認メール