Here is a complete, step-by-step guide to integrating and running **dbt** with **Meltano** using the PostgreSQL adapter (`dbt-postgres`).

This guide assumes you already have Python installed and a running instance of PostgreSQL.

### Prerequisites & Setup

Before adding dbt, you need a Meltano project.

1. **Install Meltano:**
```bash
pip install meltano

```


2. **Initialize your project:**
```bash
meltano init my-data-project
cd my-data-project

```



---

### Step 1: Install the `dbt-postgres` Transformer

Meltano manages dbt as a "transformer" plugin. You can add the specific adapter you need—in this case, Postgres—directly from MeltanoHub.

Run the following command to add it to your project:

```bash
meltano add dbt-postgres
meltano invoke dbt-postgres:initialize
```

*Note: Adding this plugin automatically creates a `transform/` directory in your Meltano project, which contains the scaffolding for your dbt project (including `dbt_project.yml` and `profiles.yml`).*

---

### Step 2: Configure the Database Connection

Next, configure dbt to talk to your Postgres instance. Meltano passes configurations down to dbt dynamically, so you do not need to manually edit the `profiles.yml` file.

You can configure the database credentials interactively:

```bash
meltano config dbt-postgres set --interactive

```

Alternatively, you can set the key parameters directly via the CLI. Replace the values in brackets with your actual database details:

```bash
meltano config dbt-postgres set host localhost
meltano config dbt-postgres set port 5432
meltano config dbt-postgres set user [your_db_user]
meltano config dbt-postgres set password [your_db_password]
meltano config dbt-postgres set dbname [your_db_name]
meltano config dbt-postgres set schema [your_target_schema]

```

To verify that your configuration is correct and dbt can connect to Postgres, run the debug command:

```bash
meltano invoke dbt-postgres:debug

```

---

### Step 3: Structuring Your Models

Navigate to the `transform/models/` directory. To maintain clean data engineering workflows, it is highly effective to organize your dbt models using a **Medallion Architecture** (Bronze, Silver, Gold).

Create subdirectories to logically separate your data transformations:

* **`bronze/` (Raw Data):** Views that cast raw ELT data into correct types and standard naming conventions without heavy logic.
* **`silver/` (Cleansed/Conformed Data):** Models that join tables, filter out bad records, and apply domain-driven design principles to establish core business entities.
* **`gold/` (Analytics-Ready Data):** Highly aggregated models and dimension/fact tables built specifically for reporting and analysis.

**Example of a simple Silver model (`transform/models/silver/slv_users.sql`):**

```sql
{{ config(materialized='table') }}

WITH raw_users AS (
    SELECT * FROM {{ source('public', 'raw_users') }}
)

SELECT 
    id AS user_id,
    LOWER(email) AS normalized_email,
    created_at::timestamp AS registered_at
FROM raw_users
WHERE is_active = true

```

---

### Step 4: Running dbt Commands via Meltano

Meltano acts as the control plane for dbt. You execute dbt commands using `meltano invoke`.

**To run all models:**

```bash
meltano invoke dbt-postgres:run

```

**To run a specific model (e.g., just the silver tier):**

```bash
meltano invoke dbt-postgres:run --select silver.*

```

**Other standard dbt commands:**

* **Test your data:** `meltano invoke dbt-postgres:test`
* **Compile SQL:** `meltano invoke dbt-postgres:compile`
* **Generate and serve docs:** ```bash
meltano invoke dbt-postgres:docs-generate
meltano invoke dbt-postgres:docs-serve
```


```



---

### Step 5: Integrating dbt into an ELT Pipeline

The true power of using dbt within Meltano is the ability to trigger your transformations immediately after your extraction and loading (EL) processes finish.

If you have an extractor (e.g., `tap-postgres` or `tap-csv`) and a loader (`target-postgres`) configured, you can chain them together with your dbt transformations in a single run:

```bash
meltano run tap-csv target-postgres dbt-postgres:run

```

Under the hood, Meltano will:

1. Extract data from the source.
2. Load it into your Postgres `dbname`.
3. Automatically execute `dbt deps` to pull any required packages.
4. Execute `dbt run` against the newly loaded data using your configured models.