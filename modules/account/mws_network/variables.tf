variable "config" {
  type = object({
    account_id         = string
    name               = string
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
    vpc_endpoints = optional(object({
      rest_api        = list(string)
      dataplane_relay = list(string)
    }))
  })

  validation {
    condition     = length(var.config.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for a Databricks network."
  }

  validation {
    condition     = length(var.config.security_group_ids) >= 1 && length(var.config.security_group_ids) <= 5
    error_message = "Between one and five security group IDs are required for a Databricks network."
  }
}
