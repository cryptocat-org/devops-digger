terraform {
  source = "git@github.com:gruntwork-io/terraform-aws-security.git//modules/github-actions-iam-role?ref=v0.74.5"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# The OIDC IAM roles for GitHub Actions require an IAM OpenID Connect (OIDC) Provider to be provisioned for each account.
# The underlying module used in `envcommon` is capable of creating the OIDC provider. Since multiple OIDC roles are required, 
# a dedicated module is used, and all roles depend on its output.
dependency "github-actions-openid-connect-provider" {
  config_path = "../github-actions-openid-connect-provider"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    arn = "known_after_apply"
    url = "token.actions.githubusercontent.com"
  }
}

locals {
  # Automatically load account-level variables
  state_bucket_pattern = "yolo-terraform-devops-dev"
}

inputs = {
  github_actions_openid_connect_provider_arn = dependency.github-actions-openid-connect-provider.outputs.arn
  github_actions_openid_connect_provider_url = dependency.github-actions-openid-connect-provider.outputs.url

  allowed_sources = {
    "cryptocat-org/devops-test" : ["main"]
  }

  # Policy for OIDC role assumed from GitHub in the "<GITHUB_ORG_NAME>/<INFRASTRUCTURE_LIVE_REPO_NAME>" repo
  custom_iam_policy_name = "pipelines-apply-oidc-policy"
  iam_role_name          = "pipelines-apply"

  # Policy based on these docs:
  # https://terragrunt.gruntwork.io/docs/features/aws-auth/#aws-iam-policies
  iam_policy = {
    "SSMGet" = {
      effect = "Allow"
      actions = [
        "ssm:*",
        "sts:*"
      ]
      resources = ["*"]
    }

    "IamPassRole" = {
      resources = ["*"]
      actions   = ["iam:*"]
      effect    = "Allow"
    }
    "IamCreateRole" = {
      resources = [
        "arn:aws:iam::*:role/aws-service-role/orgsdatasync.servicecatalog.amazonaws.com/AWSServiceRoleForServiceCatalogOrgsDataSync"
      ]
      actions = ["iam:CreateServiceLinkedRole"]
      effect  = "Allow"
    }
    "S3BucketAccess" = {
      resources = ["*"]
      actions   = ["s3:*"]
      effect    = "Allow"
    }
    "DynamoDBLocksTableAccess" = {
      resources = ["arn:aws:dynamodb:*:*:table/yolo-terraform-devops-dev"]
      actions   = ["dynamodb:*"]
      effect    = "Allow"
    }
    "OrganizationsDeployAccess" = {
      resources = ["*"]
      actions   = ["organizations:*"]
      effect    = "Allow"
    }
    "ControlTowerDeployAccess" = {
      resources = ["*"]
      actions   = ["controltower:*"]
      effect    = "Allow"
    }
    "IdentityCenterDeployAccess" = {
      resources = ["*"]
      actions   = ["sso:*", "ds:*", "sso-directory:*"]
      effect    = "Allow"
    }
    "ECSDeployAccess" = {
      resources = ["*"]
      actions   = ["ecs:*"]
      effect    = "Allow"
    }
    "ACMDeployAccess" = {
      resources = ["*"]
      actions   = ["acm:*"]
      effect    = "Allow"
    }
    "AutoScalingDeployAccess" = {
      resources = ["*"]
      actions   = ["autoscaling:*"]
      effect    = "Allow"
    }
    "CloudTrailDeployAccess" = {
      resources = ["*"]
      actions   = ["cloudtrail:*"]
      effect    = "Allow"
    }
    "CloudWatchDeployAccess" = {
      resources = ["*"]
      actions   = ["cloudwatch:*", "logs:*"]
      effect    = "Allow"
    }
    "CloudFrontDeployAccess" = {
      resources = ["*"]
      actions   = ["cloudfront:*"]
      effect    = "Allow"
    }
    "ConfigDeployAccess" = {
      resources = ["*"]
      actions   = ["config:*"]
      effect    = "Allow"
    }
    "EC2DeployAccess" = {
      resources = ["*"]
      actions   = ["ec2:*"]
      effect    = "Allow"
    }
    "ECRDeployAccess" = {
      resources = ["*"]
      actions   = ["ecr:*"]
      effect    = "Allow"
    }
    "ELBDeployAccess" = {
      resources = ["*"]
      actions   = ["elasticloadbalancing:*"]
      effect    = "Allow"
    }
    "GuardDutyDeployAccess" = {
      resources = ["*"]
      actions   = ["guardduty:*"]
      effect    = "Allow"
    }
    "IAMDeployAccess" = {
      resources = ["*"]
      actions   = ["iam:*", "access-analyzer:*"]
      effect    = "Allow"
    }
    "KMSDeployAccess" = {
      resources = ["*"]
      actions   = ["kms:*"]
      effect    = "Allow"
    }
    "LambdaDeployAccess" = {
      resources = ["*"]
      actions   = ["lambda:*"]
      effect    = "Allow"
    }
    "Route53DeployAccess" = {
      resources = ["*"]
      actions   = ["route53:*", "route53domains:*", "route53resolver:*"]
      effect    = "Allow"
    }
    "SecretsManagerDeployAccess" = {
      resources = ["*"]
      actions   = ["secretsmanager:*"]
      effect    = "Allow"
    }
    "SNSDeployAccess" = {
      resources = ["*"]
      actions   = ["sns:*"]
      effect    = "Allow"
    }
    "SQSDeployAccess" = {
      resources = ["*"]
      actions   = ["sqs:*"]
      effect    = "Allow"
    }
    "SecurityHubDeployAccess" = {
      resources = ["*"]
      actions   = ["securityhub:*"]
      effect    = "Allow"
    }
    "MacieDeployAccess" = {
      resources = ["*"]
      actions   = ["macie2:*"]
      effect    = "Allow"
    }
    "ServiceQuotaDeployAccess" = {
      resources = ["*"]
      actions   = ["servicequotas:*"]
      effect    = "Allow"
    }
    "EKSAccess" = {
      resources = ["*"]
      actions   = ["eks:*"]
      effect    = "Allow"
    }
    "EventBridgeAccess" = {
      resources = ["*"]
      actions   = ["events:*"]
      effect    = "Allow"
    }
    "ApplicationAutoScalingAccess" = {
      resources = ["*"]
      actions   = ["application-autoscaling:*"]
      effect    = "Allow"
    }
    "ApiGatewayAccess" = {
      resources = ["*"]
      actions   = ["apigateway:*"]
      effect    = "Allow"
    }
  }
}
