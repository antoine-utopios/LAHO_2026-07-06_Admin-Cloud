resource "docker_container" "web" {
  for_each = var.targets

  name  = "lab-${each.key}"
  image = "lab-ansible-target:latest"

  ports {
    internal = 22
    external = each.value
  }
}
