data "databricks_group" "groups" {
  for_each     = { for group in var.config.groups : group.name => group }
  display_name = each.value.name
}

data "databricks_user" "users" {
  for_each  = { for user in var.config.users : user.user_name => user }
  user_name = each.value.user_name
}

data "databricks_service_principal" "service_principals" {
  for_each       = { for principal in var.config.service_principals : principal.application_id => principal }
  application_id = each.value.application_id
}

data "databricks_service_principal" "deployment" {
  application_id = var.config.deployment_service_principal_application_id
}

resource "databricks_mws_permission_assignment" "groups" {
  for_each     = { for group in var.config.groups : group.name => group }
  workspace_id = var.config.workspace_id
  principal_id = data.databricks_group.groups[each.key].id
  permissions  = each.value.permissions
}

resource "databricks_mws_permission_assignment" "users" {
  for_each     = { for user in var.config.users : user.user_name => user }
  workspace_id = var.config.workspace_id
  principal_id = data.databricks_user.users[each.key].id
  permissions  = each.value.permissions
}

resource "databricks_mws_permission_assignment" "service_principals" {
  for_each     = { for principal in var.config.service_principals : principal.application_id => principal }
  workspace_id = var.config.workspace_id
  principal_id = data.databricks_service_principal.service_principals[each.key].id
  permissions  = each.value.permissions
}

resource "databricks_mws_permission_assignment" "deployment" {
  workspace_id = var.config.workspace_id
  principal_id = data.databricks_service_principal.deployment.id
  permissions  = ["ADMIN"]
}

output "deployment_permissions" {
  value = databricks_mws_permission_assignment.deployment.permissions
}
