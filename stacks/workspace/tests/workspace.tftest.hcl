mock_provider "databricks" {
  alias = "account"

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

variables {
  environment = "dev"
  region      = "ap-southeast-1"
  workspace   = "analytics"
}

run "workspace_name_is_loaded_from_real_config" {
  command = plan

  assert {
    condition     = output.workspace_name == "dev-apse1-analytics"
    error_message = "The workspace name must come from the dev YAML configuration."
  }
}

run "duplicate_top_level_yaml_key_is_rejected" {
  command = plan

  variables {
    config_root = "tests/fixtures/duplicate"
  }

  expect_failures = [terraform_data.config_contract]
}
