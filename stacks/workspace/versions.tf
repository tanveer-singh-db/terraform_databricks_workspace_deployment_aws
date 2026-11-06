terraform {
  required_version = ">= 1.10.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.81.0, < 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0, < 1.0"
    }
  }
}
