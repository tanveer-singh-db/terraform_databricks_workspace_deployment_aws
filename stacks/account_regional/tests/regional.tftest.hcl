mock_provider "databricks" {
  alias = "account"

  mock_resource "databricks_metastore" {
    defaults = {
      metastore_id = "mock-metastore-id"
    }
  }

  mock_resource "databricks_mws_network_connectivity_config" {
    defaults = {
      network_connectivity_config_id = "mock-ncc-id"
    }
  }

  mock_resource "databricks_account_network_policy" {
    defaults = {
      network_policy_id = "dev-restricted"
    }
  }
}

variables {
  environment = "account"
  region      = "ap-southeast-1"
}

run "create_metastore_and_regional_policies" {
  command = plan

  assert {
    condition     = length(module.metastore) == 1 && output.metastore_name == "apse1-metastore"
    error_message = "create=true must plan a regional metastore."
  }

  assert {
    condition     = output.network_policy_restriction_modes["dev-restricted"] == "RESTRICTED_ACCESS"
    error_message = "The regional network policy must be rendered."
  }
}

run "reuse_existing_metastore" {
  command = plan

  variables {
    config_root = "tests/fixtures"
  }

  assert {
    condition     = length(module.metastore) == 0
    error_message = "create=false must not create a metastore."
  }

  assert {
    condition     = output.metastore_id == "existing-metastore-id"
    error_message = "The existing metastore ID must be returned."
  }
}
