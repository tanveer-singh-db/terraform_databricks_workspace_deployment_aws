resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.config.account_id
  storage_configuration_name = var.config.storage_configuration_name
  bucket_name                = var.config.bucket_name
}
