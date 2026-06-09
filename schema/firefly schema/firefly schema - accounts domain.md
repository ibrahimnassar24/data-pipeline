Based on the Firefly III schema represented in the ERD, the **Accounts domain** consists of the tables responsible for storing financial accounts, account types, balances, and account-specific metadata.

---

# 1. accounts

This is the central table of the Accounts domain.

| Column            |
| ----------------- |
| id                |
| created_at        |
| updated_at        |
| deleted_at        |
| account_type_id   |
| user_id           |
| account_role      |
| name              |
| virtual_balance   |
| iban              |
| active            |
| encrypted         |
| order             |
| include_net_worth |

### Purpose

Represents a financial account owned by a user.

Examples:

* Cash Wallet
* Checking Account
* Savings Account
* Credit Card
* Loan Account

### Relationships

```text
account_types (1)
        |
        +----< accounts >----+
                             |
                             v
                           users
```

---

# 2. account_types

Lookup table that defines the type of account.

| Column     |
| ---------- |
| id         |
| created_at |
| updated_at |
| type       |

### Purpose

Defines account categories such as:

* Asset
* Expense
* Revenue
* Liability
* Mortgage
* Debt

### Relationships

```text
account_types (1)
       |
       +----< accounts (many)
```

---

# 3. account_meta

Stores additional account properties.

| Column     |
| ---------- |
| id         |
| created_at |
| updated_at |
| account_id |
| name       |
| data       |

### Purpose

Provides extensible metadata without altering the accounts table.

Examples:

```text
Account: Savings

name  = bank_name
data  = Barclays

name  = branch
data  = London
```

### Relationships

```text
accounts (1)
      |
      +----< account_meta (many)
```

---

# 4. account_balances

Stores account balance snapshots.

| Column     |
| ---------- |
| id         |
| account_id |
| title      |
| balance    |
| date       |

### Purpose

Tracks historical balances.

Example:

```text
01-Jan-2026 -> £1,200
01-Feb-2026 -> £1,450
01-Mar-2026 -> £1,375
```

Useful for:

* Net worth calculations
* Trend reporting
* Historical charts

### Relationships

```text
accounts (1)
      |
      +----< account_balances (many)
```

---

# Account Domain Relationship Diagram

```text
users
  |
  +----< accounts >----+
                       |
                       v
                account_types
                       |
                       |
accounts
  |
  +----< account_meta

accounts
  |
  +----< account_balances
```

---

# Cardinality Summary

| Relationship                | Cardinality |
| --------------------------- | ----------- |
| users → accounts            | 1:N         |
| account_types → accounts    | 1:N         |
| accounts → account_meta     | 1:N         |
| accounts → account_balances | 1:N         |

---

# DDD Perspective

If you were implementing this domain in .NET with EF Core and DDD:

### Aggregate Root

```text
Account
```

### Child Entities

```text
AccountBalance
AccountMeta
```

### Reference Entity

```text
AccountType
```

A possible aggregate structure would look like:

```csharp
Account
{
    Id
    Name
    AccountTypeId

    ICollection<AccountBalance>
    ICollection<AccountMeta>
}
```

The **Account** aggregate is one of the most important aggregates in Firefly III because almost every transaction ultimately references one or more accounts. The next domain to study would typically be the **Transactions domain**, since it is directly connected to Accounts and contains the core accounting logic.
