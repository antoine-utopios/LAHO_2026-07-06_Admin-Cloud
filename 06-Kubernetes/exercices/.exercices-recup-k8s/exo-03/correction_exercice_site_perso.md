# Exercice Kubernetes #3 - Réalisation d'un déploiement multiple

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement d'un site web personnalisé. Le site web devra posséder idéalement plusieurs pages, un fichier de CSS ainsi qu'une page d'accueil porteuse du titre `Exercice 03 terminé!` mis en valeur via du CSS.

* Créer l'image de notre applicatif

```bash
# Créer la structure des fichiers du site web...

# Créer le Dockerfile correspondant...

docker build -t <registry-name>/<image-name>:<tag> /path/to/dockerfile
```

* Héberger notre image dans un registre d'image de conteneur public

```bash
docker push <registry-name>/<image-name>:<tag> /path/to/dockerfile
```

* Créer un cluster

```bash
minikibe start
```

* Se connecter au cluster

```bash
kubectl set-context minikube
```

* Déployer un pod de l'application via son image publique

```bash
kubectl create deployment exo-03 --image=<registry-name>/<image-name>:<tag>
```

* Créer un service Kubernetes permettant d'exposer le déploiement au monde extérieur

```bash
kubectl expose deployment exo-03 --type=LoadBalancer --port=80
```

* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte

```bash
minikube service exo-03
```

* Scaler notre applicatif en une version disposant de 3 réplicats


```bash
kubectl scale deployment/exo-03 --replicas=3
```