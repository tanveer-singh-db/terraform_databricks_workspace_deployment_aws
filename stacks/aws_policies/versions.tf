terraform {
  required_version = ">= 1.10.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.81.0, < 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2, < 3.0"
    }
  }
}
