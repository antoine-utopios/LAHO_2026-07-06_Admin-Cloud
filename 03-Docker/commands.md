# Commandes Docker

## Connaître la version sur serveur et du client 

```bash
docker version
```

## Fonctionnament du nom des images Docker 

* Serveur où se trouve l'image
* Le nom du registre d'image de conteneur 
* Le nom de l'image

```text
server/registry/image
```

## Récupérer une image de conteneur

```bash
docker pull <nom-image>
```

## Lancer une image de conteneur

```bash
docker run <nom-image>

# Mode intéractif
docker run -i <nom-image>

# Mode détaché
docker run -d <nom-image>

# Mode profil TTY
docker run -t <nom-image>

# Mode port-forwarding
docker run -p <port-hote>:<port-container> <nom-image>
```

## Lister les conteneurs

```bash
docker container ls

# Alias de la commande précédente
docker ps

# Voir aussi les conteneurs stoppés
docker ps -a
```

## Lister les images de conteneur

```bash
docker image ls

# Alias de la commande précédente
docker images
```

## Obtenir des informations sur les ressources Docker

```bash
docker inspect <resource-id|resource-name>
```

## Voir les logs d'un conteneur

```bash
docker logs <container-id|container-name>
```

## Créer une sauvegarde de l'état actuel du conteneur

```bash
docker commit <container-id|container-name> <image-name>
```

## Installer NGINX sur UBUNTU

```bash
# Mettre à jour le registre des paquets 
sudo apt update 
# Installer les deux paquets
sudo apt install -y nginx systemctl 
# Vérifier le service NGINX
sudo systemctl status nginx

# Démarrer le service NGINX
sudo systemctl start nginx 
# Créer le symlink pour le service NGINX
sudo systemctl enable nginx 

# Créer le symlink et démarrer en même temps le service NGINX
sudo systemctl enable --now nginx 

# Vérifier le service NGINX
sudo systemctl status nginx 
```