variable "config" {
  type = object({
    workspace_id                   = string
    network_policy_id              = string
    network_connectivity_config_id = optional(string)
  })
}
