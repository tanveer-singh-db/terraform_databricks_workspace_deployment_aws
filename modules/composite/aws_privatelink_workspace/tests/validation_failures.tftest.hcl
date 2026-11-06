mock_provider "databricks" {
  override_during = plan
}

mock_provider "time" {}

run "missing_frontend_endpoint_is_rejected" {
  command = plan
  variables {
    config = {
      account_id = "00000000-0000-0000-0000-000000000001"
      region     = "ap-southeast-1"
      workspace  = { name = "test", aws_region = "ap-southeast-1" }
      aws = {
        account_id             = "111122223333"
        cross_account_role_arn = "arn:aws:iam::111122223333:role/test"
        root_bucket_name       = "test-root"
        network = {
          vpc_id             = "vpc-1"
          subnet_ids         = ["subnet-1", "subnet-2"]
          security_group_ids = ["sg-1"]
        }
        privatelink = {
          backend_rest_vpce_id  = "vpce-0123456789abcdef0"
          backend_relay_vpce_id = "vpce-0123456789abcdef1"
          frontend_rest_vpce_id = null
        }
      }
      private_access = { public_access_enabled = false, private_access_level = "ENDPOINT" }
      unity_catalog  = { metastore_id = "metastore" }
      workspace_access = {
        deployment_service_principal_application_id = "sp"
        groups                                      = []
        users                                       = []
        service_principals                          = []
      }
    }
  }

  expect_failures = [var.config]
}

run "one_subnet_is_rejected" {
  command = plan
  variables {
    config = {
      account_id = "00000000-0000-0000-0000-000000000001"
      region     = "ap-southeast-1"
      workspace  = { name = "test", aws_region = "ap-southeast-1" }
      aws = {
        account_id             = "111122223333"
        cross_account_role_arn = "arn:aws:iam::111122223333:role/test"
        root_bucket_name       = "test-root"
        network = {
          vpc_id             = "vpc-1"
          subnet_ids         = ["subnet-1"]
          security_group_ids = ["sg-1"]
        }
        privatelink = {
          backend_rest_vpce_id  = "vpce-0123456789abcdef0"
          backend_relay_vpce_id = "vpce-0123456789abcdef1"
          frontend_rest_vpce_id = "vpce-0123456789abcdef2"
        }
      }
      private_access = { public_access_enabled = false, private_access_level = "ENDPOINT" }
      unity_catalog  = { metastore_id = "metastore" }
      workspace_access = {
        deployment_service_principal_application_id = "sp"
        groups                                      = []
        users                                       = []
        service_principals                          = []
      }
    }
  }

  expect_failures = [var.config]
}

run "malformed_vpc_endpoint_id_is_rejected" {
  command = plan
  variables {
    config = {
      account_id = "00000000-0000-0000-0000-000000000001"
      region     = "ap-southeast-1"
      workspace  = { name = "test", aws_region = "ap-southeast-1" }
      aws = {
        account_id             = "111122223333"
        cross_account_role_arn = "arn:aws:iam::111122223333:role/test"
        root_bucket_name       = "test-root"
        network = {
          vpc_id             = "vpc-1"
          subnet_ids         = ["subnet-1", "subnet-2"]
          security_group_ids = ["sg-1"]
        }
        privatelink = {
          backend_rest_vpce_id  = "not-a-vpce"
          backend_relay_vpce_id = "vpce-0123456789abcdef1"
          frontend_rest_vpce_id = "vpce-0123456789abcdef2"
        }
      }
      private_access = { public_access_enabled = false, private_access_level = "ENDPOINT" }
      unity_catalog  = { metastore_id = "metastore" }
      workspace_access = {
        deployment_service_principal_application_id = "sp"
        groups                                      = []
        users                                       = []
        service_principals                          = []
      }
    }
  }

  expect_failures = [var.config]
}
