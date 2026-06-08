In the world of data engineering, **dbt (data build tool)** is the "T" in **ELT** (Extract, Load, Transform).

Since you’ve already decided to use **Postgres** as your warehouse, dbt acts as the orchestration layer that sits on top of it. It allows you to write SQL and treats it like software code—complete with version control, testing, and documentation.

---

### 1. The Core Concept: "SQL with Superpowers"

In a standard database, you might create a view or a table by manually running a `CREATE TABLE AS...` statement. If you change a column name, you have to remember to update every other table that depends on it.

**dbt** changes this. You write simple `SELECT` statements in `.sql` files, and dbt handles the "boilerplate" (the `CREATE` or `REPLACE` commands) for you.

### 2. The Four Pillars of dbt

#### A. Modularization (The `ref` function)

Instead of one giant, 500-line SQL script, dbt lets you break your logic into small, reusable models.

* You might have one model for `stg_transactions`.
* You then "reference" it in your `fct_monthly_spending` model.
* If `stg_transactions` changes, dbt automatically knows to update everything downstream.

#### B. Version Control (Git)

Because dbt is code-based, you can keep your entire financial logic in **GitHub**. If you make a mistake in your calculation for "Future Expenditure," you can simply "roll back" to a previous version of your logic.

#### C. Testing (Data Quality)

This is critical for your prediction system. You can tell dbt: *"The 'amount' column should never be null,"* or *"The 'category' should only be one of these 10 names."*
Every time you transform your data, dbt runs these tests. If your Firefly data has an error, dbt warns you **before** that bad data hits your prediction model.

#### D. Documentation

dbt automatically generates a website for you that shows a **Lineage Graph**. It’s a visual map showing exactly how your raw Firefly API data travels through various SQL files to become the final table used for your monthly predictions.

---

### 3. How dbt fits into your specific project

When you run dbt against your Postgres database, here is what happens:

1. **You write:** `SELECT * FROM {{ ref('stg_firefly_data') }} WHERE category = 'Utilities'`
2. **dbt compiles:** It turns that into a proper Postgres SQL statement with the correct schema names.
3. **dbt executes:** It tells Postgres to create a new **Table** or **View** with that data.

### Why is this better than just writing SQL scripts?

Without dbt, you would have a folder full of `.sql` files and you’d have to remember which one to run first. With dbt, you just type `dbt run` in your terminal. It looks at your code, figures out the dependencies (e.g., "I must clean the categories before I can calculate the monthly average"), and executes them in the perfect order.

**In short:** dbt turns your Postgres database into a professional **data factory** rather than just a storage bin.

Does the idea of managing your SQL as "code" (with Git and testing) feel like a natural extension of your development workflow?

-------
DBT workflow

Since you are already comfortable with the .NET ecosystem and Clean Architecture, you will find that **dbt** brings those same "software engineering" disciplines to the world of data.

A complete dbt workflow is built around a cycle of **Develop → Test → Deploy → Document**. Here is how you would implement it for your Firefly III analytics system.

---

### 1. Initialization & Setup

First, you create your environment. Since you’re aiming for "Professional Grade," you’ll use a local Python virtual environment.

* **Install dbt:** `pip install dbt-postgres`
* **Initialize project:** `dbt init firefly_analytics`
* **Configure Profile:** You edit a `profiles.yml` file to give dbt the "keys" to your Postgres database.

---

### 2. The "Source" Declaration

Before writing logic, you tell dbt where your raw data lives. You define your **Sources** in a YAML file. This tells dbt: "Look in the `raw` schema of Postgres for a table called `firefly_api_dump`."

> **Pro Tip:** This is where you define "Freshness." You can tell dbt to warn you if your Firefly data hasn't been updated in more than 24 hours.

---

### 3. The Development Phase (Models)

This is where you write your SQL. In dbt, everything is a `SELECT` statement. You don't write `CREATE TABLE`; dbt handles that.

#### A. Staging Layer (`stg_transactions.sql`)

You "clean" the raw API data. You cast strings to dates, rename columns to be more readable, and handle null values.

```sql
-- Using the {{ source() }} function to link to your raw data
SELECT
    (payload->>'id')::int as transaction_id,
    (payload->>'date')::date as transaction_date,
    (payload->>'amount')::decimal as amount,
    payload->>'description' as description
FROM {{ source('firefly', 'api_dump') }}

```

#### B. Mart Layer (`fct_monthly_expenditure.sql`)

You build the final table your prediction model will use. You use the `{{ ref() }}` function to point to your staging model. This creates a **lineage** (a dependency map).

---

### 4. The Testing Phase

Before you trust your data for predictions, you test it. You add a `schema.yml` file where you define rules for your data:

* **Unique:** Ensure transaction IDs aren't duplicated.
* **Not_Null:** Ensure amounts are always present.
* **Accepted_Values:** Ensure categories match your expected list.

You run these with: `dbt test`. If a test fails, you know your prediction model will receive "garbage," and you can fix it before running the forecast.

---

### 5. The "Run" Phase (Materialization)

When you are happy with your code and tests, you execute:
`dbt run`

dbt looks at your dependency graph. It sees that `fct_monthly_expenditure` depends on `stg_transactions`. It will automatically:

1. Run the staging SQL and create a view in Postgres.
2. Run the mart SQL and create a table in Postgres.

---

### 6. Documentation & Lineage

dbt can generate a full documentation website for your financial warehouse.

* **Command:** `dbt docs generate` followed by `dbt docs serve`.
* **Result:** A searchable website showing every column definition, the SQL code used to create it, and a visual graph of how data flows from Firefly III to your "Gold" tables.

---

### 7. Deployment (The "Production" Cycle)

In a professional setup, you wouldn't just run this manually.

1. **Orchestration:** You’d use a tool like **Cron** or **GitHub Actions** to run your Python "Extraction" script first.
2. **Transformation:** Immediately after, it triggers `dbt build` (which runs models and tests in one go).
3. **Prediction:** Finally, your Python prediction script runs, knowing the Postgres data is fresh, tested, and clean.

### Summary of Commands

| Command | What it does |
| --- | --- |
| `dbt seed` | Uploads static CSVs (like a list of "Fixed Expenses") to your DB. |
| `dbt run` | Transforms the data into models. |
| `dbt test` | Checks data quality. |
| `dbt build` | **(The Pro Way)** Runs, tests, and seeds everything in order. |

Does this workflow feel like a manageable "Data Version" of the software development lifecycle you're already used to?

-----

In a **dbt** project, your `SELECT` statements are written in **`.sql` files** located inside the `models/` directory of your project folder.

Since you are familiar with .NET and Clean Architecture, think of these `.sql` files as your **Domain Logic** or **Services layer**, but written in SQL instead of C#.

---

### 1. Where they live (The Directory Structure)

When you run `dbt init`, it creates a structured folder system. You organize your `SELECT` statements based on their purpose:

```text
firefly_analytics/
├── dbt_project.yml
├── models/
│   ├── staging/          <-- "Bronze" layer: Raw cleanup
│   │   └── stg_transactions.sql
│   ├── intermediate/     <-- "Silver" layer: Joins and business logic
│   │   └── int_monthly_trends.sql
│   └── marts/            <-- "Gold" layer: Final tables for your predictions
│       └── fct_expenditure_forecast_base.sql

```

---

### 2. How they are written

Each file contains exactly **one** `SELECT` statement. You do not write `CREATE TABLE`, `INSERT`, or `DROP`. dbt wraps your `SELECT` in the necessary code to build the table in Postgres.

**Example: `models/staging/stg_transactions.sql**`

```sql
{{ config(materialized='view') }} -- Tells dbt to make this a View

SELECT
    (data->>'id')::int as transaction_id,
    (data->>'amount')::decimal as amount,
    (data->>'date')::date as transaction_date,
    data->>'description' as description
FROM {{ source('firefly_raw', 'transactions_json') }}

```

---

### 3. The "Glue" (The `ref` and `source` functions)

The most important part of where you write these statements is how you link them. Instead of hardcoding table names like `raw_schema.api_table`, you use Jinja templates (the `{{ }}` syntax).

* **`{{ source() }}`**: Points to the raw data your Python script uploaded.
* **`{{ ref() }}`**: Points to *another* `.sql` file in your models folder.

### 4. Why this matters for your prediction system

By writing your SQL statements in separate files:

1. **Readability:** You don't have one massive, 500-line query. You have small, testable chunks.
2. **Lineage:** dbt looks at your files and automatically builds a "Dependency Graph." It knows it must run `stg_transactions.sql` **before** it runs `fct_monthly_expenditure.sql`.
3. **Efficiency:** When you run `dbt run`, dbt communicates with Postgres to execute all these files in the correct order.

---

### The Workflow in practice:

1. You open **VS Code** (or your favorite editor).
2. You create a new file: `models/marts/fct_daily_spend.sql`.
3. You write your `SELECT` statement using the `ref` function to pull from your staging models.
4. You run `dbt run` in your terminal.
5. **Postgres** now has a brand new table with your cleaned data, ready for your Python prediction script.

Does this "one file per table" structure feel like a good way to organize your 3 years of financial history?