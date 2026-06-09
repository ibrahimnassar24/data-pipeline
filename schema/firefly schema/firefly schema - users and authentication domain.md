Here are all the tables that belong to the **Users & Authentication** domain in the ERD, along with their columns.

---

## users

| Column         | Type         |
| -------------- | ------------ |
| id             | INTEGER (PK) |
| created_at     | TIMESTAMP    |
| updated_at     | TIMESTAMP    |
| email          | VARCHAR      |
| password       | VARCHAR      |
| remember_token | VARCHAR      |
| reset          | VARCHAR      |
| blocked        | BOOLEAN      |
| blocked_code   | VARCHAR      |
| objectguid     | VARCHAR      |
| mfa_secret     | VARCHAR      |
| domain         | VARCHAR      |
| user_group_id  | INTEGER (FK) |

---

## user_groups

| Column     | Type         |
| ---------- | ------------ |
| id         | INTEGER (PK) |
| created_at | TIMESTAMP    |
| updated_at | TIMESTAMP    |
| deleted_at | TIMESTAMP    |
| title      | VARCHAR      |

---

## user_roles

| Column     | Type         |
| ---------- | ------------ |
| id         | INTEGER (PK) |
| created_at | TIMESTAMP    |
| updated_at | TIMESTAMP    |
| deleted_at | TIMESTAMP    |
| title      | VARCHAR      |

---

## group_memberships

| Column        | Type         |
| ------------- | ------------ |
| id            | INTEGER (PK) |
| created_at    | TIMESTAMP    |
| updated_at    | TIMESTAMP    |
| deleted_at    | TIMESTAMP    |
| user_id       | INTEGER (FK) |
| user_group_id | INTEGER (FK) |
| user_role_id  | INTEGER (FK) |

---

## 2fa_tokens

| Column     | Type         |
| ---------- | ------------ |
| id         | INTEGER (PK) |
| user_id    | INTEGER (FK) |
| expires_at | TIMESTAMP    |
| token      | VARCHAR      |

---

## invited_users

| Column      | Type         |
| ----------- | ------------ |
| id          | INTEGER (PK) |
| created_at  | TIMESTAMP    |
| updated_at  | TIMESTAMP    |
| user_id     | INTEGER (FK) |
| email       | VARCHAR      |
| invite_code | VARCHAR      |
| expires     | TIMESTAMP    |
| redeemed    | BOOLEAN      |
| expires_tz  | VARCHAR      |

---

## sessions

| Column        | Type         |
| ------------- | ------------ |
| id            | PK           |
| user_id       | INTEGER (FK) |
| ip_address    | VARCHAR      |
| user_agent    | VARCHAR      |
| payload       | TEXT         |
| last_activity | INTEGER      |

---

## preferences

| Column        | Type         |
| ------------- | ------------ |
| id            | INTEGER (PK) |
| created_at    | TIMESTAMP    |
| updated_at    | TIMESTAMP    |
| user_id       | INTEGER (FK) |
| name          | VARCHAR      |
| data          | TEXT         |
| user_group_id | INTEGER (FK) |

---

## roles

| Column       | Type         |
| ------------ | ------------ |
| id           | INTEGER (PK) |
| created_at   | TIMESTAMP    |
| updated_at   | TIMESTAMP    |
| name         | VARCHAR      |
| display_name | VARCHAR      |
| description  | TEXT         |

---

## permissions

| Column       | Type         |
| ------------ | ------------ |
| id           | INTEGER (PK) |
| created_at   | TIMESTAMP    |
| updated_at   | TIMESTAMP    |
| name         | VARCHAR      |
| display_name | VARCHAR      |
| description  | TEXT         |

---

## role_user

| Column  | Type         |
| ------- | ------------ |
| user_id | INTEGER (FK) |
| role_id | INTEGER (FK) |

**Purpose:** Many-to-many junction table between users and roles.

---

## permission_role

| Column        | Type         |
| ------------- | ------------ |
| permission_id | INTEGER (FK) |
| role_id       | INTEGER (FK) |

**Purpose:** Many-to-many junction table between permissions and roles.

---

## Relationship Summary

```text
users
 │
 ├── user_group_id ──────► user_groups
 │
 ├── 1:N ───────────────► sessions
 ├── 1:N ───────────────► preferences
 ├── 1:N ───────────────► invited_users
 └── 1:N ───────────────► 2fa_tokens


users
 │
 └── role_user ◄────► roles
                         │
                         └── permission_role ◄────► permissions


users
 │
 └── group_memberships
          │
          ├──► user_groups
          └──► user_roles
```

### Core entities in this domain

The most important tables are:

* **users** — user accounts
* **user_groups** — organizations / teams
* **user_roles** — role of a user within a group
* **group_memberships** — membership records
* **roles** — authorization roles
* **permissions** — authorization permissions

The remaining tables (**sessions**, **2fa_tokens**, **preferences**, **invited_users**, **role_user**, **permission_role**) provide supporting authentication and authorization functionality.

A logical next step would be to examine the cardinality of each relationship (1:1, 1:N, N:M) and determine which tables are aggregate roots versus child entities if you're planning to model this domain using DDD and Entity Framework.
