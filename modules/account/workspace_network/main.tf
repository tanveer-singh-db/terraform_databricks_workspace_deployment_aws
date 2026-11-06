resource "databricks_workspace_network_option" "this" {
  workspace_id      = var.config.workspace_id
  network_policy_id = var.config.network_policy_id
}

resource "databricks_mws_ncc_binding" "this" {
  count = var.config.network_connectivity_config_id == null ? 0 : 1

  workspace_id                   = var.config.workspace_id
  network_connectivity_config_id = var.config.network_connectivity_config_id
}

output "ncc_binding_count" {
  value = length(databricks_mws_ncc_binding.this)
}

output "network_policy_id" {
  value = databricks_workspace_network_option.this.network_policy_id
}
