resource "databricks_mws_vpc_endpoint" "this" {
  account_id          = var.config.account_id
  vpc_endpoint_name   = var.config.name
  aws_vpc_endpoint_id = var.config.aws_vpc_endpoint_id
  region              = var.config.region
}
