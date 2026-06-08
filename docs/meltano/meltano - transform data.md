# install adapter-specific dbt, e.g. for snowflake
# Simplified syntax - plugin type is automatically detected
meltano add dbt-snowflake  # Automatically detected as utility

# Explicit plugin type for disambiguation:
# meltano add --plugin-type utility dbt-snowflake

note After dbt is installed you can configure it using   config   CLI commands,     Meltano environments   or environment variables:

# list available settings
meltano config list dbt-snowflake

# configure the `dev` environment interactively
meltano --environment=dev config dbt-snowflake set --interactive

# configure the `prod` environment interactively
meltano --environment=prod config dbt-snowflake set --interactive


note: There are two ways to run dbt utility plugins using Meltano; in a pipeline using the     run   command or standalone with arguments using the     invoke   command.
meltano --environment=dev run tap-gitlab target-snowflake dbt-snowflake:run

# run your entire dbt project
meltano invoke dbt-snowflake run

# run with node selection criteria
meltano invoke dbt-snowflake run --select +my_model_name

# run with a command specified in meltano.yml
meltano invoke dbt-snowflake:my_models
