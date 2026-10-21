import {
  to = docker_network.demo_net
  id = "8a0d49b58b8db8ecd3304337b1feb1c59c693ae4460de387ee7e6244b64b12a5"
}

resource "docker_network" "demo_net" {
  name = "demo-net"
}

removed {
  from = docker_network.demo_net

  lifecycle {
    destroy = false
  }
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# resource "docker_container" "web" {
#   image = docker_image.nginx.image_id
#   name  = "demo-container-web"

#   ports {
#     internal = 80
#     external = 8080
#   }

#   networks_advanced {
#     name = docker_network.demo_net.name
#   }
# }

# resource "docker_container" "shop" {
#   image = docker_image.nginx.image_id
#   name  = "demo-container-shop"

#   ports {
#     internal = 80
#     external = 8081
#   }

#   networks_advanced {
#     name = docker_network.demo_net.name
#   }
# }

moved {
  from = docker_container.web
  to = docker_container.webservers["web"]
}

moved {
  from = docker_container.shop
  to = docker_container.webservers["shop"]
}

resource "docker_container" "webservers" {
for_each = var.web_servers
  image = docker_image.nginx.image_id
  name  = "demo-container-${each.key}"

  ports {
    internal = 80
    external = each.value
  }

  networks_advanced {
    name = data.docker_network.demo_net.name
  }
}
