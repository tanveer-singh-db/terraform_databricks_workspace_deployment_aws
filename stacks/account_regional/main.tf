resource "terraform_data" "config_contract" {
  input = local.config

  lifecycle {
    precondition {
      condition     = length(local.duplicate_keys) == 0
      error_message = "Duplicate top-level YAML keys: ${join(", ", local.duplicate_keys)}."
    }

    precondition {
      condition     = local.config.region == var.region
      error_message = "regional.yml region must match the stack region."
    }
  }
}

module "metastore" {
  count  = local.config.metastore.create ? 1 : 0
  source = "../../modules/account/metastore"

  providers = {
    databricks = databricks.account
  }

  config = {
    name                                              = local.config.metastore.name
    region                                            = local.config.region
    storage_root                                      = try(local.config.metastore.storage_root, null)
    owner                                             = try(local.config.metastore.owner, null)
    delta_sharing_scope                               = try(local.config.metastore.delta_sharing_scope, null)
    delta_sharing_recipient_token_lifetime_in_seconds = try(local.config.metastore.delta_sharing_recipient_token_lifetime_in_seconds, null)
    delta_sharing_organization_name                   = try(local.config.metastore.delta_sharing_organization_name, null)
  }

  depends_on = [terraform_data.config_contract]
}

module "network_connectivity_config" {
  for_each = { for ncc in local.config.network_connectivity_configs : ncc.name => ncc }
  source   = "../../modules/account/network_connectivity_config"

  providers = {
    databricks = databricks.account
  }

  config = {
    name                   = each.value.name
    region                 = local.config.region
    private_endpoint_rules = try(each.value.private_endpoint_rules, [])
  }

  depends_on = [terraform_data.config_contract]
}

module "network_policy" {
  for_each = { for policy in local.config.network_policies : policy.network_policy_id => policy }
  source   = "../../modules/account/network_policy"

  providers = {
    databricks = databricks.account
  }

  config = {
    network_policy_id             = each.value.network_policy_id
    restriction_mode              = each.value.restriction_mode
    enforcement_mode              = each.value.enforcement_mode
    allowed_internet_destinations = try(each.value.allowed_internet_destinations, [])
    allowed_storage_destinations  = try(each.value.allowed_storage_destinations, [])
  }

  depends_on = [terraform_data.config_contract]
}
