# Exercice Kubernetes #6 - Réalisation d'un déploiement de serveurs webs multiples

## Sujet 

Réaliser, via minikube ainsi l'approche déclarative de K8s, un déploiement via un pod d'un conteneur de type NGINX dont la page d'accueil devra retourner l'adresse IP privée du serveur sur lequel elle tourne. 

* Créer ou trouver une image répondant aux besoins métiers

```bash
# init.sh

#!/bin/sh

# Récupère la première IP du conteneur
IP=$(hostname -i)

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Réplica NGINX</title>
  <style>
    body { font-family: sans-serif; display: flex; justify-content: center;
           align-items: center; height: 100vh; margin: 0; background: #f0f4f8; }
    .card { background: white; padding: 2rem 3rem; border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,.1); text-align: center; }
    h1 { color: #2d6a4f; }
    code { background: #e8f4ea; padding: .2rem .6rem; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Adresse IP du conteneur</h1>
    <p><code>${IP}</code></p>
  </div>
</body>
</html>
EOF

exec nginx -g "daemon off;"
```

```dockerfile
# Dockerfile

FROM nginx:alpine

COPY init.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

* La rendre disponible pour notre cluster 

```bash
docker build -t <registry-name>/<image-name> /path/to/Dockerfile

docker push <registry-name>/<image-name>
```

* Créer un cluster

```bash
minikube start
```

* Se connecter au cluster

```bash
minikube set-context minikube
```

* Créer les fichiers de manifeste
  * Créer le fichier de déploiement

```yaml
# k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment

metadata:
  name: exo-06-deployment

spec:
  replicas: 3
  selector:
    matchLabels:
      app: exo-06
      tier: frontend
  template:
    metadata:
      name: exo-06-pod
      labels:
        app: exo-06
        tier: frontend
    spec:
      containers:
        - name: exo-06-container
          image: <registry-name>/<image-name>
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"

```

  * Créer le fichier de service exposé au monde extérieur

```yaml
# k8s/service.yaml

apiVersion: v1
kind: Service

metadata:
  name: exo-06-service

spec:
  type: LoadBalancer
  selector:
    app: exo-06
    tier: frontend
  ports:
    - port: 80
      targetPort: 80

```

```bash
kubectl apply -f k8s/
```

* Tester le déploiement vis un tunnel dans minikube

```bash
minikube service exo-06-service

curl http://<minikube-tunnel-ip>:<minikube-tunnel-port>
```