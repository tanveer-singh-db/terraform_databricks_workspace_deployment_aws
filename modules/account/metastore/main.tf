resource "databricks_metastore" "this" {
  name                                              = var.config.name
  region                                            = var.config.region
  storage_root                                      = var.config.storage_root
  owner                                             = var.config.owner
  delta_sharing_scope                               = var.config.delta_sharing_scope
  delta_sharing_recipient_token_lifetime_in_seconds = var.config.delta_sharing_recipient_token_lifetime_in_seconds
  delta_sharing_organization_name                   = var.config.delta_sharing_organization_name
}
