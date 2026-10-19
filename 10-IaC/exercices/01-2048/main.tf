# Définir le contexte de Terraform, sa configuration et les providers à télécharger 
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

# Activer et configurer le provider Docker
provider "docker" {}

# Récupérer (pull) une image Docker et en faire une ressource Terraform
resource "docker_image" "game" {
  name = "quchaonet/2048:latest"
}

# Créer un conteneur Docker à partir de l'image récupérée précédemment (dépendance implicite)
resource "docker_container" "game" {
  image = docker_image.game.image_id
  name  = "exo01-2048"

  ports {
    internal = 8080
    external = 80
  }
}