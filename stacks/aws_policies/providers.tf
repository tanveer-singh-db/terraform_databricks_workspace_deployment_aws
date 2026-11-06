provider "databricks" {
  host       = "https://accounts.cloud.databricks.com"
  account_id = local.config.databricks_account_id
}
