#!/usr/bin/env bash
set -euo pipefail

warehouse_name="serverless-default"
poll_seconds=10
notebook_imported=false
notebook_path=""
notebook_file=""

usage() {
  echo "Usage: $0 [--warehouse-name NAME]" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --warehouse-name)
      (($# >= 2)) || usage
      warehouse_name=$2
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "${DATABRICKS_HOST:-}" ]]; then
  echo "DATABRICKS_HOST must be set." >&2
  exit 2
fi
if [[ -z "${DATABRICKS_TOKEN:-}" && ( -z "${DATABRICKS_CLIENT_ID:-}" || -z "${DATABRICKS_CLIENT_SECRET:-}" ) ]]; then
  echo "Set DATABRICKS_TOKEN or both DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET." >&2
  exit 2
fi
command -v databricks >/dev/null || {
  echo "databricks CLI is required." >&2
  exit 2
}

cleanup() {
  result=$?
  trap - EXIT
  if [[ "$notebook_imported" == true ]]; then
    if databricks workspace delete "$notebook_path" >/dev/null; then
      echo "PASS: temporary notebook deleted"
    else
      echo "FAIL: unable to delete temporary notebook $notebook_path" >&2
      result=1
    fi
  fi
  [[ -z "$notebook_file" ]] || rm -f "$notebook_file"
  exit "$result"
}
trap cleanup EXIT

export SMOKE_WAREHOUSE_NAME="$warehouse_name"
warehouses_json="$(databricks api get /api/2.0/sql/warehouses -o json)"
warehouse_id="$(python3 -c '
import json, os, sys
data = json.load(sys.stdin)
warehouses = data.get("warehouses", [])
name = os.environ["SMOKE_WAREHOUSE_NAME"]
def serverless(w):
    return w.get("enable_serverless_compute") is True and w.get("warehouse_type", "PRO") == "PRO"
matches = [w for w in warehouses if w.get("name") == name and serverless(w)]
if not matches:
    matches = [w for w in warehouses if serverless(w)]
print(matches[0].get("id", "") if matches else "")
' <<<"$warehouses_json")"
if [[ -n "$warehouse_id" ]]; then
  export SMOKE_WAREHOUSE_ID="$warehouse_id"
  selected_warehouse="$(python3 -c '
import json, os, sys
data=json.load(sys.stdin)
for w in data.get("warehouses", []):
    if w.get("id") == os.environ["SMOKE_WAREHOUSE_ID"]:
        print(w.get("name", ""))
        break
' <<<"$warehouses_json")"
  if [[ "$selected_warehouse" != "$warehouse_name" ]]; then
    echo "Using existing serverless SQL warehouse: $selected_warehouse"
  fi

  databricks api post "/api/2.0/sql/warehouses/$warehouse_id/start" --json '{}' -o json >/dev/null
  warehouse_deadline=$((SECONDS + 600))
  while :; do
    ((SECONDS < warehouse_deadline)) || {
      echo "FAIL: SQL warehouse $selected_warehouse did not start" >&2
      exit 1
    }
    warehouse_json="$(databricks api get "/api/2.0/sql/warehouses/$warehouse_id" -o json)"
    warehouse_state="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("state",""))' <<<"$warehouse_json")"
    [[ "$warehouse_state" == "RUNNING" ]] && break
    [[ "$warehouse_state" != "STOPPED" && "$warehouse_state" != "DELETED" ]] || {
      echo "FAIL: SQL warehouse $selected_warehouse stopped while starting" >&2
      exit 1
    }
    sleep "$poll_seconds"
  done

  statement_payload="$(python3 -c 'import json,os; print(json.dumps({"warehouse_id":os.environ["SMOKE_WAREHOUSE_ID"],"statement":"SELECT current_metastore(), current_version()","wait_timeout":"30s","on_wait_timeout":"CONTINUE"}))')"
  statement_json="$(databricks api post /api/2.0/sql/statements --json "$statement_payload" -o json)"
  statement_id="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("statement_id",""))' <<<"$statement_json")"
  [[ -n "$statement_id" ]] || {
    echo "FAIL: SQL statement submission did not return statement_id" >&2
    exit 1
  }

  statement_state="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",{}).get("state",""))' <<<"$statement_json")"
  deadline=$((SECONDS + 600))
  while [[ "$statement_state" == "PENDING" || "$statement_state" == "RUNNING" ]]; do
    ((SECONDS < deadline)) || {
      echo "FAIL: SQL statement timed out in state $statement_state" >&2
      exit 1
    }
    sleep "$poll_seconds"
    statement_json="$(databricks api get "/api/2.0/sql/statements/$statement_id" -o json)"
    statement_state="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",{}).get("state",""))' <<<"$statement_json")"
  done
  if [[ "$statement_state" != "SUCCEEDED" ]]; then
    echo "FAIL: SQL statement ended in state $statement_state" >&2
    python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",{}).get("error",{}).get("message",""))' <<<"$statement_json" >&2
    exit 1
  fi
  echo "PASS: serverless SQL statement on $selected_warehouse"
else
  echo "SKIP: no existing serverless SQL warehouse found; checking serverless jobs only"
fi

current_user="$(databricks current-user me -o json)"
user_name="$(python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("user_name") or data.get("userName", ""))' <<<"$current_user")"
[[ -n "$user_name" ]] || {
  echo "FAIL: unable to determine the authenticated user's name" >&2
  exit 1
}

timestamp="$(date +%s)"
notebook_path="/Users/$user_name/.smoke_test_serverless_$timestamp"
notebook_file="$(mktemp)"
printf '%s\n' 'print("serverless smoke test passed")' >"$notebook_file"
databricks workspace import "$notebook_path" --language PYTHON --format SOURCE --file "$notebook_file"
notebook_imported=true

export SMOKE_NOTEBOOK_PATH="$notebook_path"
run_payload="$(python3 -c '
import json, os
print(json.dumps({
    "run_name": "serverless-smoke-test",
    "tasks": [{
        "task_key": "serverless_notebook_smoke",
        "notebook_task": {
            "notebook_path": os.environ["SMOKE_NOTEBOOK_PATH"],
            "source": "WORKSPACE"
        }
    }]
}))
')"
run_json="$(databricks jobs submit --no-wait --performance-target STANDARD --json "$run_payload" -o json)"
run_id="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("run_id",""))' <<<"$run_json")"
[[ -n "$run_id" ]] || {
  echo "FAIL: jobs submit did not return run_id" >&2
  exit 1
}

deadline=$((SECONDS + 1800))
while :; do
  ((SECONDS < deadline)) || {
    echo "FAIL: serverless job run $run_id timed out" >&2
    exit 1
  }
  run_json="$(databricks jobs get-run "$run_id" -o json)"
  run_state="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("state",{}).get("life_cycle_state",""))' <<<"$run_json")"
  result_state="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("state",{}).get("result_state",""))' <<<"$run_json")"
  if [[ "$run_state" == "TERMINATED" || "$run_state" == "SKIPPED" || "$run_state" == "INTERNAL_ERROR" ]]; then
    break
  fi
  sleep "$poll_seconds"
done

if [[ "$result_state" != "SUCCESS" ]]; then
  echo "FAIL: serverless job run $run_id ended with state $result_state (lifecycle $run_state)" >&2
  exit 1
fi
echo "PASS: serverless notebook job run $run_id"
