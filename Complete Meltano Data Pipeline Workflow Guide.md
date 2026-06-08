
## Complete Meltano Data Pipeline Workflow Guide

This guide walks you through setting up an end-to-end ELT (Extract, Load, Transform) data pipeline using Meltano, PostgreSQL, and dbt.

---

### Step 1: Environment Setup

Before initializing the project, you need to set up an isolated Python environment and install Meltano.

* Create a virtual environment:

```bash
python -m venv .venv

```

* Activate the virtual environment:

```bash
.\.venv\Scripts\activate

```

* Install Meltano using pip:

```bash
python -m pip install meltano

```

* Save your dependencies:

```bash
pip freeze > requirements.txt

```

### Step 2: Initialize the Project

Create a new Meltano project to house your pipeline configurations.

* Initialize the Meltano project:

```bash
meltano init pipeline

```

* Navigate into your new project directory:

```bash
cd .\pipeline

```

### Step 3: Configure the Extractor (Source Database)

Set up the connection to the source database where your raw data lives.

* Add the PostgreSQL extractor:

```bash
meltano add tap-postgres

```

* Set up the configuration interactively:

```bash
meltano config set tap-postgres --interactive

```

* Alternatively, configure the connection details via the command line:

```bash
meltano config set tap-postgres host localhost
meltano config set tap-postgres user postgres
meltano config set tap-postgres password 123@Bc
meltano config set tap-postgres database finance
meltano config set tap-postgres port 5432

```

* Select the schemas and tables you want to extract (e.g., all public tables):

```bash
meltano select tap-postgres "public-*" "*"

```

* You can verify the extractor works by invoking it:

```bash
meltano invoke tap-postgres

```

### Step 4: Configure the Loader (Destination Database)

Next, configure where Meltano will load the extracted data.

* Add the PostgreSQL target:

```bash
meltano add target-postgres

```

* Configure the destination database connection:

```bash
meltano config set target-postgres host localhost
meltano config set target-postgres user postgres
meltano config set target-postgres password 123@Bc
meltano config set target-postgres database analytical
meltano config set target-postgres port 5432

```

* Specify the target schema for the raw data:

```bash
meltano config set target-postgres default_target_schema raw

```

### Step 5: Setup Transformation (dbt)

Once the data is loaded, you will use dbt to transform it into analytics-ready models.

* Add the dbt plugin for PostgreSQL:

```bash
meltano add dbt-postgres

```

* Configure dbt interactively:

```bash
meltano config set dbt-postgres --interactive

```

* Provide your transformation database credentials:
* **dbname**: `analytical`
* **host**: `localhost`
* **port**: `5432`
* **schema**: `trm`
* **user**: `postgres`


* Initialize the dbt project:

```bash
meltano invoke dbt-postgres:initialize

```

### Step 6: Define dbt Sources and Models

Define your raw data sources and create transformation models.

* Create a `source.yml` file to define the raw data location:

```yaml
version: 2

sources:
  - name: finance_raw
    database: analytical
    schema: raw
    tables:
      - name: transactions

```

*(Note: The table `transactions` is defined in the source file)*

* Create an SQL file for your model to select transaction types:

```sql
with transaction_types as (
    select transaction_type
    from {{ source('finance_raw', 'transactions') }}
    group by transaction_type
)

select transaction_type as transaction_types
from transaction_types

```

* Create a YAML file for the model configuration (`dim_transaction_types`) to define it as a table, describe columns, and run tests:

```yaml
version: 2

models:
  - name: dim_transaction_types
    description: "A dimension table for transaction types."
    config:
      materialized: table
    columns:
      - name: transaction_types
        description: "The unique identifier for the transaction type."
        tests:
          - unique
          - not_null # Recommended for a dimension primary key

```

*(Note: The `unique` and `not_null` tests are applied to the column)*

### Step 7: Managing Configurations

You can easily tweak your setup later using configuration files.

* **Extractor configuration**: Modify the extractor settings and its table selections in the `meltano.yml` file.
* **Loader configuration**: Change where the data is loaded by updating the loader settings in `meltano.yml`.
* **dbt Sources**: Update the source data definitions for dbt inside `transform/models/source.yml`.
* **Transformation destination**: Modify where the transformed dbt data is stored by checking the utilities section in `meltano.yml`.

### Step 8: Run the Pipeline

With everything configured, you can execute the entire Extract, Load, and Transform process with a single command.

* Run the pipeline using the following command:

```bash
meltano run tap-postgres target-postgres dbt-postgres:run

```