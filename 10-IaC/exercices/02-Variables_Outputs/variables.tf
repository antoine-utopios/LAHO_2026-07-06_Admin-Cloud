variable "image_name" {
  type        = map(string)
  description = "Les noms des images qui seront utilisées pour les conteneurs"
  default = {
    "web" = "nginx:latest"
    "database" : "mysql:9.0"
  }
}

variable "container_prefix" {
  type        = string
  description = "Le prefix servant au nommage des conteneurs"
  default     = "exo02"
}

variable "web_servers" {
  type        = map(number)
  description = "Les ports externe des serveurs webs"
  default = {
    "web"   = 8080
    "admin" = 8081
    "shop"  = 8082
  }
}

variable "database_ext_port" {
  type        = number
  description = "Le port externe utilisé par le conteneur de base de données"
  default     = 3306
}