variable "config" {
  type = object({
    name                     = string
    region                   = string
    public_access_enabled    = bool
    private_access_level     = string
    allowed_vpc_endpoint_ids = list(string)
  })

  validation {
    condition     = contains(["ACCOUNT", "ENDPOINT"], var.config.private_access_level)
    error_message = "private_access_level must be ACCOUNT or ENDPOINT."
  }

  validation {
    condition     = var.config.private_access_level != "ENDPOINT" || length(var.config.allowed_vpc_endpoint_ids) > 0
    error_message = "allowed_vpc_endpoint_ids must be non-empty when private_access_level is ENDPOINT."
  }
}
