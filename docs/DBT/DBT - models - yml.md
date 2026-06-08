In a dbt project, `.yml` (or `.yaml`) files inside your `models/` directory act as the **configuration, testing, and documentation manual** for your SQL models.

While your `.sql` files contain the actual data transformation logic, the `.yml` files tell dbt (and your team) **what the data means, how it should behave, and who owns it.**

---

## 1. Where do they live and what are they named?

There is no strict rule about how many `.yml` files you can have, or what they must be named, as long as they live inside the `models/` directory. dbt scans the entire folder for any YAML file.

However, best practices dictate two common approaches:

1. **The Monolithic Approach:** One file named `_schema.yml` inside each subfolder (e.g., `models/staging/_schema.yml`) that configures all models in that specific folder.
2. **The Matched Approach:** A dedicated YAML file named exactly after the model (e.g., `customers.sql` paired with `customers.yml`). This is highly recommended for large, complex models.

---

## 2. The Anatomy of a Model `.yml` File

Here is a comprehensive breakdown of what an enterprise-grade `.yml` file looks like for a model:

```yaml
version: 2

models:
  - name: fct_orders
    description: "A fact table containing clean, grain-level transaction details for every customer order."
    config:
      materialized: table
      tags: ['finance', 'daily_run']
      
    columns:
      - name: order_id
        description: "The primary key for this table. Generated via hashing customer_id and order_date."
        tests:
          - unique
          - not_null

      - name: status
        description: "The current lifecycle stage of the order."
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned']

      - name: customer_id
        description: "Foreign key linking to dim_customers."
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id

```

---

## 3. The 4 Core Features Handled by `.yml` Files

### 📝 Documentation

The `description` tags at both the **model level** and **column level** feed directly into dbt’s documentation engine. When you run `dbt docs generate`, dbt scrapes these descriptions and builds a searchable UI website for your business users, data analysts, and stakeholders so they know exactly what `fct_orders` means without needing to read your SQL code.

### 🧪 Data Quality Testing

The `tests` block is where you declare data guardrails. dbt has four built-in tests that you can apply to any column natively:

* `unique`: Asserts that no two rows have the same value (crucial for primary keys).
* `not_null`: Asserts that the column never contains a blank or null value.
* `accepted_values`: Ensures the database only contains a strict list of allowed strings (e.g., preventing a status of `'confused'` if only `'shipped'` or `'completed'` are valid).
* `relationships`: Validates referential integrity (foreign keys). It checks if every `customer_id` in your orders table actually exists in your customers dimension table.

### ⚙️ Model-Level Configurations

While you *can* configure materializations (like `table` or `incremental`) inside the SQL file using `{{ config() }}` blocks, you can also manage them globally or group-by-group inside your YAML files. This keeps your SQL entirely focused on data logic.

### 🏷️ Tagging and Meta-Data

You can add custom `tags` or `meta` blocks (like data owners or Slack channels) to your models in YAML. This allows you to run targeted commands later, such as:

```bash
dbt run --select tag:finance

```

This command tells dbt to only build models that have the `finance` tag declared in their `.yml` file.

---

## 💡 Pro-Tip: Generating YAML Automatically

Writing YAML files by hand can be tedious and prone to indentation errors (since YAML relies strictly on spaces, not tabs). Data engineers rarely write these entirely from scratch.

Instead, you can use a dbt package called **codegen**. You can run a simple macro command in your terminal, and dbt will inspect your data warehouse table and output the baseline YAML structure for you to copy and paste:

```bash
dbt run-operation generate_model_yaml --args '{"model_names": ["fct_orders"]}'

```

This will print out the fully formatted YAML file with all column names already populated, leaving you only to type out the descriptions and tests.

Are you looking to add advanced testing (like custom SQL tests) to your YAML files, or are you setting up documentation tracking for your team?