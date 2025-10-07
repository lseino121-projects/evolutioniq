SHELL := /bin/bash

AWS_REGION ?= us-east-1
ENV ?= dev
ECR_REPO ?= demo
APP_VERSION ?= 0.1.0
ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Create backend + infra + kubectl context + ArgoCD
	./scripts/bootstrap.sh $(ENV) $(AWS_REGION)

teardown: ## Destroy env
	./scripts/teardown.sh $(ENV) $(AWS_REGION)

login-ecr: ## Docker login to ECR
	./scripts/ecr_login.sh $(AWS_REGION)

build-app: login-ecr ## Build & push images (frontend/backend)
	ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text); \
	FRONT=$$ACCOUNT_ID.dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO)-frontend:$(APP_VERSION); \
	BACK=$$ACCOUNT_ID.dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO)-backend:$(APP_VERSION); \
	docker buildx build --platform linux/amd64 -t $$FRONT apps/frontend --push; \
	docker buildx build --platform linux/amd64 -t $$BACK apps/backend --push


release-bump: ## Bump semver (patch by default)
	python3 scripts/release_bump.py $(APP_VERSION) patch
