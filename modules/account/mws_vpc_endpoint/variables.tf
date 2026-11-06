variable "config" {
  type = object({
    account_id          = string
    name                = string
    aws_vpc_endpoint_id = string
    region              = string
  })

  validation {
    condition     = can(regex("^vpce-[0-9a-f]+$", var.config.aws_vpc_endpoint_id))
    error_message = "aws_vpc_endpoint_id must be an AWS VPC endpoint ID (vpce- followed by lowercase hexadecimal characters)."
  }
}
