#!/usr/bin/env bash
set -euo pipefail
ENV=${1:-dev}
REGION=${2:-us-east-1}

pushd infra/envs/$ENV
terraform destroy -auto-approve -var="region=$REGION"
popd