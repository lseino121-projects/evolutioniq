module "github_oidc" {
  source    = "../../modules/github-oidc"
  repo      = "lseino121-projects/evolutioniq"
  role_name = "github-oidc-ecr"
  extra_policies = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
