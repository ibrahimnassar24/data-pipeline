Based on the Firefly III ERD, the **Transactions domain** is the core accounting domain. It contains the entities that represent financial operations, transfers, currencies, transaction grouping, and links between transactions.

---

# 1. transaction_groups

Top-level container for related transaction journals.

| Column     |
| ---------- |
| id         |
| created_at |
| updated_at |
| title      |

### Purpose

Groups multiple transaction journals together.

Example:

```text
Monthly Salary
 ├─ Journal #1
 ├─ Journal #2
 └─ Journal #3
```

---

# 2. transaction_journals

The most important table in the domain.

| Column                  |
| ----------------------- |
| id                      |
| created_at              |
| updated_at              |
| deleted_at              |
| user_id                 |
| transaction_type_id     |
| transaction_group_id    |
| bill_id                 |
| transaction_currency_id |
| description             |
| date                    |
| order                   |
| completed               |
| encrypted               |
| foreign_amount          |
| foreign_currency_id     |

### Purpose

Represents a business transaction such as:

* Withdrawal
* Deposit
* Transfer

A journal acts as a container for one or more transaction rows.

---

# 3. transactions

Stores the actual accounting entries.

| Column                  |
| ----------------------- |
| id                      |
| created_at              |
| updated_at              |
| deleted_at              |
| transaction_journal_id  |
| account_id              |
| transaction_currency_id |
| amount                  |
| identifier              |
| reconciled              |

### Purpose

Represents one side of an accounting movement.

Example:

```text
Transfer £100

Journal
 ├─ Transaction: Checking  -100
 └─ Transaction: Savings   +100
```

### Relationships

```text
transaction_journals (1)
       |
       +----< transactions
```

---

# 4. transaction_types

Lookup table.

| Column |
| ------ |
| id     |
| type   |

### Common values

```text
Deposit
Withdrawal
Transfer
Opening Balance
```

### Relationships

```text
transaction_types (1)
        |
        +----< transaction_journals
```

---

# 5. transaction_currencies

Supported currencies.

| Column         |
| -------------- |
| id             |
| code           |
| name           |
| symbol         |
| decimal_places |
| enabled        |

### Examples

```text
USD
EUR
GBP
JPY
```

### Relationships

```text
transaction_currencies (1)
        |
        +----< transaction_journals

transaction_currencies (1)
        |
        +----< transactions
```

---

# 6. journal_meta

Extensible metadata for journals.

| Column                 |
| ---------------------- |
| id                     |
| created_at             |
| updated_at             |
| transaction_journal_id |
| name                   |
| data                   |

### Purpose

Stores additional journal properties without schema changes.

Example:

```text
name = merchant
data = Amazon
```

---

# 7. group_journals

Junction table.

| Column                 |
| ---------------------- |
| transaction_group_id   |
| transaction_journal_id |

### Purpose

Links groups and journals.

---

# 8. journal_links

Links journals together.

| Column             |
| ------------------ |
| id                 |
| created_at         |
| updated_at         |
| link_type_id       |
| inward_journal_id  |
| outward_journal_id |

### Purpose

Creates relationships between journals.

Example:

```text
Purchase
    |
Refund
```

---

# 9. link_types

Lookup table for journal relationships.

| Column  |
| ------- |
| id      |
| name    |
| inward  |
| outward |

### Example

```text
Refund Of
Repayment Of
Correction Of
```

---

# 10. transaction_currency_user

User-specific currency settings.

| Column                  |
| ----------------------- |
| user_id                 |
| transaction_currency_id |

### Purpose

Defines currencies available to a user.

---

# 11. transaction_currency_user_group

Group-specific currency settings.

| Column                  |
| ----------------------- |
| user_group_id           |
| transaction_currency_id |

### Purpose

Defines currencies available to a user group.

---

# 12. currency_exchange_rates

Exchange rates between currencies.

| Column           |
| ---------------- |
| id               |
| from_currency_id |
| to_currency_id   |
| rate             |
| date             |

### Purpose

Supports multi-currency transactions.

Example:

```text
GBP -> USD = 1.34
```

---

# Transaction Domain Relationship Map

```text
transaction_groups
       |
       +----< transaction_journals
                    |
                    |
                    +----< transactions
                    |
                    +----< journal_meta
                    |
                    +----< journal_links
                               |
                               v
                           link_types


transaction_types
        |
        +----< transaction_journals


transaction_currencies
        |
        +----< transaction_journals
        |
        +----< transactions


transaction_currencies
        |
        +----< currency_exchange_rates
        |
        +----< transaction_currency_user
        |
        +----< transaction_currency_user_group
```

# Cardinality Summary

| Relationship                                     | Cardinality |
| ------------------------------------------------ | ----------- |
| transaction_groups → transaction_journals        | 1:N         |
| transaction_types → transaction_journals         | 1:N         |
| transaction_journals → transactions              | 1:N         |
| transaction_journals → journal_meta              | 1:N         |
| link_types → journal_links                       | 1:N         |
| transaction_currencies → transactions            | 1:N         |
| transaction_currencies → transaction_journals    | 1:N         |
| transaction_currencies → currency_exchange_rates | 1:N         |
| users → transaction_currency_user                | 1:N         |
| user_groups → transaction_currency_user_group    | 1:N         |

# Most Important Tables

If you are trying to understand how Firefly III actually records money movements, focus on these four tables first:

```text
transaction_groups
        ↓
transaction_journals
        ↓
transactions
        ↓
accounts
```

Almost every financial operation ultimately flows through this chain. The `transaction_journals` table represents the business transaction, while the `transactions` table contains the actual debit/credit entries tied to accounts. This is the central accounting model of the application.
