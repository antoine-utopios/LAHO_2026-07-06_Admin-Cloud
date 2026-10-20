module "websites" {
  for_each = var.web_servers
  source   = "./modules/website/"

  image_name              = "nginx:latest"
  container_prefix        = "exo03"
  container_suffix        = each.key
  container_external_port = each.value
}

module "database_mysql" {
  source = "./modules/database"

  image_name              = "mysql:9.0"
  container_prefix        = "exo03"
  container_suffix        = "db"
  container_external_port = 3306

  root_password = var.root_password
  user_name     = "user"
  user_password = var.user_password
  database_name = "exo03"
}

module "database_mysql_bis" {
  source = "./modules/database"

  image_name              = "mysql:9.0"
  container_prefix        = "exo03"
  container_suffix        = "db-bis"
  container_external_port = 3307

  root_password = var.root_password
  user_name     = "user"
  user_password = var.user_password
  database_name = "exo03"
}