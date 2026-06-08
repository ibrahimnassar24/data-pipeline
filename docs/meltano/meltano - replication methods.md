meltano config set <plugin> _metadata <entity> replication-method <LOG_BASED|INCREMENTAL|FULL_TABLE>

# For example:
meltano config set tap-postgres _metadata some_entity_id replication-method INCREMENTAL
meltano config set tap-postgres _metadata other_entity replication-method FULL_TABLE

# Set replication-method metadata for all entities
meltano config set tap-postgres _metadata '*' replication-method INCREMENTAL

# Set replication-method metadata for matching entities
meltano config set tap-postgres _metadata '*_full' replication-method FULL_TABLE

# If you've set a table's   replication-method   to   INCREMENTAL  , also choose a     Replication Key   by setting the   replication-key   metadata:
meltano config set <plugin> _metadata <entity> replication-key <column>

# For example:
meltano config set tap-postgres _metadata some_entity_id replication-key updated_at
meltano config set tap-postgres _metadata some_entity_id replication-key id


# to verify that the stream metadata for each table was set correctly in the extractor's generated catalog file:
meltano invoke --dump=catalog <plugin>

# For example:
meltano invoke --dump=catalog tap-postgres