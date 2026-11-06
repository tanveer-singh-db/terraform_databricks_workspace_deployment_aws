output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "deployment_name" {
  value = databricks_mws_workspaces.this.deployment_name
}

output "pricing_tier" {
  value = databricks_mws_workspaces.this.pricing_tier
}

output "compute_mode" {
  value = databricks_mws_workspaces.this.compute_mode
}

output "is_no_public_ip_enabled" {
  value = databricks_mws_workspaces.this.is_no_public_ip_enabled
}
