# Commandes de base de K8s

## Minikube

* Démarrer le cluster Minikube

```bash
minikube start
```

* Mettre en pause le cluster Minikube

```bash
minikube stop
```

* Voir l'état du cluster Minikube

```bash
minikube status
```

* Afficher le dashboard (interface web) du cluster Minikube

```bash
minikube dashboard
```

* Supprimer le cluster Minikube

```bash
minikube delete
```

* Accéder au service présent sur le cluster Minikube

```bash
minikube service service/nom-service
```

## Kind

* Créer un cluster avec KinD

```bash
kind create cluster
```

* Créer un cluster personnalisé avec KinD

```bash
kind create cluster --name nom --config fichier-config.yaml
```

* Supprimer le cluster KinD
```bash
kind delete cluster

kind delete cluster --name nom
```

* Voir la liste des clusters KinD
```bash
kind get clusters
```

## K8s

* Afficher les ressources présentes dans le cluster

```bash
# Toutes les ressources de base
kubectl get all

# Pods
kubectl get pods

# ReplicaSets
kubectl get replicasets

# Deployments
kubectl get deployments

# Services
kubectl get services
```

* Supprimer une ressource

```bash
kubectl delete type nom

kubectl delete type/nom
```

* Exposer un deployment

```bash
kubectl expose deployment/nom

kubectl expose deployment nom
```

* Créer un pod

```bash
kubectl run nom-pod --image=image-docker
```

* Créer un deployment

```bash
kubectl create deployment nom-deployment --image=image-docker --replicas=3
```

* Scaler manuellement un deployment

```bash
kubectl scale deployment nom-deployment --replicas=3
```

* Réaliser un redirection des ports

```bash
kubectl port-forward service nom --port <container-port>
```