variable "repos" { type = list(string) }

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repos)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

output "repo_urls" {
  value = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}