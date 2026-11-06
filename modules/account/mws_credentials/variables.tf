variable "config" {
  type = object({
    credentials_name = string
    role_arn         = string
  })
}
