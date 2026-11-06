variable "config" {
  type = object({
    network_policy_id             = string
    restriction_mode              = string
    enforcement_mode              = string
    allowed_internet_destinations = list(string)
    allowed_storage_destinations = list(object({
      bucket_name = string
      region      = string
    }))
  })

  validation {
    condition     = contains(["FULL_ACCESS", "RESTRICTED_ACCESS"], var.config.restriction_mode)
    error_message = "restriction_mode must be FULL_ACCESS or RESTRICTED_ACCESS."
  }

  validation {
    condition     = contains(["DRY_RUN", "ENFORCED"], var.config.enforcement_mode)
    error_message = "enforcement_mode must be DRY_RUN or ENFORCED."
  }
}
