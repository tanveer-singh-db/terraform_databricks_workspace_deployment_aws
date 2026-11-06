resource "databricks_account_network_policy" "this" {
  network_policy_id = var.config.network_policy_id
  egress = {
    network_access = {
      restriction_mode = var.config.restriction_mode
      allowed_internet_destinations = [
        for destination in var.config.allowed_internet_destinations : {
          destination               = destination
          internet_destination_type = "DNS_NAME"
        }
      ]
      allowed_storage_destinations = [
        for destination in var.config.allowed_storage_destinations : {
          bucket_name              = destination.bucket_name
          region                   = destination.region
          storage_destination_type = "AWS_S3"
        }
      ]
      policy_enforcement = {
        enforcement_mode = var.config.enforcement_mode
      }
    }
  }
}
