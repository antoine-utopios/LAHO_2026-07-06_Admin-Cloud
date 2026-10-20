data "docker_network" "shared_network" {
  name = var.network_name
}

removed {
  from = module.database

  lifecycle {
    destroy = false
  }
}

module "webservers" {
  for_each = var.web_servers
  source = "./modules/webserver"

  image_name     = var.web_image
  container_name = each.value.container_name
  container_ports = each.value.ports
  environment = [  ]
  network_name = data.docker_network.shared_network.name

  depends_on = [ module.database ]
}