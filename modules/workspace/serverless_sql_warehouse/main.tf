resource "databricks_sql_endpoint" "this" {
  for_each = { for warehouse in var.config.warehouses : warehouse.name => warehouse }

  name                      = each.value.name
  cluster_size              = each.value.cluster_size
  min_num_clusters          = each.value.min_num_clusters
  max_num_clusters          = each.value.max_num_clusters
  auto_stop_mins            = each.value.auto_stop_mins
  enable_serverless_compute = true
  warehouse_type            = "PRO"

  dynamic "tags" {
    for_each = length(each.value.tags) == 0 ? [] : [each.value.tags]
    content {
      dynamic "custom_tags" {
        for_each = tags.value
        content {
          key   = custom_tags.key
          value = custom_tags.value
        }
      }
    }
  }
}
