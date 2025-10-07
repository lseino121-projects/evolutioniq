package k8s.images

deny[msg] {
  some i
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[i]
  endswith(container.image, ":latest")
  msg := sprintf("%s uses latest tag", [container.name])
}