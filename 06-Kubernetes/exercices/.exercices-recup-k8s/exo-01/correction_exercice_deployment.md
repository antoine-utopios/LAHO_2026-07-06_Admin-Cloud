# Exercice Kubernetes #1 - Réalisation d'un déploiement de base

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement de la page d'accueil par défaut de NGINX

* Créer un cluster

```bash
minikube start
```

* Se connecter au cluster

```bash
kubectl set-context minikube
```

* Déployer un pod de l'application NGINX avec le tag `alpine`

```bash
kubectl create deployment exo-01 --image=nginx:alpine
```

* Créer un service Kubernetes permettant d'exposer le déploiement au sein du cluster

```bash
kubectl expose deployment exo-01 --type=ClusterIP --port=80
```

* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte

```bash
minikube service exo-01
```