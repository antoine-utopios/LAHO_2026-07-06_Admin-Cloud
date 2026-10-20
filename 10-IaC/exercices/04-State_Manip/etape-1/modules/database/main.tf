resource "docker_image" "mysql" {
  name = var.image_name
}

resource "docker_container" "database" {
  image = docker_image.mysql.image_id
  name  = var.container_name

  dynamic "ports" {
    for_each = var.container_ports

    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  env = concat(var.environment,  [ "MYSQL_ROOT_PASSWORD=${var.root_password}"])
}