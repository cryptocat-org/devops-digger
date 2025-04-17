##test
locals {

  ### --- Base module

  # GitHub Tag/Branch
  base_version = "modules/aws/ecs_cluster/generic/v1.0.0"

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

  ### --- Resource locals

}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../../../../global/${local.region}/common/vpc/dev3"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs_merge_strategy_with_state  = "shallow"

  mock_outputs = {
    private_subnets  = ["subnet-123456"]
    vpc_id           = "vpc-12345678"
    vpc_cidr_block   = "10.0.0.0/16"
  }
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

  # On-demand: pay-as-you-go compute resource
  # Spot: Cheaper instances but can be interrupted with little notice because they rely on unused capacity. Suitable for workloads that can tolerate interruptions
  capacity_provider = "on-demand"

  instance_type = "t3.medium"
  min_size      = 1
  max_size      = 2

  # disable fargate
  default_capacity_provider_use_fargate = false
  enable_fargate_capacity_provider      = false

  # enable EC2 capacity_provider
  enable_ec2_capacity_provider = true

  # A list of subnet IDs to launch EC2 instances in
  vpc_zone_identifier = dependency.vpc.outputs.private_subnets

  # Where to create security group
  vpc_id = dependency.vpc.outputs.vpc_id

  # Allow traffic from Private network to EC2 machines
  ingress_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]
}

