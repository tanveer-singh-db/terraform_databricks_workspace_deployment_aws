resource "databricks_compliance_security_profile_workspace_setting" "this" {
  count = var.config.compliance_security_profile == null ? 0 : 1

  compliance_security_profile_workspace {
    is_enabled           = var.config.compliance_security_profile.enabled
    compliance_standards = var.config.compliance_security_profile.standards
  }
}

resource "databricks_enhanced_security_monitoring_workspace_setting" "this" {
  count = var.config.enhanced_security_monitoring == null ? 0 : 1

  enhanced_security_monitoring_workspace {
    is_enabled = var.config.enhanced_security_monitoring
  }
}

resource "databricks_disable_legacy_dbfs_setting" "this" {
  count = var.config.disable_legacy_dbfs == null ? 0 : 1

  disable_legacy_dbfs {
    value = var.config.disable_legacy_dbfs
  }
}

resource "databricks_disable_legacy_access_setting" "this" {
  count = var.config.disable_legacy_access == null ? 0 : 1

  disable_legacy_access {
    value = var.config.disable_legacy_access
  }
}
