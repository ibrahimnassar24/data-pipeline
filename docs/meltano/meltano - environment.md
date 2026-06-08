by default the following 3 environments are added to your project dev, staging   and   prod.

There's also a     default_environment   setting in the   meltano.yml   that get  automatically set to   dev  

meltano environment list

# to activate the environment for the current shell session:
export MELTANO_ENVIRONMENT=dev

$ for powershell
$env:MELTANO_ENVIRONMENT="dev"

meltano environment add <environment name>