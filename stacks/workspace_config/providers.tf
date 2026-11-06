provider "databricks" {
  alias = "workspace"
  host  = local.config.workspace_url
}
