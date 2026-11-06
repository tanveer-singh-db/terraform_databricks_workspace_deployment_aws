variable "config" {
  type = object({
    account_id                 = string
    workspace_name             = string
    deployment_name            = optional(string)
    aws_region                 = string
    credentials_id             = string
    storage_configuration_id   = string
    network_id                 = string
    private_access_settings_id = string
    custom_tags                = optional(map(string), {})
  })
}
