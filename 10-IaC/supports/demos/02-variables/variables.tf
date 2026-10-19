variable "image_name" {
  type        = string
  description = "Le nom de l'image qui sera utilisée par le conteneur futur"
  default     = "nginx:alpine"
}

variable "container_prefix" {
  type = string
  description = "Le prefix servant au nommage des conteneurs"
  default = "demo"
}

## VARIABLES POUR BOUCLE - COUNT 

# Les noms de servers

# variable "web_servers" {
#   type        = list(string)
#   description = "Le nom des conteneurs de notre infrastructure"
# #   default     = ["web", "admin", "shop"]
#   default     = ["web", "shop"]
# }

# Les ports externes de servers

# variable "external_ports" {
#   type        = list(number)
#   description = "Les ports externes des conteneurs de notre infrastructure"
# #   default     = [8080, 8081, 8082]
#   default     = [8080, 8082]
# }

## VARIABLE POUR BOUCLE - FOR_EACH

# L'ensemble nom / ports externes de servers

variable "web_servers" {
  type = map(number)
  description = "Les ports externe des serveurs webs"
  default = {
    "web" = 8080
    "admin" = 8081
    "shop" = 8082
  }
}