# Set common variables for the namespace. This is automatically pulled in in the root root.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  namespace = basename(get_terragrunt_dir())
}
