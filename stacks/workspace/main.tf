resource "terraform_data" "config_contract" {
  input = local.config

  lifecycle {
    precondition {
      condition     = length(local.duplicate_keys) == 0
      error_message = "Duplicate top-level YAML keys: ${join(", ", local.duplicate_keys)}."
    }

    precondition {
      condition     = local.config.workspace.aws_region == var.region
      error_message = "workspace.aws_region must match the stack region."
    }

    precondition {
      condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", local.config.aws.cross_account_role_arn))
      error_message = "aws.cross_account_role_arn must be an AWS IAM role ARN."
    }

    precondition {
      condition     = local.config.private_access.public_access_enabled || try(local.config.aws.privatelink.frontend_rest_vpce_id, null) != null
      error_message = "aws.privatelink.frontend_rest_vpce_id is required when public_access_enabled is false."
    }
  }
}

module "workspace" {
  source = "../../modules/composite/aws_privatelink_workspace"

  providers = {
    databricks = databricks.account
    time       = time
  }

  config = {
    account_id       = local.config.databricks_account_id
    region           = var.region
    workspace        = local.config.workspace
    aws              = local.config.aws
    private_access   = local.config.private_access
    unity_catalog    = local.config.unity_catalog
    serverless       = try(local.config.serverless, {})
    workspace_access = local.config.workspace_access
  }

  depends_on = [terraform_data.config_contract]
}
