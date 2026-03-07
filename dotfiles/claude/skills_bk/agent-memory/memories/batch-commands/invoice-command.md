---
summary: "InvoiceCommand (create:invoices) で作成・更新されるデータの一覧"
created: 2026-01-07
tags: [batch, invoice, charges]
related: [application/app/Console/Commands/InvoiceCommand.php]
---

# InvoiceCommand

深夜定期バッチ: `php artisan create:invoices`

## 作成されるデータ

| テーブル | 説明 |
|---------|------|
| invoices | インボイスデータ |
| invoice_items | インボイス明細データ |
| charge_blacklists | xba.charge_itemsに該当データがない場合に登録 |

## 更新されるデータ

| テーブル | カラム | 説明 |
|---------|--------|------|
| bam.charges | invoice_id | 作成したinvoice_idを反映 |
| xba.charges | invoice_id | setXbaCharges() / recoveryXbaCharges() で更新 |

## 処理の流れ

1. `charges`テーブルから`invoice_id=0`のデータを取得
2. `invoices`と`invoice_items`を作成
3. 作成した`invoice_id`を`bam.charges`と`xba.charges`に反映