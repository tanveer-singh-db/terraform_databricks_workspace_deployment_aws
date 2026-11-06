mock_provider "databricks" {}

run "endpoint_access_requires_allowed_endpoints" {
  command = plan

  variables {
    config = {
      name                     = "test-pas"
      region                   = "ap-southeast-1"
      public_access_enabled    = false
      private_access_level     = "ENDPOINT"
      allowed_vpc_endpoint_ids = []
    }
  }

  expect_failures = [var.config]
}
