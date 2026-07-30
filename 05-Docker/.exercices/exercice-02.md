# Exercice Docker #2

Déployer, au moyen de Docker, une image du jeu 2048: 

* Trouver dans le registre d'images de conteneur public DockerHub, une image compatible du jeu 2048
* Récupérer l'image localement
* Lancer un conteneur basé sur l'image de l'application (faire en sorte que celle-ci soit disponible au port hôte 8080, ou 8090 si non disponible)
* Naviguer, via le navigateur de l'ordinateur (pas via le conteneur) vers http://localhost:8080 et faire en sorte de voir l'application
* Réaliser le meilleur score possible en attendant la correction

---

## Correction 

* Trouver dans le registre d'images de conteneur public DockerHub, une image compatible du jeu 2048

```bash
# Chercher via le CLI 
docker search 2048

# Chercher via l'interface graphique (Docker Desktop / Dockerhub)
```

* Récupérer l'image localement

```bash
docker pull oats87/2048
```

* Lancer un conteneur basé sur l'image de l'application (faire en sorte que celle-ci soit disponible au port hôte 8080, ou 8090 si non disponible)

```bash
# Pour savoir quel est le port exposé par l'image, on peut l'inspecter via...
docker inspect oats87/2048

# On lance un conteneur en détaché et via la redirection de ports (8090 vers 80)
docker run -d -p 8090:80 oats87/2048
```

* Naviguer, via le navigateur de l'ordinateur (pas via le conteneur) vers http://localhost:8080 et faire en sorte de voir l'application

```bash
# Si on voulait vérifier la présence du site au bon nom de domaine et port, on peut le faire via un curl
curl http://localhost:8090
```

* Réaliser le meilleur score possible en attendant la correction