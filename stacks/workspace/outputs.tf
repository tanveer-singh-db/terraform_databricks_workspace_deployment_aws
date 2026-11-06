output "workspace_id" {
  value = module.workspace.workspace_id
}

output "workspace_url" {
  value = module.workspace.workspace_url
}

output "deployment_name" {
  value = module.workspace.deployment_name
}

output "workspace_name" {
  value = local.config.workspace.name
}
