terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name = var.image_name["web"]
}

resource "docker_image" "mysql" {
  name = var.image_name["database"]
}

resource "docker_container" "web" {
  for_each = var.web_servers
  image    = docker_image.nginx.image_id
  name     = "${var.container_prefix}-${each.key}"

  ports {
    internal = 80
    external = each.value
  }
}

resource "docker_container" "database" {
  image = docker_image.mysql.image_id
  name  = "${var.container_prefix}-db"

  ports {
    internal = 3306
    external = var.database_ext_port
  }

  env = ["MYSQL_ALLOW_EMPTY_PASSWORD=true", "MYSQL_USER=user", "MYSQL_PASSWORD=password", "MYSQL_DATABASE=testDB"]
}