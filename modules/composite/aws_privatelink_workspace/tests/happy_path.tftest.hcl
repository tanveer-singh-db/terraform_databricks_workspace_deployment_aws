mock_provider "databricks" {
  override_during = plan

  mock_resource "databricks_mws_vpc_endpoint" {
    defaults = {
      vpc_endpoint_id = "registered-vpce"
    }
  }

  mock_resource "databricks_mws_workspaces" {
    defaults = {
      workspace_id  = "123456789"
      workspace_url = "https://mock.cloud.databricks.com"
    }
  }

  mock_data "databricks_group" {
    defaults = {
      id = "mock-group-id"
    }
  }

  mock_data "databricks_service_principal" {
    defaults = {
      id = "mock-service-principal-id"
    }
  }
}

mock_provider "time" {}

run "private_link_workspace_happy_path" {
  command = plan

  variables {
    config = {
      account_id = "00000000-0000-0000-0000-000000000001"
      region     = "ap-southeast-1"
      workspace = {
        name        = "test-workspace"
        aws_region  = "ap-southeast-1"
        custom_tags = { Env = "test" }
      }
      aws = {
        account_id             = "111122223333"
        cross_account_role_arn = "arn:aws:iam::111122223333:role/test-crossaccount"
        root_bucket_name       = "test-root-bucket"
        network = {
          vpc_id             = "vpc-0123456789abcdef0"
          subnet_ids         = ["subnet-1", "subnet-2"]
          security_group_ids = ["sg-0123456789abcdef0"]
        }
        privatelink = {
          backend_rest_vpce_id  = "vpce-0123456789abcdef0"
          backend_relay_vpce_id = "vpce-0123456789abcdef1"
          frontend_rest_vpce_id = "vpce-0123456789abcdef2"
        }
      }
      private_access = {
        public_access_enabled = false
        private_access_level  = "ENDPOINT"
      }
      unity_catalog = {
        metastore_id = "00000000-0000-0000-0000-000000000002"
      }
      serverless = {
        network_connectivity_config_id = "00000000-0000-0000-0000-000000000003"
        network_policy_id              = "test-restricted"
      }
      workspace_access = {
        deployment_service_principal_application_id = "00000000-0000-0000-0000-000000000004"
        groups = [{
          name        = "test-admins"
          permissions = ["ADMIN"]
        }]
        users              = []
        service_principals = []
      }
    }
  }

  assert {
    condition = toset(output.private_access_allowed_vpc_endpoint_ids) == toset([
      output.registered_vpc_endpoint_ids.frontend_rest,
      output.registered_vpc_endpoint_ids.backend_rest
    ])
    error_message = "ENDPOINT PAS must allow the frontend and backend REST endpoints."
  }

  assert {
    condition     = toset(output.network_vpc_endpoints.rest_api) == toset([output.registered_vpc_endpoint_ids.backend_rest]) && toset(output.network_vpc_endpoints.dataplane_relay) == toset([output.registered_vpc_endpoint_ids.backend_relay])
    error_message = "The network must register the REST and relay backend endpoints."
  }

  assert {
    condition     = output.workspace_pricing_tier == "ENTERPRISE" && output.workspace_is_no_public_ip_enabled && output.workspace_compute_mode == null
    error_message = "The workspace must be Enterprise, SCC-enabled, and classic/hybrid."
  }

  assert {
    condition     = output.assigned_metastore_id == "00000000-0000-0000-0000-000000000002"
    error_message = "The requested metastore must be assigned."
  }

  assert {
    condition     = output.ncc_binding_count == 1 && output.network_policy_id == "test-restricted"
    error_message = "The NCC binding and serverless network policy must be created."
  }

  assert {
    condition     = toset(output.deployment_permissions) == toset(["ADMIN"])
    error_message = "The deployment service principal must always be assigned ADMIN."
  }
}
