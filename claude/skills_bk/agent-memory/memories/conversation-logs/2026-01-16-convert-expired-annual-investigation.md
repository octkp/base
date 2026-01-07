---
summary: "convert_expired_annual_company_charge_type_to_monthly メソッドについてQA検証で年払い→月払いに変わった原因を調査した会話ログ"
created: 2026-01-16
tags: [conversation-log, charge, annual, monthly, qa]
related: [src/xba/packages/xbacore/classes/model/company.php]
---

# 会話ログ: convert_expired_annual_company_charge_type_to_monthly 調査

## 発端

**ユーザー**:
聞いてもええか？ @src/xba/packages/xbacore/classes/model/company.php#L2474 なんやが、先月年払い契約が終了していて今月の課金がある場合、対象にならないか？

## 調査

**Claude**:
該当メソッドの中身を確認。

```php
public static function convert_expired_annual_company_charge_type_to_monthly($date): void
{
    // ONの場合は何もしない
    if (\Model_Charge::is_annual_charge_enable()) {
        return;
    }

    // 年払い契約をしていて、契約満了している企業を取得
    $companies = \Model_Company::find()
        ->where('company_next_charge_type', self::CHARGE_TYPE_ANNUAL)
        ->where('company_charge_period_end_date', '<', $date->format('Y-m-d'))
        ->get();

    foreach ($companies as $company) {
        \Log::info("年払い機能OFF: 企業ID {$company->company_id} を月払いに移行");
        $company->update_next_charge_type_monthly();
    }
}
```

Task_5min.php:138 で呼ばれている：
1. `convert_expired_annual_company_charge_type_to_monthly($date)` が**先に**実行
2. その後 `create_this_month_charges($date, ...)` で課金が作成

**Claude**:
最初は「今月課金されるべき年払い契約満了企業が、課金作成前に月払いに変換されてまう可能性がある」と指摘。

## 認識の修正

**ユーザー**:
いや、年払いOFFの場合は次回契約が年払いでも月払いにしなくちゃいけないのでそれはいいんですわ

**Claude**:
あー、そうか、年払いOFFなら月払いに移行するのが正しい動作やもんな。すまん、勘違いしたわ。

## 真の質問意図

**ユーザー**:
わかりにくくてすまん。QA検証用の企業が、次回更新予定のやつが年払いから月払いに変わってたことがあったんや。そんで原因が知りたかったっちゅーわけや

**Claude**:
QA環境で意図せず年払い→月払いに変わってた原因調査やな。

考えられる原因：
1. `convert_expired_annual_company_charge_type_to_monthly` が実行された
   - 年払い機能がOFF（`is_annual_charge_enable() = false`）
   - かつ `company_charge_period_end_date` が過去日付になってた

確認方法：
1. QA環境の年払い機能がOFFになってへんか？
2. 該当企業の `company_charge_period_end_date` が過去日付やったか？
3. ログで「年払い機能OFF: 企業ID {company_id} を月払いに移行」を確認

## 原因特定

**ユーザー**:
まさにそうで、QA検証でOFFにするパターンがあるんや。その場合、契約期間終了日過ぎてるやつはそのタイミングで切り替わるっちゅーことよな。

**Claude**:
せやせや、その通りや。

流れ：
1. QA検証で年払い機能をOFFにする
2. Task_5min が実行される（5分毎）
3. `convert_expired_annual_company_charge_type_to_monthly` が走る
4. `company_charge_period_end_date < 今日` の年払い企業が月払いに変換される

年払い機能OFFにした瞬間じゃなくて、次のTask_5min実行時に切り替わる。

## 本番環境への影響確認

**ユーザー**:
これってさ、本番環境では問題になるはずはないよな？常に月が跨った最初の5分バッチで切り替わるわけやから。ただあれか。契約終了後、無料期間に入って契約期間が更新されないとしたら、その間に次回の契約を年払いにしても、月払いに更新されてまうか。

**Claude**:
鋭いな。そのケースを整理すると：

シナリオ：
1. 企業が年払い契約、契約期間終了（例：2025-12-31）
2. 無料期間に入る（`company_charge_period_end_date = 2025-12-31` のまま）
3. 管理者が次回契約を年払い（`company_next_charge_type = ANNUAL`）に設定
4. 年払い機能OFFの銀行だと、次のTask_5minで月払いに戻される

**ただし**、年払い機能OFFの銀行では、そもそも「次回契約を年払いに設定する」という操作自体ができないはず。

本番で問題になるケース：
1. 年払い機能ONの銀行 → 早期リターンするから問題なし
2. 年払い機能OFFの銀行 → そもそも年払い設定できないはずやから問題なし
3. 途中でON→OFFに切り替えた銀行 → 既存の年払い企業が契約終了後に月払いに変換されるけど、意図した動作

## 結論

**ユーザー**:
なるほどな。確かにその通りや。年払いOFFだったら切り替えできないもんな。サンガツ。

**Claude**:
本番では問題にならない。QA環境みたいに設定をコロコロ変えるケースだけ注意が必要。