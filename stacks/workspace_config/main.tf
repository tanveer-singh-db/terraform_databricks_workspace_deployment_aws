resource "terraform_data" "config_contract" {
  input = local.config

  lifecycle {
    precondition {
      condition     = length(local.duplicate_keys) == 0
      error_message = "Duplicate top-level YAML keys: ${join(", ", local.duplicate_keys)}."
    }

    precondition {
      condition     = can(regex("^https://[^/]+$", local.config.workspace_url))
      error_message = "workspace_url must be an HTTPS workspace host without a path."
    }
  }
}

module "security_settings" {
  source = "../../modules/workspace/security_settings"

  providers = {
    databricks = databricks.workspace
  }

  config = local.config.security

  depends_on = [terraform_data.config_contract]
}

module "serverless_sql_warehouse" {
  source = "../../modules/workspace/serverless_sql_warehouse"

  providers = {
    databricks = databricks.workspace
  }

  config = {
    warehouses = local.config.sql_warehouses
  }

  depends_on = [terraform_data.config_contract]
}
