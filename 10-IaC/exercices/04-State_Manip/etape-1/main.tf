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
}

module "webserver" {
  source = "./modules/webserver"

  image_name     = var.web_image
  container_name = "exo04-web"
  container_ports = [ {
    internal = 80
    external = 8080
  } ]
  environment = [  ]
}