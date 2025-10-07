package terraform.security

deny[msg] {
  input.resource_type == "aws_security_group"
  input.ingress[_].cidr_blocks[_] == "0.0.0.0/0"
  msg := sprintf("SecurityGroup %s allows public ingress", [input.name])
}