variable "web_image" {
  description = "Image du jeu 2048"
  type        = string
  default     = "quchaonet/2048"
}

variable "db_image" {
  description = "Image de MySQL"
  type        = string
  default     = "mysql:9.0"
}

variable "db_name" {
  description = "Nom de la base de données par défaut"
  type        = string
  default     = "testDB"
}

variable "web_servers" {
  type = map(object({
    container_name = string
    ports = list(object({
      internal = number
      external = number
    })) 
  }))

  default = {
    "web" = {
      container_name = "web"
      ports = [{
        internal = 80
        external = 8080
      }]
    }
    "shop" = {
      container_name = "shop"
      ports = [{
        internal = 80
        external = 8081
      }]
    }
    "admin" = {
      container_name = "admin"
      ports = [{
        internal = 80
        external = 8082
      }]
    }
  }
}

# Récupérée depuis le fichier secrets.local.tfvars (non commité)
variable "db_root_password" {
  description = "Mot de passe de l'administrateur de la base de données"
  type        = string
  sensitive = true
}

variable "network_name" {
  type = string
  description = "Le nom du réseau utilisé par les conteneurs"
}