# to view the supported settings
meltano config list <plugin name.

meltano config set <plubin_name> <setting_name> ,setting_value>
# to verify that the configuration looks like what the Singer target expects according to its documentations:
meltano config print <plugin_name.


note: Sensitive configuration information (such as   password  ) will instead be stored in your project's     .env    file   so that it will not be checked into version control:
export TARGET_POSTGRES_PASSWORD=meltano