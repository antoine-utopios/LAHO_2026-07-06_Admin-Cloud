# Exercice Docker #1


Réaliser une image de conteneur compatible avec NGINX (serveur web): 
 
Pour cela, suivre les étapes suivantes: 
* Créer un conteneur Ubuntu 
* Entrer dans le conteneur Ubuntu
* Mettre à jour les paquets dans le conteneur
* Installer NGINX dans le conteneur
* Sortir du conteneur
* Sauvegarder l'état actuel du conteneur en tant que nouvelle image nommée par exemple "ubuntu-nginx"
 
---

## Correction

* Créer un conteneur Ubuntu 

```bash
docker run ubuntu

# Si l'on veut ne pas avoir à entrer manuellement dans le conteneur en étape 2
docker run -it ubuntu
```

* Entrer dans le conteneur Ubuntu

```bash
docker start -i id-conteneur|nom-conteneur
```

* Mettre à jour les paquets dans le conteneur

```bash
apt update
```

* Installer NGINX dans le conteneur

```bash
apt install -y nginx
```

* Sortir du conteneur

```bash
exit
```

* Sauvegarder l'état actuel du conteneur en tant que nouvelle image nommée par exemple "ubuntu-nginx"

```bash
docker commit id-conteneur ubuntu-nginx
```