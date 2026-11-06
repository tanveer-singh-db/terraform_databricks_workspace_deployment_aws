mock_provider "databricks" {
  mock_data "databricks_aws_assume_role_policy" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "databricks_aws_crossaccount_policy" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "databricks_aws_bucket_policy" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

mock_provider "local" {}

variables {
  environment = "dev"
  region      = "ap-southeast-1"
  workspace   = "analytics"
}

run "dev_cloudformation_policies_are_rendered" {
  command = plan

  assert {
    condition     = length(output.assume_role_policy_json) > 0 && length(output.root_bucket_policy_json) > 0
    error_message = "AWS assume-role and bucket policy JSON must be rendered."
  }

  assert {
    condition     = length(output.crossaccount_policy_json_by_security_group) == 1
    error_message = "A restricted cross-account policy must be rendered for each configured security group."
  }
}
