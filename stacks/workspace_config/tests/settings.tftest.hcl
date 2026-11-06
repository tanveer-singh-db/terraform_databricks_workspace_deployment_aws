mock_provider "databricks" {
  alias = "workspace"

  mock_resource "databricks_sql_endpoint" {
    defaults = {
      id = "mock-warehouse-id"
    }
  }
}

variables {
  environment = "dev"
  region      = "ap-southeast-1"
  workspace   = "analytics"
}

run "serverless_warehouse_and_workspace_settings" {
  command = plan

  assert {
    condition     = output.serverless_warehouse_settings["serverless-default"].enable_serverless_compute && output.serverless_warehouse_settings["serverless-default"].warehouse_type == "PRO"
    error_message = "Configured SQL warehouses must use serverless PRO compute."
  }

  assert {
    condition     = output.managed_security_settings.compliance_security_profile.enabled == false
    error_message = "Compliance profile management must follow its enabled flag."
  }

  assert {
    condition     = output.managed_security_settings.enhanced_security_monitoring == false
    error_message = "Enhanced security monitoring management must follow its enabled flag."
  }

  assert {
    condition     = output.managed_security_settings.disable_legacy_dbfs && output.managed_security_settings.disable_legacy_access
    error_message = "Legacy DBFS and legacy access are disabled in the sample configuration."
  }
}
