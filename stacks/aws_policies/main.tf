resource "terraform_data" "config_contract" {
  input = local.config

  lifecycle {
    precondition {
      condition     = length(local.duplicate_keys) == 0
      error_message = "Duplicate top-level YAML keys: ${join(", ", local.duplicate_keys)}."
    }

    precondition {
      condition     = local.config.workspace.aws_region == var.region
      error_message = "workspace.aws_region must match the stack region."
    }
  }
}

data "databricks_aws_assume_role_policy" "this" {
  external_id = local.config.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {
  for_each          = local.sg_policies
  policy_type       = "restricted"
  aws_account_id    = local.config.aws.account_id
  vpc_id            = local.config.aws.network.vpc_id
  region            = var.region
  security_group_id = each.value
}

data "databricks_aws_bucket_policy" "this" {
  bucket                   = local.config.aws.root_bucket_name
  databricks_e2_account_id = local.config.databricks_account_id
}

locals {
  policy_files = merge(
    {
      assume_role = data.databricks_aws_assume_role_policy.this.json
      root_bucket = data.databricks_aws_bucket_policy.this.json
    },
    {
      for id, policy in data.databricks_aws_crossaccount_policy.this :
      "crossaccount_${replace(id, "-", "_")}" => policy.json
    }
  )
}

resource "local_file" "policies" {
  for_each        = local.policy_files
  filename        = "${local.output_dir}/${each.key}.json"
  content         = each.value
  file_permission = "0644"

  depends_on = [terraform_data.config_contract]
}
