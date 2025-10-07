variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.33"
}