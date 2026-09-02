# Exercice Kubernetes #2 - Réalisation d'un déploiement d'applicatif Java

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement de l'application 2048 déservie par un serveur Tomcat (image docker de `quchaonet`)

* Créer un cluster

```bash
minikube start
```

* Se connecter au cluster

```bash
kubectl set-context minikube
```

* Déployer un pod de l'application voulue

```bash
kubectl create deployment exo-02 --image=quchaonet/2048:latest
```

* Créer un service Kubernetes de type `LoadBalancer` permettant d'exposer le déploiement au monde extérieur

```bash
kubectl expose deployment exo-02 --type=LoadBalancer --port=8080
```

* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte

```bash
minikube service exo-02
```