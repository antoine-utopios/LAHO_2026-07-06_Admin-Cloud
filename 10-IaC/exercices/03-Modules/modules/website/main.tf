resource "docker_image" "nginx" {
  name = var.image_name
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = local.container_name

  ports {
    internal = 80
    external = var.container_external_port
  }
}