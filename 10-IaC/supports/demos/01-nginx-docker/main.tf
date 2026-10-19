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
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

# Créer un conteneur Docker à partir de l'image récupérée précédemment (dépendance implicite)
resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "demo-nginx"
  
  ports {
    internal = 80
    external = 8080
  }
}