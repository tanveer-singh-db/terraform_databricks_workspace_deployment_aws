variable "config" {
  type = object({
    workspace_id                                = string
    deployment_service_principal_application_id = string
    groups = optional(list(object({
      name        = string
      permissions = list(string)
    })), [])
    users = optional(list(object({
      user_name   = string
      permissions = list(string)
    })), [])
    service_principals = optional(list(object({
      application_id = string
      permissions    = list(string)
    })), [])
  })

  validation {
    condition = alltrue(flatten([
      [for principal in var.config.groups : alltrue([for permission in principal.permissions : contains(["USER", "ADMIN"], permission)])],
      [for principal in var.config.users : alltrue([for permission in principal.permissions : contains(["USER", "ADMIN"], permission)])],
      [for principal in var.config.service_principals : alltrue([for permission in principal.permissions : contains(["USER", "ADMIN"], permission)])]
    ]))
    error_message = "Workspace permissions may only contain USER or ADMIN."
  }
}
