output "private_access_settings_id" {
  value = databricks_mws_private_access_settings.this.private_access_settings_id
}

output "allowed_vpc_endpoint_ids" {
  value = databricks_mws_private_access_settings.this.allowed_vpc_endpoint_ids
}
