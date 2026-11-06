resource "databricks_metastore_assignment" "this" {
  workspace_id = var.config.workspace_id
  metastore_id = var.config.metastore_id
}
