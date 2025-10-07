#!/usr/bin/env bash
set -euo pipefail
REGION=${1:-us-east-1}
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com