variable "config" {
  type = object({
    name   = string
    region = string
    private_endpoint_rules = optional(list(object({
      endpoint_service = optional(string)
      resource_names   = optional(list(string))
      domain_names     = optional(list(string))
      enabled          = optional(bool)
    })), [])
  })

  validation {
    condition = alltrue([
      for rule in var.config.private_endpoint_rules :
      (rule.endpoint_service != null && ((rule.resource_names != null) != (rule.domain_names != null))) ||
      (rule.endpoint_service == null && rule.resource_names != null && rule.domain_names == null)
    ])
    error_message = "Each AWS private endpoint rule must specify endpoint_service with exactly one of resource_names or domain_names, or specify resource_names alone for AWS S3."
  }
}
