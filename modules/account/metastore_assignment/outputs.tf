output "id" {
  value = databricks_metastore_assignment.this.id
}

output "assigned_metastore_id" {
  value = var.config.metastore_id
}
