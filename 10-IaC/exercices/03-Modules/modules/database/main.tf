resource "docker_image" "mysql" {
  name = var.image_name
}

resource "docker_container" "database" {
  image = docker_image.mysql.image_id
  name  = local.container_name

  ports {
    internal = 3306
    external = var.container_external_port
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.root_password}", 
    "MYSQL_USER=${var.user_name}", 
    "MYSQL_PASSWORD=${var.user_password}", 
    "MYSQL_DATABASE=${var.database_name}"
    ]
}