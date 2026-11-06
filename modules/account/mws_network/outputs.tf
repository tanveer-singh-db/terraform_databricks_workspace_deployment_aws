output "network_id" {
  value = databricks_mws_networks.this.network_id
}

output "vpc_endpoints" {
  value = databricks_mws_networks.this.vpc_endpoints
}

output "configured_vpc_endpoints" {
  value = var.config.vpc_endpoints
}
