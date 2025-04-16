terraform {
  source = "git@github.com:gruntwork-io/terraform-aws-security.git//modules/github-actions-openid-connect-provider?ref=v0.74.5"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  allowed_organizations = [
    "cryptocat-org",
  ]
}
