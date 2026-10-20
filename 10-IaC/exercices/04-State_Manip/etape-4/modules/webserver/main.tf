resource "docker_image" "nginx" {
  name = var.image_name
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = var.container_name

  networks_advanced {
    name = var.network_name
  }

  dynamic "ports" {
    for_each = var.container_ports

    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
}