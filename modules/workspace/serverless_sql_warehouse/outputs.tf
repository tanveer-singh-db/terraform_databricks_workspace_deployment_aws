output "warehouse_ids" {
  value = { for name, warehouse in databricks_sql_endpoint.this : name => warehouse.id }
}

output "warehouse_specs" {
  value = {
    for name, warehouse in databricks_sql_endpoint.this : name => {
      enable_serverless_compute = warehouse.enable_serverless_compute
      warehouse_type            = warehouse.warehouse_type
      cluster_size              = warehouse.cluster_size
    }
  }
}
