locals {
  endpoint_configs = merge(
    {
      backend_rest = {
        name                = "backend-rest"
        aws_vpc_endpoint_id = var.config.aws.privatelink.backend_rest_vpce_id
      }
      backend_relay = {
        name                = "backend-relay"
        aws_vpc_endpoint_id = var.config.aws.privatelink.backend_relay_vpce_id
      }
    },
    var.config.aws.privatelink.frontend_rest_vpce_id == null ? {} : {
      frontend_rest = {
        name                = "frontend-rest"
        aws_vpc_endpoint_id = var.config.aws.privatelink.frontend_rest_vpce_id
      }
    }
  )

  allowed_vpc_endpoint_keys = var.config.private_access.private_access_level == "ENDPOINT" ? concat(
    var.config.aws.privatelink.frontend_rest_vpce_id == null ? [] : ["frontend_rest"],
    ["backend_rest"]
  ) : []
}

module "credentials" {
  source = "../../account/mws_credentials"

  config = {
    credentials_name = "${var.config.workspace.name}-credentials"
    role_arn         = var.config.aws.cross_account_role_arn
  }
}

module "storage_configuration" {
  source = "../../account/mws_storage_configuration"

  config = {
    account_id                 = var.config.account_id
    storage_configuration_name = "${var.config.workspace.name}-storage"
    bucket_name                = var.config.aws.root_bucket_name
  }
}

module "vpc_endpoint" {
  for_each = local.endpoint_configs
  source   = "../../account/mws_vpc_endpoint"

  config = {
    account_id          = var.config.account_id
    name                = "${var.config.workspace.name}-${each.value.name}"
    aws_vpc_endpoint_id = each.value.aws_vpc_endpoint_id
    region              = var.config.region
  }
}

module "network" {
  source = "../../account/mws_network"

  config = {
    account_id         = var.config.account_id
    name               = "${var.config.workspace.name}-network"
    vpc_id             = var.config.aws.network.vpc_id
    subnet_ids         = var.config.aws.network.subnet_ids
    security_group_ids = var.config.aws.network.security_group_ids
    vpc_endpoints = {
      rest_api        = [module.vpc_endpoint["backend_rest"].vpc_endpoint_id]
      dataplane_relay = [module.vpc_endpoint["backend_relay"].vpc_endpoint_id]
    }
  }
}

module "private_access_settings" {
  source = "../../account/mws_private_access_settings"

  config = {
    name                     = "${var.config.workspace.name}-private-access"
    region                   = var.config.region
    public_access_enabled    = var.config.private_access.public_access_enabled
    private_access_level     = var.config.private_access.private_access_level
    allowed_vpc_endpoint_ids = [for key in local.allowed_vpc_endpoint_keys : module.vpc_endpoint[key].vpc_endpoint_id]
  }
}

module "workspace" {
  source = "../../account/mws_workspace"

  config = {
    account_id                 = var.config.account_id
    workspace_name             = var.config.workspace.name
    deployment_name            = var.config.workspace.deployment_name
    aws_region                 = var.config.workspace.aws_region
    credentials_id             = module.credentials.credentials_id
    storage_configuration_id   = module.storage_configuration.storage_configuration_id
    network_id                 = module.network.network_id
    private_access_settings_id = module.private_access_settings.private_access_settings_id
    custom_tags                = var.config.workspace.custom_tags
  }
}

module "metastore_assignment" {
  source = "../../account/metastore_assignment"

  config = {
    workspace_id = module.workspace.workspace_id
    metastore_id = var.config.unity_catalog.metastore_id
  }
}

module "workspace_network" {
  source = "../../account/workspace_network"

  config = {
    workspace_id                   = module.workspace.workspace_id
    network_policy_id              = coalesce(var.config.serverless.network_policy_id, "default-policy")
    network_connectivity_config_id = var.config.serverless.network_connectivity_config_id
  }

  depends_on = [module.metastore_assignment]
}

module "workspace_permission_assignment" {
  source = "../../account/workspace_permission_assignment"

  config = {
    workspace_id                                = module.workspace.workspace_id
    deployment_service_principal_application_id = var.config.workspace_access.deployment_service_principal_application_id
    groups                                      = var.config.workspace_access.groups
    users                                       = var.config.workspace_access.users
    service_principals                          = var.config.workspace_access.service_principals
  }

  depends_on = [module.metastore_assignment]
}
