resource "databricks_mws_private_access_settings" "this" {
  private_access_settings_name = var.config.name
  region                       = var.config.region
  public_access_enabled        = var.config.public_access_enabled
  private_access_level         = var.config.private_access_level
  allowed_vpc_endpoint_ids     = var.config.allowed_vpc_endpoint_ids
}
