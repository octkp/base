---
summary: "年払い機能OFF時に契約満了した年払い企業を月払いに自動移行するメソッドの調査結果。QA検証時の注意点と本番環境での影響を整理。"
created: 2026-01-16
tags: [charge, annual, monthly, task-5min, qa]
related: [src/xba/packages/xbacore/classes/model/company.php, src/xba/packages/xbacore/classes/task/5min.php]
---

# convert_expired_annual_company_charge_type_to_monthly 調査結果

## 概要

`Model_Company::convert_expired_annual_company_charge_type_to_monthly()` は年払い機能OFFの銀行で、契約満了した年払い企業を月払いに自動移行するメソッド。

## 場所

- 定義: `src/xba/packages/xbacore/classes/model/company.php:2474`
- 呼び出し: `src/xba/packages/xbacore/classes/task/5min.php:138`

## 実行条件

以下の**すべて**を満たす場合に実行される：

1. `Model_Charge::is_annual_charge_enable()` が `false`（年払い機能OFF）
2. `company_next_charge_type = ANNUAL`
3. `company_charge_period_end_date < 今日`

## 処理の流れ（Task_5min内）

1. `convert_expired_annual_company_charge_type_to_monthly($date)` が**先に**実行
2. その後 `create_this_month_charges($date)` で月払い課金作成
3. その後 `create_this_annual_charges($date)` で年払い課金作成

## QA検証時の注意点

- 年払い機能をOFFにするテストパターンでは、契約期間終了日が過ぎている年払い企業が、**次のTask_5min実行時**（5分毎）に月払いに自動変換される
- 意図せず変換されないようにするには：
  - テストデータの `company_charge_period_end_date` を未来日付にする
  - または検証後すぐにONに戻す

## 本番環境での影響

| ケース | 影響 |
|--------|------|
| 年払い機能ONの銀行 | 早期リターンするため**影響なし** |
| 年払い機能OFFの銀行 | そもそも年払い設定ができないため**問題なし** |
| 途中でON→OFFに切り替えた銀行 | 既存年払い企業が契約終了後に月払いに変換されるが、**意図した動作** |

## 結論

本番環境では問題にならない。QA環境で設定をコロコロ変えるケースのみ注意が必要。
