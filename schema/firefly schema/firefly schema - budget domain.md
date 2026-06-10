Based on the Firefly III ERD, the **Budgets domain** is responsible for planning spending, tracking budget limits, and assigning transactions to budgets.

---

# 1. budgets

The main budget entity.

| Column     |
| ---------- |
| id         |
| created_at |
| updated_at |
| user_id    |
| name       |
| active     |
| order      |
| encrypted  |

### Purpose

Represents a spending budget.

Examples:

* Groceries
* Transportation
* Entertainment
* Rent

### Relationships

```text
users (1)
    |
    +----< budgets
```

---

# 2. budget_limits

Stores spending limits for budgets during a specific period.

| Column                  |
| ----------------------- |
| id                      |
| created_at              |
| updated_at              |
| budget_id               |
| transaction_currency_id |
| start_date              |
| end_date                |
| amount                  |

### Purpose

Defines how much money may be spent within a period.

Example:

```text
Groceries
Budget: £500

Start: 2026-06-01
End:   2026-06-30
```

### Relationships

```text
budgets (1)
    |
    +----< budget_limits

transaction_currencies (1)
    |
    +----< budget_limits
```

---

# 3. available_budgets

Stores the amount available for budgeting during a period.

| Column                  |
| ----------------------- |
| id                      |
| created_at              |
| updated_at              |
| transaction_currency_id |
| amount                  |
| start_date              |
| end_date                |

### Purpose

Represents the total amount available to distribute among budgets.

Example:

```text
Monthly Available Budget

June 2026
Amount: £2,000
```

### Relationships

```text
transaction_currencies (1)
    |
    +----< available_budgets
```

---

# 4. auto_budgets

Defines automatic budgeting rules.

| Column                  |
| ----------------------- |
| id                      |
| created_at              |
| updated_at              |
| user_id                 |
| transaction_currency_id |
| auto_budget_type        |
| amount                  |

### Purpose

Automatically generates budget allocations according to predefined rules.

Example:

```text
Allocate £200 monthly
to Entertainment budget
```

### Relationships

```text
users (1)
    |
    +----< auto_budgets

transaction_currencies (1)
    |
    +----< auto_budgets
```

---

# 5. budget_transaction

Junction table between budgets and transactions.

| Column         |
| -------------- |
| budget_id      |
| transaction_id |

### Purpose

Associates individual transaction rows with budgets.

### Relationships

```text
budgets
    |
    +---- budget_transaction ----+
                                 |
                                 v
                            transactions
```

---

# 6. budget_transaction_journal

Junction table between budgets and transaction journals.

| Column                 |
| ---------------------- |
| budget_id              |
| transaction_journal_id |

### Purpose

Associates entire transaction journals with budgets.

### Relationships

```text
budgets
    |
    +---- budget_transaction_journal ----+
                                         |
                                         v
                              transaction_journals
```

---

# 7. limit_repetitions

Defines recurring periods for budget limits.

| Column           |
| ---------------- |
| id               |
| created_at       |
| updated_at       |
| budget_limit_id  |
| repetition_type  |
| repetition_value |

### Purpose

Used to repeat budget limits automatically.

Examples:

```text
Monthly
Weekly
Quarterly
Yearly
```

### Relationships

```text
budget_limits (1)
      |
      +----< limit_repetitions
```

---

# Budget Domain Relationship Diagram

```text
users
  |
  +----< budgets
  |
  +----< auto_budgets

budgets
  |
  +----< budget_limits
  |
  +---- budget_transaction
  |
  +---- budget_transaction_journal

budget_limits
  |
  +----< limit_repetitions

transaction_currencies
  |
  +----< budget_limits
  |
  +----< available_budgets
  |
  +----< auto_budgets

transactions
  |
  +---- budget_transaction

transaction_journals
  |
  +---- budget_transaction_journal
```

---

# Cardinality Summary

| Relationship                               | Cardinality |
| ------------------------------------------ | ----------- |
| users → budgets                            | 1:N         |
| users → auto_budgets                       | 1:N         |
| budgets → budget_limits                    | 1:N         |
| budget_limits → limit_repetitions          | 1:N         |
| budgets ↔ transactions                     | N:M         |
| budgets ↔ transaction_journals             | N:M         |
| transaction_currencies → budget_limits     | 1:N         |
| transaction_currencies → available_budgets | 1:N         |
| transaction_currencies → auto_budgets      | 1:N         |

---

# DDD Perspective

### Aggregate Roots

```text
Budget
AvailableBudget
AutoBudget
```

### Child Entities

```text
BudgetLimit
LimitRepetition
```

### Junction Entities

```text
BudgetTransaction
BudgetTransactionJournal
```

### Typical Aggregate Structure

```csharp
Budget
{
    Id;
    Name;

    ICollection<BudgetLimit> Limits;
}
```

The **Budget** aggregate is primarily concerned with *planning* and *categorizing spending*. Actual money movement is still recorded in the **Transactions domain**, while the Budget domain answers questions such as:

* How much can I spend?
* How much have I spent?
* Did I exceed my budget?
* What is my remaining budget for the month?
