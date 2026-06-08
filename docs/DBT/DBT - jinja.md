Welcome to the **Jinja for Data Engineering** crash course!

If you are using tools like **dbt** or **Apache Airflow**, you’ve likely seen weird syntax like `{{ ... }}` or `{% ... %}` sprinkled inside SQL scripts. That is Jinja.

Jinja is a text-templating engine written in Python. In data engineering, it turns static SQL into **dynamic, programmatic code**. It allows you to use loops, if/else logic, environment variables, and macros right inside your data warehouse queries.

---

## 1. The Core Syntax (The "Delimiters")

Jinja uses three primary pairs of delimiters. Memorize these, and you've mastered 50% of Jinja:

### `{{ ... }}` — Expressions (The "Print" Statement)

Used when you want to output a string, variable, or the result of a function directly into your SQL script.

* **Example:** `select * from {{ ref('stg_users') }}`
* **Compiles to:** `select * from analytics.stg_users`

### `{% ... %}` — Statements (The "Logic" Worker)

Used for control structures like loops (`for`), conditional statements (`if`), and variable declarations (`set`). These do not print anything to your SQL on their own; they control *how* the SQL is built.

* **Example:** `{% set payment_methods = ['credit_card', 'paypal', 'coupon'] %}`

### `{# ... #}` — Comments

Used to comment out code within Jinja. Unlike `-- SQL comments`, Jinja comments are stripped out *before* the code reaches your data warehouse, keeping production query logs completely clean.

---

## 2. Variables and Conditions (`if/else`)

You can define variables using `{% set ... %}` and conditionally generate SQL based on those variables or environment metadata.

### Scenario: Running different logic for Dev vs. Production

```sql
select
    order_id,
    amount,
    -- Only mask data if we are NOT in production
    {% if target.name != 'prod' %}
        HASH(customer_email) as customer_email
    {% else %}
        customer_email
    {% endif %}
from {{ ref('stg_orders') }}

```

If your dbt target is set to `dev`, Jinja compiles this to `HASH(customer_email) as customer_email`. If it's `prod`, it compiles to just `customer_email`.

---

## 3. The Power of Loops (`for`)

Imagine you have a table with a column called `payment_method` containing values like `credit_card`, `bank_transfer`, and `gift_card`. You need to pivot this table to create a column for each type.

Instead of typing repetitive `CASE WHEN` statements 20 times, you loop through them:

```sql
{% set payment_methods = ['credit_card', 'bank_transfer', 'gift_card'] %}

select
    order_id,
    {% for method in payment_methods %}
    sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount
    -- Add a comma after every item EXCEPT the last one in the loop
    {% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_payments') }}
group by 1

```

### What Jinja compiles this into for your warehouse:

```sql
select
    order_id,
    sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
    sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
    sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount
from analytics.stg_payments
group by 1

```

---

## 4. Reusable Code: Macros

Think of a **Macro** as a Python function, but written in Jinja/SQL. If you find yourself writing the exact same complex SQL snippet across multiple models, wrap it in a macro.

### Step 1: Define the Macro (e.g., in `macros/cents_to_dollars.sql`)

```sql
{% macro cents_to_dollars(column_name, decimal_places=2) %}
    round(cast({{ column_name }} as numeric) / 100, {{ decimal_places }})
{% endmacro %}

```

### Step 2: Call the Macro in any Model

```sql
select
    order_id,
    {{ cents_to_dollars('order_total_cents') }} as order_total_dollars
from {{ ref('stg_orders') }}

```

---

## 5. White-Space Control (The Secret Pro-Tip)

When Jinja compiles your code, it leaves behind a lot of blank rows and ugly spacing where the logic blocks used to be. While your database engine doesn't care, it makes reading compiled queries difficult.

To fix this, use a hyphen `-` right next to the percentage signs (`{%-` or `-%}`). This tells Jinja to strip out the whitespace/newlines from that side of the block.

```sql
-- Without whitespace control, this leaves ugly blank spaces in compiled SQL
{% if target.name == 'dev' %}
    limit 100
{% endif %}

-- Clean, stripped compiled code
{%- if target.name == 'dev' -%}
    limit 100
{%- endif -%}

```

---

## 🏁 Crash Course Summary

* Use `{{ }}` to inject values/names, and `{% %}` to write code logic.
* Use `ref()` and `source()` to build your warehouse lineage graph automatically.
* Use loops to eliminate massive, repetitive blocks of `CASE WHEN` or `UNION ALL` statements.
* Wrap repeating logic into Macros to keep your repository DRY (*Don't Repeat Yourself*).
