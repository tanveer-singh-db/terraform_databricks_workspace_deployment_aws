variable "config" {
  type = object({
    compliance_security_profile = optional(object({
      enabled   = bool
      standards = list(string)
    }))
    enhanced_security_monitoring = optional(bool)
    disable_legacy_dbfs          = optional(bool)
    disable_legacy_access        = optional(bool)
  })
}

output "managed_settings" {
  value = {
    compliance_security_profile  = var.config.compliance_security_profile
    enhanced_security_monitoring = var.config.enhanced_security_monitoring
    disable_legacy_dbfs          = var.config.disable_legacy_dbfs
    disable_legacy_access        = var.config.disable_legacy_access
  }
}
