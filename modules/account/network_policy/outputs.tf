output "network_policy_id" {
  value = databricks_account_network_policy.this.network_policy_id
}

output "restriction_mode" {
  value = databricks_account_network_policy.this.egress.network_access.restriction_mode
}
