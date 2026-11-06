output "metastore_id" {
  value = local.config.metastore.create ? module.metastore[0].metastore_id : local.config.metastore.metastore_id
}

output "metastore_name" {
  value = local.config.metastore.create ? module.metastore[0].metastore_name : null
}

output "network_connectivity_config_ids" {
  value = { for name, ncc in module.network_connectivity_config : name => ncc.network_connectivity_config_id }
}

output "network_policy_ids" {
  value = { for name, policy in module.network_policy : name => policy.network_policy_id }
}

output "network_policy_restriction_modes" {
  value = { for name, policy in module.network_policy : name => policy.restriction_mode }
}
