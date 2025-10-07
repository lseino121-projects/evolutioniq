# 1. OIDC provider for GitHub (only needs to exist once per account)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Role scoped to the repo
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # Replace * with :ref:refs/heads/main to limit to main branch
            "token.actions.githubusercontent.com:sub" = "repo:${var.repo}:*"
          }
        }
      }
    ]
  })
}

# 3. Attach default ECR policy
resource "aws_iam_role_policy_attachment" "ecr_poweruser" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 4. Attach any extras (like AdministratorAccess for Terraform)
resource "aws_iam_role_policy_attachment" "extras" {
  for_each   = toset(var.extra_policies)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
