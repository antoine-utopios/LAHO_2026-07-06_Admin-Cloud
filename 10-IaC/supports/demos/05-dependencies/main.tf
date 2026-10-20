

resource "docker_image" "mysql" {
  name = "mysql:9.0"
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_network" "demo_dependencies" {
  name = "dependencies-net"
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "demo-nginx"
  depends_on = [ docker_container.database ]

  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.demo_dependencies.name
  }
}

resource "docker_container" "database" {
  image = docker_image.nginx.image_id
  name  = "demo-db"

  ports {
    internal = 3306
    external = 3306
  }

  env = ["MYSQL_ROOT_PASSWORD=password"]
}