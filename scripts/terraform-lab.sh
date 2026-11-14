#!/usr/bin/env bash
# Rôle : Initialise/valide/planifie le LAB avec état Linux privé ; aucun apply automatique et aucun état dans Git.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/taoufik-gitops/lab"
umask 077
mkdir -p "$state_dir"
chmod 700 "$state_dir"
export TF_VAR_subscription_id
TF_VAR_subscription_id=$(az account show --query id -o tsv)
mode=${1:-plan}
case "$mode" in
  init)
    terraform -chdir="$root/environments/lab" init -reconfigure -input=false \
      -backend-config="path=$state_dir/terraform.tfstate" ;;
  plan)
    terraform -chdir="$root/environments/lab" plan -input=false -out="$state_dir/infra.tfplan" ;;
  validate)
    terraform -chdir="$root/environments/lab" validate ;;
  *) echo 'Usage: terraform-lab.sh init|plan|validate' >&2; exit 2 ;;
esac
