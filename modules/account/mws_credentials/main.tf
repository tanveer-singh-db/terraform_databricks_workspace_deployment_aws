resource "time_sleep" "iam_propagation" {
  create_duration = "30s"
}

resource "databricks_mws_credentials" "this" {
  credentials_name = var.config.credentials_name
  role_arn         = var.config.role_arn

  depends_on = [time_sleep.iam_propagation]
}
