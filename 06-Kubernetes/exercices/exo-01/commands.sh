# Créer le déploiement du conteneur Docker avec le jeu 2048
kubectl create deployment exo-01 --image=quchaonet/2048 --replicas=5

# Créer un service permettant d'atteindre du monde extérieur le déploiement (LoadBalancer)
kubectl expose deploy/exo-01 --type=LoadBalancer --port=8080

# Vu qu'on a pas d'adresse IP externe, on doit réaliser un port-forward pour atteindre notre déploiement...
kubectl port-forward svc/exo-01 8080:8080

# Adresse IP externe cluster => Service => Deployment => ReplicaSet => Pods => Containers 