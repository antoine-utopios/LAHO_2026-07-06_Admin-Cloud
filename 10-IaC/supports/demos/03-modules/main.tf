# module "website_web" {
#   source = "./modules/website/"

#   image_name = "nginx:latest"
#   container_prefix = "demo"
#   container_suffix = "web"
#   container_external_port = 8090
# }

# module "website_admin" {
#   source = "./modules/website/"

#   image_name = "nginx:latest"
#   container_prefix = "demo"
#   container_suffix = "admin"
#   container_external_port = 8091
# }

# module "website_shop" {
#   source = "./modules/website/"

#   image_name = "nginx:latest"
#   container_prefix = "demo"
#   container_suffix = "shop"
#   container_external_port = 8092
# }

module "websites" {
  for_each = var.web_servers
  source   = "./modules/website/"

  image_name              = "nginx:latest"
  container_prefix        = "demo"
  container_suffix        = each.key
  container_external_port = each.value
}
