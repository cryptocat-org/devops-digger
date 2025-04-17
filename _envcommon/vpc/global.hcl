###### Test
locals {

  ### --- Base module

  # GitHub Tag/Branch
  base_version = "modules/aws/vpc/generic/v1.0.0"

  # Module Path
  base_module = ""

  # Github URL
  base_source = "git::ssh://git@github.com/cryptocat-org/modules.git/${local.base_module}?ref=${local.base_version}"

  ### --- Get envs from files in folders

  # Automatically load env-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load namespace-level variables
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl"))

  ### --- Extract variables

  # Extract out resource name
  name = basename(get_terragrunt_dir())

  # Extract out account variables for reuse
  aws_profile = local.account_vars.locals.aws_profile

  # Extract project name from directory name
  namespace = local.namespace_vars.locals.namespace

  # Extract Environment of the resource
  environment = local.env_vars.locals.environment

  # Extract AWS region of the resouce
  region = local.region_vars.locals.aws_region

}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

  ### --- Global Labels

  # The name of the component
  name = local.name

  # Used for project e.g. 'misc', 'pay88'
  namespace = local.namespace

  # Resource region e.g. 'eu-north-1', 'eu-central-1'
  region = local.region

  # The environment of the resource, such as l, s, t1
  environment = local.environment

  # Extra tags
  tags = {
  }

  ### --- Resource variables

  # The primary IPv4 CIDR block for the VPC
  vpc_cidr = "10.10.0.0/16"

  # Use a single NAT Gateway for all subnets
  single_nat_gateway = "true"

}
