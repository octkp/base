---
name: charge-test-data-generator
description: Big Advance課金機能のテストデータを作成するSQL生成スキル。企業の課金状態を特定のパターンに設定するSQLを生成する。「○○のテストデータを作成」「課金テスト用のデータ」「月払い→年払いパターン」「先月課金されて今月○○」などのリクエストでトリガー。課金タイプ変更（月払い⇔年払い）、課金タイミング（初回課金、継続課金、契約満了）のテストパターンに対応。「D-01のテストデータ」「B-02パターン」「無料期間終了パターン」「契約更新バッチ」などのパターン番号指定にも対応。
---

# Charge Test Data Generator

課金機能テスト用のSQLを生成するスキル。企業の課金状態を特定のパターンに設定する。

## SQL出力先

対応するDB（bamanager or xba）と環境（aoba or cuba）によってディレクトリを分ける。

```
qa_sqls/
├── xba/
│   ├── aoba/    # aoba7環境用（bank_code: 0117）
│   │   └── {SQL No}_{パターン名}.sql
│   └── cuba/    # cuba7環境用（bank_code: 0542）
│       └── {SQL No}_{パターン名}.sql
└── bamanager/
    ├── aoba/    # aoba7環境用（bank_code: 0117）
    │   └── {SQL No}_{パターン名}.sql
    └── cuba/    # cuba7環境用（bank_code: 0542）
        └── {SQL No}_{パターン名}.sql
```

フルパス:
- xba: `/Users/takano_y/.claude/skills/charge-test-data-generator/qa_sqls/xba/{環境}/{パターン名}.sql`
- bamanager: `/Users/takano_y/.claude/skills/charge-test-data-generator/qa_sqls/bamanager/{環境}/{パターン名}.sql`

## テストパターン

### 課金タイプ変更

| パターン | company_charge_type | company_next_charge_type |
|---------|---------------------|--------------------------|
| 月払い→月払い | MONTHLY | MONTHLY |
| 月払い→年払い | MONTHLY | ANNUAL |
| 年払い→月払い | ANNUAL | MONTHLY |
| 年払い→年払い | ANNUAL | ANNUAL |

### 課金タイミング

| パターン | 説明 |
|---------|------|
| 先月課金・今月課金予定 | 契約期間が先月末で終了 |
| 今月初課金 | 課金開始日が今月 |
| 年払い期間中 | 年払い契約期間の途中 |
| 契約満了直前 | 年払い契約が今月末で満了 |

---

## プレテスト（test7）パターン一覧

プレテスト環境（aoba7/cuba7）で使用するパターン。SQL Noをファイル名のプレフィックスとして使用する。

### カテゴリ1: 日付操作が必要なケース（D-01〜D-06）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| D-01 | 年払い申込後、無料期間終了 | 無料期間終了日を過去日付に設定 | 無料期間満了後の課金データ生成確認 |
| D-02 | 契約満了日の23:59→0:01をまたぐ | 契約終了日を検証日の前日に設定 | 日付境界での契約更新処理確認 |
| D-03 | 年払い契約11ヶ月目（残1ヶ月） | 契約開始日を11ヶ月前に設定 | 契約満了間近での退会予約動作確認 |
| D-04 | 年払い契約満了月の1日 | 契約終了日を検証月末に設定 | 契約更新メール・イベント生成確認 |
| D-05 | 月払い→年払い変更予約後の契約満了 | 月払い契約終了日を検証日の前日に設定 | 年払いへの切替処理確認 |
| D-06 | 年払い→月払い変更予約後の契約満了 | 年払い契約終了日を検証日の前日に設定 | 月払いへの切替処理確認 |

### カテゴリ2: 金融機関設定操作が必要なケース（F-01）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| F-01 | 年払いON→OFF後の既存年払いユーザー契約満了 | ①年払いONで年払い契約作成→②年払いOFF→③契約終了日を過去に設定 | 強制月払い切替確認 |

### カテゴリ3: バッチ処理タイミング確認が必要なケース（B-01〜B-04）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| B-01 | 課金データ作成バッチ実行後 | バッチ実行または同等のデータ状態作成 | 年払い課金データの正常生成確認 |
| B-02 | 契約更新バッチ実行（年払い継続） | 契約満了日経過後のバッチ実行 | 年払い→年払いの更新確認 |
| B-03 | 契約更新バッチ実行（年払い→月払い） | 変更予約済み＋契約満了日経過後のバッチ実行 | プラン切替の更新確認 |
| B-04 | メール送信バッチ（AM9:00） | 契約満了月1日の状態作成 | メール送信＋イベント生成確認 |

### カテゴリ4: 特殊条件の組み合わせ（X-04）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| X-04 | 年払い2年目更新直前 | 2年目の契約満了日を検証日の翌日に設定 | 2回目以降の更新処理確認 |

### カテゴリ5: 課金開始日操作が必要なケース（K-02）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| K-02 | 年払い満了→月払い変更＋課金開始日が未来日 | 年払い契約満了＋課金開始日を未来日に設定 | 再無料期間発生時の挙動確認 |

### カテゴリ6: 課金設定操作が必要なケース（CH-01）

| パターン | 説明 | SQL操作 | 検証目的 |
|----------|------|---------|----------|
| CH-01 | 年払い契約満了月＋課金無効 | 課金処理フラグをOFFに設定＋契約満了月1日の状態作成 | 契約更新確認メールが送信されないこと |

---

## 企業データ対応表（test7環境）

SQL Noをファイル名のプレフィックスとして使用。

### 金融機関コード

| 環境 | 金融機関コード |
|------|----------------|
| aoba7 | 0117 |
| cuba7 | 0542 |

### 企業ID対応表

| SQL No | パターン | 説明 | aoba7 | cuba7 |
|--------|----------|------|-------|-------|
| 01 | D-01 + B-01 | 無料期間終了〜契約更新バッチ一連（初回年払い） | 123714352 | 123902124 |
| 02 | B-02 | 契約更新バッチ実行（年払い継続） | 123657570 | 123528242 |
| 03 | B-03 | 契約更新バッチ実行（年払い→月払い） | 123637984 | 123529190 |
| 04 | D-02 | 契約満了日の23:59→0:01をまたぐ | 123583608 | 123529302 |
| 05 | D-03 | 年払い契約11ヶ月目（残1ヶ月） | 123612848 | 123531604 |
| 06 | D-04 + B-04 | 契約満了月1日（メール送信確認含む） | 123581219 | 123532307 |
| 07 | D-05 + F-01 | 月払い→年払い変更予約後の契約満了 | 123582185, 123578422 | 123535186, 123555135 |
| 08 | D-06 + F-01 | 年払い→月払い変更予約後の契約満了 | 123571118, 123570501 | 123566220, 123573857 |
| 09 | X-04 | 年払い2年目更新直前 | 123560480 | 123588971 |
| 10 | K-02 | 年払い満了→月払い変更＋課金開始日が未来日 | 123560475 | 123628544 |
| 11 | CH-01 | 年払い契約満了月＋課金無効 | 123553837 | 123892092 |

### SQLファイル命名規則

```
{SQL No}_{パターン番号}_{説明}.sql
```

例：
- `01_D-01_B-01_初回の年払いパターン.sql`
- `02_B-02_年払い継続パターン.sql`
- `03_B-03_年払いから月払いパターン.sql`

---

## 参照ドキュメント

- `docs/プレテスト（test7）企業データ管理表.md` - 企業IDとパターンの対応表
- `docs/開発側データ操作が必要なパターン.md` - 各パターンの詳細説明と優先度

## SQLフォーマット

### 基本形式（companiesのみ）

```sql
-- 目的: [テストパターンの説明]
-- 対象テーブル: companies

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '企業ID';

-- companiesテーブル更新用
SET v.charge_type = 'MONTHLY';
SET v.next_charge_type = 'MONTHLY';
SET v.charge_amount = '3000';
SET v.next_charge_amount = '3000';
SET v.charge_start_at = 'YYYY-MM-01';
SET v.charge_period_start_date = 'YYYY-MM-DD';
SET v.charge_period_end_date = 'YYYY-MM-DD';
SET v.is_charge_target = '1';

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
SELECT * FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-------------------------------
-- 2. テストデータ更新
-------------------------------
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
RETURNING *;
```

### 拡張形式（charges, charge_items含む）

課金データの作成が必要な場合（契約更新テストなど）に使用。

```sql
-- 目的: [テストパターンの説明]
-- 対象テーブル: companies, charges, charge_items

-------------------------------
-- 変数設定
-------------------------------
SET v.company_id = '企業ID';
-- ... 各種変数

-------------------------------
-- トランザクション開始
-------------------------------
BEGIN;

-------------------------------
-- 1. 現在の状態を確認
-------------------------------
-- companies
SELECT * FROM companies
WHERE company_id = current_setting('v.company_id')::int;

-- charges
SELECT * FROM charges
WHERE charges.charge_company_id = current_setting('v.company_id')::int
ORDER BY charges.charge_date DESC;

-- charge_items
SELECT * FROM charge_items
WHERE charge_items.ci_charge_id IN (
    SELECT charges.charge_id FROM charges
    WHERE charges.charge_company_id = current_setting('v.company_id')::int
)
ORDER BY charge_items.ci_charge_id DESC, charge_items.ci_seq;

-------------------------------
-- 2. テストデータ更新
-------------------------------
-- 2-1. charge_historiesクリア
DELETE FROM charge_histories WHERE ...;

-- 2-2. chargesクリア
DELETE FROM charges WHERE ...;

-- 2-3. charges作成
INSERT INTO charges (...) VALUES (...);

-- 2-4. charge_items作成
INSERT INTO charge_items (...) SELECT ...;

-- 2-5. companies更新
UPDATE companies SET ... WHERE ... RETURNING *;

-------------------------------
-- トランザクション終了
-------------------------------
COMMIT;
```

## ルール

- ASでのカラム名変更禁止
- テーブルエイリアス禁止（フルテーブル名を使用）
- 日本語名への変換禁止
- 確認SQLにLIMITは不要
- xbaでcharges更新時、企業に紐づく既存chargesのcharge_envをtest7に統一する

## 主要カラム

### companies

| カラム | 説明 | 値 |
|--------|------|-----|
| company_charge_type | 現在の課金タイプ | MONTHLY / ANNUAL |
| company_next_charge_type | 次回の課金タイプ | MONTHLY / ANNUAL |
| company_charge_amount | 課金金額（税抜） | 月払い: 3000 / 年払い: 33000 |
| company_next_charge_amount | 次回課金金額（税抜） | 月払い: 3000 / 年払い: 33000 |
| company_charge_start_at | 課金開始日 | 日付（1日固定） |
| company_charge_period_start_date | 契約期間開始日 | 日付 |
| company_charge_period_end_date | 契約期間終了日 | 月払い: 月末 / 年払い: +11ヶ月末 |
| company_is_charge_target | 課金対象フラグ | 0 / 1 |

## 制約

- company_charge_start_at は日が1日固定（CHECK制約）
- chargesテーブルは同一企業・課金タイプで期間重複不可（EXCLUDE制約）