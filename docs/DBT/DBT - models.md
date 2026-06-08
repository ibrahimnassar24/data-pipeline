Welcome to the crash course on **dbt (Data Build Tool)** models!

If the Medallion Architecture is the blueprint for your data warehouse, **dbt is the factory engine**. It is the industry standard for the **"T" (Transform)** in ELT pipelines. It lets data engineers and analysts write modular, version-controlled SQL queries that dbt automatically builds into actual tables and views.

Let’s break down how dbt models work, from absolute basics to advanced practices.

---

## 1. What Exactly is a dbt Model?

In dbt, a **model** is simply a single `.sql` file inside your project's `models/` directory.

* Each file contains exactly **one `SELECT` statement**.
* You do *not* write `CREATE TABLE` or `INSERT INTO`.
* dbt handles all the heavy lifting (the DDL and DML) behind the scenes.

If you have a file named `models/customers.sql`, dbt will compile that SQL and run it in your data warehouse as a view or table named `customers`.

---

## 2. Materializations: Table vs. View vs. Incremental

How should that model exist in your warehouse? You control this using **materializations**. You define this at the top of your `.sql` file using a config block:

```sql
{{ config(materialized='table') }}

select * 
from {{ ref('stg_orders') }}

```

There are four primary materialization types:

* **`view` (Default):** dbt creates a virtual view. It builds instantly and takes up no storage, but queries run against it will rerun the underlying logic every time.
* **`table`:** dbt drops the old table and rebuilds a brand-new physical table from scratch every time you run it. Great for small-to-medium datasets where you want fast query performance for end-users.
* **`incremental`:** The holy grail for big data. dbt only appends or updates *new or modified* data since the last time the model ran. It saves massive amounts of cloud compute costs.
* **`ephemeral`:** This doesn't build anything in the warehouse at all. It acts like a reusable Common Table Expression (CTE) that gets interpolated into downstream models.

---

## 3. The Power of `{{ ref() }}` and `{{ source() }}`

The absolute golden rule of dbt is: **Never hardcode table names in your `FROM` clause.** Instead, you use Jinja (dbt's templating language) to handle dependencies.

### Connecting to Raw Data: `{{ source() }}`

When pulling data into dbt for the very first time (from your Bronze/Raw layer), register it in a `schema.yml` file and reference it like this:

```sql
select * from {{ source('jaffle_shop', 'raw_orders') }}

```

### Connecting Models Together: `{{ ref() }}`

When a model depends on *another* dbt model, use `ref()`.

```sql
select * from {{ ref('stg_customers') }}

```

**Why this matters:** `ref()` tells dbt exactly what order to run your models in. It automatically generates a **DAG (Directed Acyclic Graph)**—a visual lineage map of your entire data warehouse pipeline. If Model B depends on Model A, dbt makes sure Model A finishes building first.

---

## 4. The Standard Project Structure (The dbt Way)

To map dbt to your Medallion Architecture, modern analytics engineering teams structure their `models/` directory into three specific subfolders:

```text
models/
├── staging/      # (Bronze -> Silver boundary) Clean, cast, and rename raw data.
├── intermediate/ # (Inside Silver) Complex transformations, heavy joins.
└── marts/        # (Gold layer) Business-ready dimensions and facts for BI tools.

```

### Anatomy of a Perfect dbt Model (`marts/fct_orders.sql`)

Here is how an enterprise-grade dbt model looks, utilizing the **CTE-first style** (best practice for readability):

```sql
-- 1. Config Block
{{ config(materialized='table') }}

-- 2. Import CTEs (Bring in your dependencies up front)
with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

-- 3. Functional/Transformation CTE
final as (
    select
        orders.order_id,
        orders.customer_id,
        customers.first_name,
        customers.last_name,
        orders.order_date,
        orders.total_amount
    from orders
    left join customers on orders.customer_id = customers.customer_id
)

-- 4. Final Select (Keep it simple!)
select * from final

```

---

## 5. Testing and Documenting Your Models

A model isn't complete until it is tested and documented. This happens in a companion YAML file (usually named `_schema.yml` or matching the model name) in the same folder.

```yaml
version: 2

models:
  - name: fct_orders
    description: "A fact table containing clean, grain-level transaction details for every customer order."
    columns:
      - name: order_id
        description: "The primary key for this table."
        tests:
          - unique
          - not_null
      - name: total_amount
        tests:
          - accepted_values:
              values: ['completed', 'returned', 'shipped']

```

When you execute `dbt test` in your command line, dbt automatically generates and runs SQL queries to verify your data asserts those rules. If a `primary_key` is suddenly not unique, dbt throws an error and alerts you before that bad data reaches your BI tools.

---

## 🏁 The 4 Commands You Need to Know

Open your terminal in your project directory and run these to manage your models:

* `dbt run` — Compiles and builds all models into your data warehouse.
* `dbt run --select my_model` — Builds *only* the model named `my_model`.
* `dbt test` — Runs all data quality tests defined in your YAML files.
* `dbt docs generate && dbt docs serve` — Automatically builds an interactive website detailing your data documentation and lineage graph.

Are you getting ready to build out your first dbt repository, or are you looking to refactor some existing legacy SQL scripts into dbt models?