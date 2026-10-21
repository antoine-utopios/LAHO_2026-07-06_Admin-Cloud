resource "docker_container" "web" {
  for_each = var.targets

  name  = "lab-${each.key}"
  image = "lab-ansible-target:latest"

  privileged = true
  tmpfs = {
    "/run"      = ""
    "/run/lock" = ""
  }

  ports {
    internal = 22
    external = each.value
  }
}
