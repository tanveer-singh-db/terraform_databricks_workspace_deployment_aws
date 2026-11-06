output "workspace_url" {
  value = local.config.workspace_url
}

output "serverless_warehouse_ids" {
  value = module.serverless_sql_warehouse.warehouse_ids
}

output "serverless_warehouse_settings" {
  value = module.serverless_sql_warehouse.warehouse_specs
}

output "managed_security_settings" {
  value = module.security_settings.managed_settings
}
