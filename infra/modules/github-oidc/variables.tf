variable "repo" {
  description = "GitHub repo in format org/repo"
  type        = string
}

variable "role_name" {
  description = "Name for the IAM role to create"
  type        = string
  default     = "github-oidc-role"
}

variable "extra_policies" {
  description = "Additional IAM policy ARNs to attach"
  type        = list(string)
  default     = []
}
