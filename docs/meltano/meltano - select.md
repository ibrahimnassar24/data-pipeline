meltano select <plugin> --list --all

# For example:
meltano select tap-gitlab --list --all

note: If the previous command fails with an error message, it usually means that the Singer tap does not support   catalog discovery mode   and will always extract all supported entities and attributes.

meltano select <plugin> <entity> <attribute>
meltano select <plugin> --exclude <entity> <attribute>

# For example:
meltano select tap-gitlab commits id
meltano select tap-gitlab commits project_id
meltano select tap-gitlab commits created_at
meltano select tap-gitlab commits author_name
meltano select tap-gitlab commits message

# Include all attributes of an entity
meltano select tap-gitlab tags "*"

# Exclude matching attributes of all entities
meltano select tap-gitlab --exclude "*" "*_url"

meltano select <plugin> --list

# to verify that only the intended entities and attributes are now selected:
meltano select tap-gitlab --list