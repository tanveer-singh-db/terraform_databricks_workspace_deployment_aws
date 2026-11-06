resource "databricks_mws_network_connectivity_config" "this" {
  name   = var.config.name
  region = var.config.region
}

resource "databricks_mws_ncc_private_endpoint_rule" "this" {
  for_each = { for index, rule in var.config.private_endpoint_rules : tostring(index) => rule }

  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  endpoint_service               = each.value.endpoint_service
  resource_names                 = each.value.resource_names
  domain_names                   = each.value.domain_names
  enabled                        = each.value.enabled
}
