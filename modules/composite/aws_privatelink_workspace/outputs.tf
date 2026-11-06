output "workspace_id" {
  value = module.workspace.workspace_id
}

output "workspace_url" {
  value = module.workspace.workspace_url
}

output "deployment_name" {
  value = module.workspace.deployment_name
}

output "registered_vpc_endpoint_ids" {
  value = { for name, endpoint in module.vpc_endpoint : name => endpoint.vpc_endpoint_id }
}

output "private_access_allowed_vpc_endpoint_ids" {
  value = module.private_access_settings.allowed_vpc_endpoint_ids
}

output "network_vpc_endpoints" {
  value = module.network.configured_vpc_endpoints
}

output "workspace_pricing_tier" {
  value = module.workspace.pricing_tier
}

output "workspace_compute_mode" {
  value = module.workspace.compute_mode
}

output "workspace_is_no_public_ip_enabled" {
  value = module.workspace.is_no_public_ip_enabled
}

output "assigned_metastore_id" {
  value = module.metastore_assignment.assigned_metastore_id
}

output "ncc_binding_count" {
  value = module.workspace_network.ncc_binding_count
}

output "network_policy_id" {
  value = module.workspace_network.network_policy_id
}

output "deployment_permissions" {
  value = module.workspace_permission_assignment.deployment_permissions
}
