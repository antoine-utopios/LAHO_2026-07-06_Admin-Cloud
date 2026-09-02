# Exercice Kubernetes #5 - Réalisation d'un déploiement d'applicatif Java

## Sujet 

Réaliser, via minikube ainsi l'approche déclarative de K8s, un déploiement via un pod de l'application 2048 déservie par un serveur Tomcat (image docker de `quchaonet`)

* Créer un cluster

```bash
minikube start
```

* Se connecter au cluster

```bash
minikube set-context minikube
```

* Créer le fichier de manifeste

```yaml
# 2048.yaml

apiVersion: v1
kind: Pod
metadata:
  name: exo-05-pod
specs:
  containers:
    - name: exo-05-container
      image: quchaonet/2048:latest
      resources:
        requests:
          memory: "128Mi"
          cpu: "250m"
        limits:
          memory: "512Mi"
          cpu: "1"
```

* Déployer un pod de l'application voulue

```bash
kubectl apply -f manifests/2048.yaml
```