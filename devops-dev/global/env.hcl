# Set common variables for the environment. This is automatically pulled in in the root root.hcl configuration to
# feed forward to the child modules.
locals {
  environment = basename(get_terragrunt_dir())
}
