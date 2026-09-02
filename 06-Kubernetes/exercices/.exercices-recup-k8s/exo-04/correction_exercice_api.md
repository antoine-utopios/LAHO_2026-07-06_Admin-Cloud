# Exercice Kubernetes #4 - Réalisation d'un déploiement mise à jour

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement d'un applicatif personnel. Il pourra s'agir par exemple d'une API réalisée avec Express. Cet applicatif sera mis à jour par la suite de sorte à tester le mécanisme des rollouts de K8s.

* Créer l'image de notre applicatif

```bash
# Réaliser l'application Node.js...

# Créer une image Docker de l'applicatif...
docker build -t <registry-name>/<image-name>:v1 /path/to/Dockerfile
```

* Héberger notre image dans un registre d'image de conteneur public

```bash
docker push <registry-name>/<image-name>:v1
```

* Créer un cluster

```bash
minikube start
```

* Se connecter au cluster

```bash
kubectl set-context minikube
```

* Déployer un pod de l'application via son image publique

```bash
kubectl create deployment exo-04 --image=<registry-name>/<image-name>:v1
```

* Créer un service Kubernetes permettant d'exposer le déploiement au monde extérieur

```bash
kubectl expose deployment exo-04 --type=LoadBalancer --port=3000
```

* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte

```bash
minikube service exo-04
```

* Tester le fonctionnement de notre applicatif via un client REST

```bash
curl -v http://<ip-minikube>:<port-minikube>/api/v1/hello
```

* Créer une nouvelle version de notre applicatif avec de nouveaux endpoints

```bash
# On modifie le code...

# Créer une nouvelle image Docker de l'applicatif...
docker build -t <registry-name>/<image-name>:v2 /path/to/Dockerfile

# On pousse sur Dockerhub la nouvelle version...
docker push <registry-name>/<image-name>:v2
```

* Mettre à jour le déploiement au sein du cluster

```bash
kubectl set image deployment/exo-04 <image-name>=<registry-name>/<image-name>:v2
```

* Tester la présence des nouvelles routes dans le client REST

```bash
curl -v http://<ip-minikube>:<port-minikube>/api/v1/blabla
```