variable "config" {
  type = object({
    account_id                 = string
    storage_configuration_name = string
    bucket_name                = string
  })
}
