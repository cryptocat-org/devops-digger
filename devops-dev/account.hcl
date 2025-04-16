# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# root.hcl configuration.
locals {
  aws_profile = basename(get_terragrunt_dir())
}
