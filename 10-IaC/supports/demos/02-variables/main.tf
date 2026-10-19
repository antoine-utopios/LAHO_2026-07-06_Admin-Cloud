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
  name = var.image_name
}

## VERSION SANS BOUCLE

# resource "docker_container" "web" {
#   image = docker_image.nginx.image_id
#   name  = var.web_servers[0]

#   ports {
#     internal = 80
#     external = var.external_ports[0]
#   }
# }

# resource "docker_container" "admin" {
#   image = docker_image.nginx.image_id
#   name  = var.web_servers[1]

#   ports {
#     internal = 80
#     external = var.external_ports[1]
#   }
# }

# resource "docker_container" "shop" {
#   image = docker_image.nginx.image_id
#   name  = var.web_servers[2]

#   ports {
#     internal = 80
#     external = var.external_ports[2]
#   }
# }

## VERSION BOUCLE - COUNT 

# resource "docker_container" "web" {
#   count = 3
#   image = docker_image.nginx.image_id
#   name  = var.web_servers[count.index]

#   ports {
#     internal = 80
#     external = var.external_ports[count.index]
#   }
# }

## VERSION BOUCLE - FOR_EACH

resource "docker_container" "web" {
  for_each = var.web_servers
  image = docker_image.nginx.image_id
  name  = "${var.container_prefix}-${each.key}"

  ports {
    internal = 80
    external = each.value
  }
}