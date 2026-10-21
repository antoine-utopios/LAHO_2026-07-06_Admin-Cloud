## A créer : 
# docker_container.web
# resource "docker_container" "web" {
#   image = docker_image.nginx.image_id
#   name  = "container-${var.container_name_web}"

#   ports {
#     internal = 80
#     external = var.container_external_port_web
#   }
# }

## A créer : 
# docker_container.shop
# resource "docker_container" "shop" {
#   image = docker_image.nginx.image_id
#   name  = "container-${var.container_name_shop}"

#   ports {
#     internal = 80
#     external = var.container_name_shop
#   }
# }

## A créer : 
# docker_container.admin
# resource "docker_container" "admin" {
#   image = docker_image.nginx.image_id
#   name  = "container-${var.container_external_port_admin}"

#   ports {
#     internal = 80
#     external = var.container_name_admin
#   }
# }