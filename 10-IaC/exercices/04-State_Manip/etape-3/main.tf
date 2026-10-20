data "docker_network" "shared_network" {
  name = var.network_name
}

module "database" {
  source = "./modules/database"

  image_name     = var.db_image
  container_name = "exo04-db"
  database_name = "testDB"
  container_ports = [ {
    internal = 3306
    external = 3306
  } ]
  environment = [  ]
  root_password = var.db_root_password
  network_name = data.docker_network.shared_network.name
}

moved {
  from = module.webserver
  to = module.webservers["web"]
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