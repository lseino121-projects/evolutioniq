# Top .001% DevOps Prep — GitOps-on-EKS Reference Monorepo

This single-file export contains a complete reference monorepo you can copy/paste into your own repo. It includes:
- Terraform (modular) to provision: VPC, EKS, ECR, IRSA, RDS (optional), Budgets/Cost Anomaly detection, and Terraform state backend (S3+DynamoDB).
- Dockerized demo app (React frontend + FastAPI backend) with CI for tests, SBOM, image scan, semver tags, and push to ECR.
- GitOps CD via Argo CD watching a dedicated `gitops/` folder with Helm charts & Argo Rollouts canary strategy.
- Security + policy checks with OPA/Conftest for Terraform and K8s manifests.
- Makefile and bootstrap scripts for a 1-command demo.

> ⚠️ **Costs**: EKS, RDS, NAT, and Budgets incur AWS charges. Prefer `t3.small`/`t4g.small` test sizes and a single-AZ pilot. Destroy when done.

---

## Repository Tree

```
.
├─ Makefile
├─ README.md
├─ scripts/
│  ├─ bootstrap.sh
│  ├─ teardown.sh
│  ├─ ecr_login.sh
│  └─ release_bump.py
├─ ci/
│  ├─ conftest/
│  │  ├─ terraform/
│  │  │  └─ deny-public-sg.rego
│  │  └─ kubernetes/
│  │     └─ no-latest-tag.rego
│  └─ semver/
│     └─ rules.json
├─ .github/workflows/
│  ├─ app-ci.yml
│  ├─ infra-plan-apply.yml
│  └─ gitops-validate.yml
├─ infra/
│  ├─ backend/
│  │  ├─ main.tf
│  │  └─ versions.tf
│  ├─ envs/
│  │  ├─ dev/
│  │  │  ├─ main.tf
│  │  │  ├─ providers.tf
│  │  │  ├─ variables.tf
│  │  │  └─ terraform.tfvars
│  │  └─ prod/
│  │     ├─ main.tf
│  │     ├─ providers.tf
│  │     ├─ variables.tf
│  │     └─ terraform.tfvars
│  └─ modules/
│     ├─ vpc/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     ├─ eks/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     ├─ ecr/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     ├─ rds/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     └─ budgets/
│        ├─ main.tf
│        └─ variables.tf
├─ app/
│  ├─ frontend/
│  │  ├─ Dockerfile
│  │  ├─ package.json
│  │  └─ src/index.html
│  └─ backend/
│     ├─ Dockerfile
│     ├─ pyproject.toml
│     └─ app/main.py
├─ charts/
│  └─ demo-stack/
│     ├─ Chart.yaml
│     ├─ values.yaml
│     └─ templates/
│        ├─ backend-deploy.yaml
│        ├─ backend-service.yaml
│        ├─ frontend-deploy.yaml
│        ├─ frontend-service.yaml
│        ├─ hpa.yaml
│        ├─ pdb.yaml
│        ├─ networkpolicy.yaml
│        └─ rollout.yaml
└─ gitops/
   ├─ argocd/
   │  ├─ namespace.yaml
   │  ├─ project.yaml
   │  └─ application.yaml
   └─ kustomization.yaml
```

## README.md (Interview-Ready Walkthrough)

```markdown
# Top .001% DevOps Prep — GitOps-on-EKS

## 1) What this proves in an interview
- **IaC (Terraform)**: Modular VPC, EKS, ECR, RDS, Budgets, S3/DynamoDB TF backend. Workspaces or per-env folders.
- **Kubernetes**: Deployments/Services, HPA, PDB, NetworkPolicy, Argo Rollouts canary.
- **Docker**: Multi-stage builds, healthchecks, minimal images.
- **CI/CD**: GitHub Actions with OIDC, SBOM (Syft), scan (Trivy), SemVer, push to ECR, GitOps update.
- **GitOps**: Argo CD Application auto-sync against `charts/demo-stack` path.
- **Security/Policy**: Conftest OPA checks for TF and K8s (no latest tag, no public SG).
- **Cost-Aware**: AWS Budgets alert.

## 2) One-command demo
```bash
make bootstrap ENV=dev AWS_PROFILE=default AWS_REGION=us-east-1
```
Then push app changes to trigger CI → images → GitOps chart bump → Argo CD sync → rollout.

## 3) Talking points for your panel
- **GitOps vs Push**: Why Argo CD pull-based reduces credential surface & drift.
- **IRSA** in EKS for least privilege vs node role.
- **Policy-as-code** shift-left: OPA gate on PRs, fail fast.
- **Cost controls**: Budget alarms + cluster right-sizing, HPA.
- **Versioning**: immutable tags, release notes, and Rollouts canary to reduce blast radius.
- **Terraform patterns**: remote state, state locking, modules, per-env separation, OIDC in CI.

## 4) Swap-ins
- Replace Helm with Kustomize overlays.
- Swap Trivy with Grype/Clair.
- Use Terraform Cloud/Enterprise instead of S3 backend; discuss SSO, Sentinel policies.

## 5) Cleanup
```bash
make teardown ENV=dev
```
# 📡 How Pods/Networking Connect to RDS (Interview Ready)


1. **RDS Placement**
- RDS lives in **private subnets** within the VPC.
- It has a private endpoint (`demo-postgres.XXXX.rds.amazonaws.com`).
- Not publicly accessible (good security practice).


2. **Pod Networking**
- EKS worker nodes are in the same VPC/subnets (or have routing to them).
- Each pod gets an IP from the VPC CIDR via CNI (AWS VPC CNI plugin).
- That means pods can directly reach the RDS endpoint over VPC-internal networking.


3. **DNS Resolution**
- Kubernetes pods resolve the RDS hostname via CoreDNS → VPC DNS → RDS endpoint.
- No special config needed, as long as the pod’s SG/NACL allows traffic.


4. **IAM/Secrets**
- Typically you’d store DB credentials in **AWS Secrets Manager** or K8s Secrets.
- Pods mount these as env vars.
- With IRSA, pods can assume an IAM role that grants read-only access to the secret.


5. **Security Groups**
- RDS SG allows inbound on port 5432 from the node group’s SG.
- Outbound from pods → nodes → VPC routing → RDS endpoint.


6. **Kubernetes Service Mesh (Optional)**
- In advanced setups, Istio/Linkerd handles service-to-service mTLS.
- But for DB, usually a direct connection over VPC.


---


## Interview Answer (Concise)


> “Pods in EKS get IPs from the VPC via the AWS CNI, so they can directly reach private endpoints like RDS over the VPC network. DNS resolution is handled automatically, and security groups restrict access to port 5432. DB creds are typically stored in Secrets Manager and pulled into pods with IRSA. That way networking is seamless but also secure.”