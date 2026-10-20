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

# Récupérée depuis le fichier secrets.local.tfvars (non commité)
variable "db_root_password" {
  description = "Mot de passe de l'administrateur de la base de données"
  type        = string
  sensitive = true
}

