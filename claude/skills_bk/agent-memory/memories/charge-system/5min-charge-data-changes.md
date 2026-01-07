---
summary: "5min.php charge()メソッドで作成・更新されるテーブルとカラムの一覧"
created: 2026-01-07
tags: [charge, billing, database, 5min-task]
related: [src/xba/packages/xbacore/classes/task/5min.php, src/xba/packages/xbacore/classes/model/charge.php]
---

# charge()メソッド（5min.php:123-161）のデータ変更一覧

## テーブル別操作サマリー

| テーブル | INSERT | UPDATE | DELETE |
|---------|--------|--------|--------|
| charges | ✓ | ✓ | ✓ |
| charge_items | ✓ | - | - |
| charge_histories | ✓ | ✓ | - |
| companies | - | ✓ | - |

## メソッド別詳細

### 1. Model_Charge::create_ng_notice()
- **テーブル**: charge_histories
- **操作**: UPDATE
- **カラム**: `ch_ng_notified_at`
- **処理**: NGステータスの課金履歴に通知済みフラグを設定

### 2. Model_Company::convert_expired_annual_company_charge_type_to_monthly()
- **テーブル**: companies
- **操作**: UPDATE
- **カラム**: `company_next_charge_type`, `company_next_charge_amount`
- **処理**: 年払い機能OFF時、契約満了の年払い企業を月払いに自動転換

### 3. create_this_month_charges() - 月払い課金作成
- **テーブル**: charges, charge_items, companies
- **操作**: INSERT (charges, charge_items), UPDATE (companies)
- **chargesカラム**: `charge_id`, `charge_company_id`, `charge_type`(MONTHLY), `charge_amount`, `charge_tax_amount`, `charge_period_start_date`, `charge_period_end_date`
- **charge_itemsカラム**: `ci_charge_id`, `ci_type`, `ci_unit_price`, `ci_qty`, `ci_title`, `ci_is_annual`(false), `ci_subtotal`, `ci_tax_amount`
- **companiesカラム**: `company_charge_type`, `company_charge_amount`, `company_charge_period_start_date`, `company_charge_period_end_date`

### 4. create_this_annual_charges() - 年払い課金作成
- **テーブル**: charges, charge_items, companies
- **操作**: INSERT (charges, charge_items), UPDATE (companies)
- **chargesカラム**: `charge_id`, `charge_company_id`, `charge_type`(ANNUAL), `charge_amount`, `charge_tax_amount`, `charge_period_start_date`, `charge_period_end_date`
- **charge_itemsカラム**: `ci_charge_id`, `ci_type`, `ci_unit_price`, `ci_qty`, `ci_title`, `ci_is_annual`(true), `ci_subtotal`, `ci_tax_amount`
- **companiesカラム**: `company_charge_type`, `company_charge_amount`, `company_charge_period_start_date`, `company_charge_period_end_date`

### 5. create_this_monthly_option_charges() - 年払い期間中の月次オプション課金
- **テーブル**: charges, charge_items
- **操作**: INSERT/DELETE (charges), INSERT (charge_items)
- **chargesカラム**: `charge_type`(MONTHLY), `charge_amount`, `charge_tax_amount`
- **charge_itemsカラム**: `ci_type`, `ci_unit_price`, `ci_qty`, `ci_title`, `ci_is_annual`(false)
- **処理**: 年払い契約中の企業に月次オプション（ビジネスユーザー従量課金、ちゃんと請求書等）を作成。オプション0件なら課金データ自体を削除

### 6. Model_Charge::execute_charges() - 課金実行
- **テーブル**: charges, charge_histories
- **操作**: UPDATE (charges), INSERT (charge_histories)
- **chargesカラム**: `charge_status`(OK/NG/NG_UNKNOWN), `charge_ng_message`
- **処理**: 実行予定日時に達した課金を決済実行。0円は強制完了、カードなし/マイナス金額はNG設定
