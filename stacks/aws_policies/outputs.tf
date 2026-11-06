output "assume_role_policy_json" {
  value = data.databricks_aws_assume_role_policy.this.json
}

output "root_bucket_policy_json" {
  value = data.databricks_aws_bucket_policy.this.json
}

output "crossaccount_policy_json_by_security_group" {
  value = { for id, policy in data.databricks_aws_crossaccount_policy.this : id => policy.json }
}

output "policy_files" {
  value = [for policy in local_file.policies : policy.filename]
}
