variable "image_name" {
  type = string
  description = "Le nom de l'image utilisée par le module pour faire le conteneur"
}

variable "container_prefix" {
  type = string
  description = "Le préfix de nommage utilisé par le module pour nommer le conteneur"
}
variable "container_suffix" {
  type = string
  description = "Le suffixe de nommage utilisé par le module pour faire le conteneur"
}
variable "container_external_port" {
  type = number
  description = "Le port externe utilisé par le module pour faire le port-forwarding du conteneur"
}