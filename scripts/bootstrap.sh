#!/usr/bin/env bash
set -euo pipefail
ENV=${1:-dev}
REGION=${2:-us-east-1}


export AWS_REGION="$REGION"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)


# Step 1: Bootstrap backend if not already present
pushd infra/bootstrap
terraform init -input=false
terraform apply -auto-approve -input=false -var="region=$REGION" -var="account_id=$ACCOUNT_ID"
popd


# Step 2: Provision environment with remote state
pushd infra/envs/$ENV
terraform init -reconfigure -input=false
terraform apply -auto-approve -input=false -var="region=$REGION" -var="account_id=$ACCOUNT_ID"
EKS_NAME=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region "$REGION" --name "$EKS_NAME"
popd


# Step 3: Install Argo CD
kubectl apply -f gitops/argocd/namespace.yaml
kubectl -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=180s || true
kubectl apply -f gitops/argocd/project.yaml
kubectl apply -f gitops/argocd/application.yaml


# Step 4: Print Argo admin password
printf "\nArgo CD admin password (initial):\n"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo