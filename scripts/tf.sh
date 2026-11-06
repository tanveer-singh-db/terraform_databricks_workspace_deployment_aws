#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <stack> <env> <region> <workspace> <init|plan|apply|destroy>" >&2
  echo "For account_regional, use: $0 account_regional account <region> - <action>" >&2
  exit 2
}

[[ $# -eq 5 ]] || usage

stack=$1
environment=$2
region=$3
workspace=$4
action=$5

case "$stack" in
  aws_policies|account_regional|workspace|workspace_config) ;;
  *) usage ;;
esac
case "$action" in
  init|plan|apply|destroy) ;;
  *) usage ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stack_dir="$repo_root/stacks/$stack"
if [[ "$stack" == "account_regional" ]]; then
  config_dir="$repo_root/configs/account/$region"
  backend_file="$config_dir/account_regional.s3.tfbackend"
else
  config_dir="$repo_root/configs/$environment/$region/$workspace"
  case "$stack" in
    aws_policies) backend_file="" ;;
    workspace) backend_file="$config_dir/workspace.s3.tfbackend" ;;
    workspace_config) backend_file="$config_dir/workspace_config.s3.tfbackend" ;;
  esac
fi
tfvars="$config_dir/terraform.tfvars"

[[ -d "$stack_dir" && -f "$tfvars" ]] || {
  echo "Stack or configuration not found: $stack_dir / $tfvars" >&2
  exit 2
}

cd "$stack_dir"
if [[ "$action" == "init" ]]; then
  if [[ -n "$backend_file" ]]; then
    terraform init -reconfigure -input=false -backend-config="$backend_file"
  else
    terraform init -reconfigure -input=false
  fi
else
  terraform "$action" -input=false -var-file="$tfvars"
fi
