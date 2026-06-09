Based on the ERD, the **fact tables** are the tables that store measurable business events and metrics.

# 1. fact_transaction

This is the central transactional fact table.

## Columns

| Column               | Type                    |
| -------------------- | ----------------------- |
| transaction_key      | BIGINT (PK)             |
| transaction_id       | INT                     |
| transaction_date_key | INT (FK → dim_date)     |
| entry_date_key       | INT (FK → dim_date)     |
| account_key          | INT (FK → dim_account)  |
| counter_account_key  | INT (FK → dim_account)  |
| category_key         | INT (FK → dim_category) |
| budget_key           | INT (FK → dim_budget)   |
| user_key             | INT (FK → dim_user)     |
| amount               | DECIMAL(20,4)           |
| foreign_amount       | DECIMAL(20,4)           |
| exchange_rate        | DECIMAL(10,6)           |
| description          | TEXT                    |
| transaction_type     | VARCHAR(50)             |
| is_reconciled        | BOOLEAN                 |
| has_attachment       | BOOLEAN                 |
| tag_count            | INT                     |
| created_at           | TIMESTAMP               |

## Measures

The numeric measures that can be aggregated:

```text
amount
foreign_amount
exchange_rate
tag_count
```

## Grain

One row represents:

```text
One financial transaction
```

Example:

```text
User: John
Account: Checking
Category: Food
Amount: 25.50
Date: 2026-06-01
```

---

# 2. fact_daily_balance

Stores daily account balance snapshots.

## Columns

| Column                  | Type                   |
| ----------------------- | ---------------------- |
| balance_key             | BIGINT (PK)            |
| date_key                | INT (FK → dim_date)    |
| account_key             | INT (FK → dim_account) |
| user_key                | INT (FK → dim_user)    |
| opening_balance         | DECIMAL(20,4)          |
| closing_balance         | DECIMAL(20,4)          |
| total_credit            | DECIMAL(20,4)          |
| total_debit             | DECIMAL(20,4)          |
| transaction_count       | INT                    |
| tag_aggregated_balances | JSONB                  |
| created_at              | TIMESTAMP              |

## Measures

```text
opening_balance
closing_balance
total_credit
total_debit
transaction_count
```

## Grain

One row represents:

```text
One account balance snapshot for one day
```

Example:

```text
Date: 2026-06-01
Account: Checking

Opening Balance: 1000
Closing Balance: 850

Credits: 200
Debits: 350
```

---

# Fact Tables Summary

| Fact Table           | Grain                       |
| -------------------- | --------------------------- |
| `fact_transaction`   | One row per transaction     |
| `fact_daily_balance` | One row per account per day |

---

# Foreign Key Relationships

## fact_transaction

```text
fact_transaction
│
├── transaction_date_key → dim_date
├── entry_date_key       → dim_date
├── account_key          → dim_account
├── counter_account_key  → dim_account
├── category_key         → dim_category
├── budget_key           → dim_budget
└── user_key             → dim_user
```

---

## fact_daily_balance

```text
fact_daily_balance
│
├── date_key    → dim_date
├── account_key → dim_account
└── user_key    → dim_user
```

---

# Bridge Fact-Like Table

The ERD also contains:

**bridge_transaction_tag**

| Column           |
| ---------------- |
| transaction_key  |
| tag_key          |
| is_primary_tag   |
| confidence_score |
| tagged_by        |
| tagged_at        |

This is **not a fact table** and **not a dimension table**. It is a **bridge table** used to implement a many-to-many relationship between `fact_transaction` and `dim_tag`.

So the warehouse contains:

* **7 dimensions**
* **2 facts**
* **1 bridge table**
* **6 prediction/ML tables** (`pred_*`) that serve analytical and machine-learning workloads rather than traditional star-schema facts.
