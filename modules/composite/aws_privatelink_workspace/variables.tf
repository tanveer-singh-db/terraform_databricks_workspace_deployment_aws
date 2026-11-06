variable "config" {
  type = object({
    account_id = string
    region     = string
    workspace = object({
      name            = string
      deployment_name = optional(string)
      aws_region      = string
      custom_tags     = optional(map(string), {})
    })
    aws = object({
      account_id             = string
      cross_account_role_arn = string
      root_bucket_name       = string
      network = object({
        vpc_id             = string
        subnet_ids         = list(string)
        security_group_ids = list(string)
      })
      privatelink = object({
        backend_rest_vpce_id  = string
        backend_relay_vpce_id = string
        frontend_rest_vpce_id = optional(string)
      })
    })
    private_access = object({
      public_access_enabled = bool
      private_access_level  = string
    })
    unity_catalog = object({
      metastore_id = string
    })
    serverless = optional(object({
      network_connectivity_config_id = optional(string)
      network_policy_id              = optional(string)
    }), {})
    workspace_access = object({
      deployment_service_principal_application_id = string
      groups = optional(list(object({
        name        = string
        permissions = list(string)
      })), [])
      users = optional(list(object({
        user_name   = string
        permissions = list(string)
      })), [])
      service_principals = optional(list(object({
        application_id = string
        permissions    = list(string)
      })), [])
    })
  })

  validation {
    condition     = var.config.workspace.aws_region == var.config.region
    error_message = "workspace.aws_region must match the stack region."
  }

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.config.aws.cross_account_role_arn))
    error_message = "aws.cross_account_role_arn must be an AWS IAM role ARN."
  }

  validation {
    condition     = var.config.private_access.public_access_enabled || var.config.aws.privatelink.frontend_rest_vpce_id != null
    error_message = "aws.privatelink.frontend_rest_vpce_id is required when public_access_enabled is false."
  }

  validation {
    condition     = length(var.config.aws.network.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for a Databricks network."
  }

  validation {
    condition     = length(var.config.aws.network.security_group_ids) >= 1 && length(var.config.aws.network.security_group_ids) <= 5
    error_message = "Between one and five security group IDs are required for a Databricks network."
  }

  validation {
    condition = alltrue([
      can(regex("^vpce-[0-9a-f]+$", var.config.aws.privatelink.backend_rest_vpce_id)),
      can(regex("^vpce-[0-9a-f]+$", var.config.aws.privatelink.backend_relay_vpce_id)),
      var.config.aws.privatelink.frontend_rest_vpce_id == null ? true : can(regex("^vpce-[0-9a-f]+$", var.config.aws.privatelink.frontend_rest_vpce_id))
    ])
    error_message = "VPC endpoint IDs must be AWS endpoint IDs (vpce- followed by lowercase hexadecimal characters)."
  }
}
