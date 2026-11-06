variable "config" {
  type = object({
    name                                              = string
    region                                            = string
    storage_root                                      = optional(string)
    owner                                             = optional(string)
    delta_sharing_scope                               = optional(string)
    delta_sharing_recipient_token_lifetime_in_seconds = optional(number)
    delta_sharing_organization_name                   = optional(string)
  })
}
