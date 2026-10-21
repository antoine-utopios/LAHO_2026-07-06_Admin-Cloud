resource "docker_image" "nginx" {
  name = "nginx:latest"
}

## A créer : 
# docker_container.server['web']
# docker_container.server['shop']
# docker_container.server['admin']
resource "docker_container" "servers" {
    for_each = var.webservers_config
    image = docker_image.nginx.image_id
    name  = "container-${each.key}"

    ports {
        internal = 80
        external = each.value
    }
}