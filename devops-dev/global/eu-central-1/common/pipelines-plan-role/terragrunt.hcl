terraform {
  source = "git@github.com:gruntwork-io/terraform-aws-security.git//modules/github-actions-iam-role?ref=v0.74.5"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# The OIDC IAM roles for GitHub Actions require an IAM OpenID Connect (OIDC) Provider to be provisioned for each account.
# The underlying module used in `envcommon` is capable of creating the OIDC provider. Since multiple OIDC roles are required, 
# a dedicated module is used, and all roles depend on its output
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
  state_bucket_pattern = lower("yolo-terrafrom-devops-dev")
}

inputs = {
  github_actions_openid_connect_provider_arn = dependency.github-actions-openid-connect-provider.outputs.arn
  github_actions_openid_connect_provider_url = dependency.github-actions-openid-connect-provider.outputs.url

  allowed_sources_condition_operator = "StringLike"

  allowed_sources = {
    "cryptocat-org/devops-test" : ["*"]
  }

  custom_iam_policy_name = "pipelines-plan-oidc-policy"
  iam_role_name          = "pipelines-plan"

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
    "RDSReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "rds:Describe*",
        "rds:List*",
        "rds:Download*",
      ]
      resources = ["*"]
    }
    "CloudWatchEventsReadOnlyAccess" = {
      effect    = "Allow"
      actions   = ["events:Describe*", "events:List*"]
      resources = ["*"]
    }
    ECSReadOnlyAccess = {
      effect = "Allow"
      actions = [
        "ecs:Describe*",
        "ecs:List*",
      ]
      resources = ["*"]
    }
    "ACMReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate",
        "acm:ListTagsForCertificate",
      ]
      resources = ["*"]
    }
    AutoScalingReadOnlyAccess = {
      effect    = "Allow"
      actions   = ["autoscaling:Describe*"]
      resources = ["*"]
    }
    "CloudTrailReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "cloudtrail:Describe*",
        "cloudtrail:List*",
        "cloudtrail:Get*",
      ]
      resources = ["*"]
    }
    "CloudWatchReadOnlyAccess" = {
      effect    = "Allow"
      actions   = ["cloudwatch:Describe*", "cloudwatch:List*"]
      resources = ["*"]
    }
    "CloudWatchLogsReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "logs:Get*",
        "logs:Describe*",
        "logs:List*",
        "logs:Filter*",
      ]
      resources = ["*"]
    }
    "ConfigReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "config:Get*",
        "config:Describe*",
        "config:List*",
        "config:Select*",
        "config:BatchGetResourceConfig",
      ]
      resources = ["*"]
    }
    "EC2ServiceReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "ec2:Describe*",
        "ec2:Get*",
      ]
      resources = ["*"]
    }
    "ECRReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "ecr:BatchGet*",
        "ecr:Describe*",
        "ecr:Get*",
        "ecr:List*",
      ]
      resources = ["*"]
    }
    "ELBReadOnlyAccess" = {
      effect    = "Allow"
      actions   = ["elasticloadbalancing:Describe*"]
      resources = ["*"]
    }
    "GuardDutyReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "guardduty:Get*",
        "guardduty:List*",
      ]
      resources = ["*"]
    }
    "IAMReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "iam:Get*",
        "iam:List*",
        "iam:PassRole*",
      ]
      resources = ["*"]
    }
    "IAMAccessAnalyzerReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "access-analyzer:List*",
        "access-analyzer:Get*",
        "access-analyzer:ValidatePolicy",
      ]
      resources = ["*"]
    }
    "KMSReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "kms:Describe*",
        "kms:Get*",
        "kms:List*",
      ]
      resources = ["*"]
    }
    "LambdaReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "lambda:Get*",
        "lambda:List*",
      ]
      resources = ["*"]
    }
    "Route53ReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "route53:Get*",
        "route53:List*",
        "route53:Test*",
        "route53domains:Check*",
        "route53domains:Get*",
        "route53domains:List*",
        "route53domains:View*",
        "route53resolver:Get*",
        "route53resolver:List*",
      ]
      resources = ["*"]
    }
    "S3ReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
      resources = ["*"]
    }
    "SecretsManagerReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "secretsmanager:Get*",
        "secretsmanager:List*",
        "secretsmanager:Describe*",
      ]
      resources = ["*"]
    }
    "SNSReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "sns:Get*",
        "sns:List*",
        "sns:Check*",
      ]
      resources = ["*"]
    }
    "SQSReadOnlyAccess" = {
      effect = "Allow"
      actions = [
        "sqs:Get*",
        "sqs:List*",
      ]
      resources = ["*"]
    }
    "DynamoDBLocksTableAccess" = {
      effect = "Allow"
      actions = [
        "dynamodb:*",
      ]
      resources = ["arn:aws:dynamodb:*:*:table/yolo-terraform-devops-dev"]
    }
    "S3StateBucketAccess" = {
      effect = "Allow"
      actions = [
        "s3:*",
      ]
      resources = [
        "arn:aws:s3:::${local.state_bucket_pattern}",
        "arn:aws:s3:::${local.state_bucket_pattern}/*",
      ]
    }
    "SecurityHubDeployAccess" = {
      resources = ["*"]
      actions = [
        "securityhub:Get*",
        "securityhub:Describe*",
        "securityhub:List*"
      ]
      effect = "Allow"
    }
    "MacieDeployAccess" = {
      resources = ["*"]
      actions = [
        "macie2:Get*",
        "macie2:Describe*",
        "macie2:List*"
      ]
      effect = "Allow"
    }
    "ServiceQuotaAccess" = {
      resources = ["*"]
      actions = [
        "servicequotas:Get*",
        "servicequotas:List*"
      ]
      effect = "Allow"
    }
    "ApplicationAutoScalingAccess" = {
      resources = ["*"]
      actions = [
        "application-autoscaling:Describe*",
        "application-autoscaling:List*"
      ]
      effect = "Allow"
    }
    "ApiGatewayAccess" = {
      resources = ["*"]
      actions   = ["apigateway:Get*"]
      effect    = "Allow"
    }
  }
}
