resource "databricks_mws_networks" "this" {
  account_id         = var.config.account_id
  network_name       = var.config.name
  vpc_id             = var.config.vpc_id
  subnet_ids         = var.config.subnet_ids
  security_group_ids = var.config.security_group_ids

  dynamic "vpc_endpoints" {
    for_each = var.config.vpc_endpoints == null ? [] : [var.config.vpc_endpoints]
    content {
      rest_api        = vpc_endpoints.value.rest_api
      dataplane_relay = vpc_endpoints.value.dataplane_relay
    }
  }
}
