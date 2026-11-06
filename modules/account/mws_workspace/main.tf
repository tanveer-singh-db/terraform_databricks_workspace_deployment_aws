resource "databricks_mws_workspaces" "this" {
  account_id                 = var.config.account_id
  workspace_name             = var.config.workspace_name
  deployment_name            = var.config.deployment_name
  aws_region                 = var.config.aws_region
  pricing_tier               = "ENTERPRISE"
  credentials_id             = var.config.credentials_id
  storage_configuration_id   = var.config.storage_configuration_id
  network_id                 = var.config.network_id
  private_access_settings_id = var.config.private_access_settings_id
  is_no_public_ip_enabled    = true
  custom_tags                = var.config.custom_tags
}
