variable "image_name" {
  type = string
  description = "Le nom de l'image utilisée par le module pour faire le conteneur"
}

variable "container_name" {
  type = string
  description = "Le nom utilisé par le module pour nommer le conteneur"
}

variable "container_ports" {
  type = list(object({
    internal = number
    external = number
  }))
  description = "Les ports utilisé par le module pour faire le port-forwarding du conteneur"
}

variable "environment" {
  type = list(string)
  description = "Environement utilisé par le module pour faire celui du conteneur"
}

variable "root_password" {
  type = string
  description = "Le mot de passe de l'utilisateur racine"
  sensitive = true
}

variable "database_name" {
  type = string
  description = "Le nom de la base de données"
  default = "testDB"
}

variable "network_name" {
  type = string
  description = "Le nom du réseau utilisé par le conteneur"
}