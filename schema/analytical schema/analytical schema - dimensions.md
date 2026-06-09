Here are all the **dimension tables** from the ERD and their columns.

## dim_user

| Column          | Type         |
| --------------- | ------------ |
| user_key        | INT (PK)     |
| user_id         | INT          |
| user_group_id   | BIGINT       |
| created_date    | DATE         |
| is_blocked      | BOOLEAN      |
| email           | VARCHAR(255) |
| user_group_name | VARCHAR(255) |
| user_role       | VARCHAR(255) |

---

## dim_account

| Column          | Type          |
| --------------- | ------------- |
| account_key     | INT (PK)      |
| account_id      | INT           |
| account_type_id | INT           |
| is_active       | BOOLEAN       |
| is_encrypted    | BOOLEAN       |
| created_date    | DATE          |
| valid_from      | DATE          |
| valid_to        | DATE          |
| is_current      | BOOLEAN       |
| version         | INT           |
| account_name    | VARCHAR(1024) |
| account_type    | VARCHAR(50)   |
| currency_code   | VARCHAR(10)   |

---

## dim_category

| Column             | Type          |
| ------------------ | ------------- |
| category_key       | INT (PK)      |
| category_id        | INT           |
| is_encrypted       | BOOLEAN       |
| parent_category_id | INT           |
| level              | INT           |
| category_name      | VARCHAR(1024) |

---

## dim_budget

| Column      | Type          |
| ----------- | ------------- |
| budget_key  | INT (PK)      |
| budget_id   | INT           |
| is_active   | BOOLEAN       |
| budget_name | VARCHAR(1024) |

---

## dim_currency

| Column         | Type         |
| -------------- | ------------ |
| currency_key   | INT (PK)     |
| currency_id    | INT          |
| decimal_places | INT          |
| is_enabled     | BOOLEAN      |
| code           | VARCHAR(10)  |
| name           | VARCHAR(255) |
| symbol         | VARCHAR(10)  |

---

## dim_date

| Column          | Type        |
| --------------- | ----------- |
| date_key        | INT (PK)    |
| full_date       | DATE        |
| year            | INT         |
| quarter         | INT         |
| month           | INT         |
| week            | INT         |
| week_start_date | DATE        |
| week_end_date   | DATE        |
| day_of_month    | INT         |
| day_of_week     | INT         |
| is_weekend      | BOOLEAN     |
| is_holiday      | BOOLEAN     |
| fiscal_year     | INT         |
| fiscal_quarter  | INT         |
| month_name      | VARCHAR(20) |
| day_name        | VARCHAR(10) |

---

## dim_tag

| Column          | Type                  |
| --------------- | --------------------- |
| tag_key         | BIGINT (PK)           |
| tag_id          | INT                   |
| tag_description | TEXT                  |
| parent_tag_key  | BIGINT (FK → dim_tag) |
| tag_level       | INT                   |
| is_root         | BOOLEAN               |
| is_leaf         | BOOLEAN               |
| child_count     | INT                   |
| hierarchy_depth | INT                   |
| usage_count     | INT                   |
| is_active       | BOOLEAN               |
| is_encrypted    | BOOLEAN               |
| valid_from      | TIMESTAMP             |
| valid_to        | TIMESTAMP             |
| is_current      | BOOLEAN               |
| version         | INT                   |
| created_at      | TIMESTAMP             |
| updated_at      | TIMESTAMP             |
| tag_name        | VARCHAR(255)          |
| tag_slug        | VARCHAR(255)          |
| tag_color       | VARCHAR(7)            |
| parent_tag_name | VARCHAR(255)          |
| tag_path        | VARCHAR(500)          |
| tag_type        | VARCHAR(50)           |

Example `tag_path`:

```text
/Expenses/Housing/Rent
```

Example `tag_type` values:

```text
System
User
Auto-generated
```

### Summary

The warehouse contains **7 dimension tables**:

1. `dim_user`
2. `dim_account`
3. `dim_category`
4. `dim_budget`
5. `dim_currency`
6. `dim_date`
7. `dim_tag`

The most sophisticated dimension is `dim_tag`, which implements a hierarchical tag structure with support for parent-child relationships, paths, versioning, and slowly changing dimension (SCD) attributes. The simplest dimensions are `dim_budget` and `dim_currency`, which act mainly as lookup dimensions.
