locals {

  ### --- Get envs from files in folders

  # Automatically load env-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  ### --- Extract variables

  # Extract out account variables for reuse
  aws_profile = local.account_vars.locals.aws_profile

  # Extract AWS region of the resouce
  region = local.region_vars.locals.aws_region

  ### --- Terrafrom state bucket

  # Terraform state bucket
  bucket         = "yolo-terraform-${local.aws_profile}"
  dynamodb_table = "yolo-terraform-${local.aws_profile}"
  backend_region = "eu-central-1"

}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"

  # Only these AWS Account Profiles may be operated on by this template
  profile = "${local.aws_profile}"
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt               = true
    bucket                = local.bucket
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    region                = local.backend_region
    profile               = local.aws_profile
    dynamodb_table        = local.dynamodb_table
    disable_bucket_update = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repos to search when you run 'terragrunt catalog'
catalog {
  urls = [
    "https://github.com/coingaming/skeleton-infra",
    "https://github.com/coingaming/infra-modules"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `root.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals
)
