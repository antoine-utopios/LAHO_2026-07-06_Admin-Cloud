# Exercice Kubernetes #7 - Réalisation d'un déploiement d'applicatifs sur plusieurs nodes différentes

## Sujet 

Réaliser, via kind ainsi l'approche déclarative de K8s, un déploiement d'applicatifs différents sur différents emplacements du monde: 

* Déployer un serveur web de type NGINX sur un emplacement 'France'
* Déployer une api réalisée avec Express sur un emplacement 'Japon'
* Déployer le jeu 2048 sur un emplacement 'USA'

## Correction

* Créer le fichier de configuration du cluster avec KinD

```yaml
# kind-cluster.yaml

apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: demo
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```

* Lancer le cluster

```bash
kind create cluster kind/kind-cluster.yaml
```

* Teinter et labelliser les nodes

```bash
kubectl label nodes demo-worker country=france && \
kubectl taint nodes demo-worker country=france:NoExecute && \
kubectl label nodes demo-worker2 country=japan && \
kubectl taint nodes demo-worker2 country=japan:NoExecute && \
kubectl label nodes demo-worker3 country=usa && \
kubectl taint nodes demo-worker3 country=usa:NoExecute
```

* Créer les fichiers de déploiement et de service

  * France

```yaml
# k8s/france-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: exo-07-france-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: exo-07-france-nginx
      tier: frontend
  template:
    metadata:
      name: exo-07-france-nginx-pod
      labels:
        app: exo-07-france-nginx
        tier: frontend
    spec:
      tolerations:
        - key: "country"
          operator: "Equal"
          value: "france"
          effect: "NoExecute"
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: "country"
                    operator: "In"
                    values: ["france"]
      containers:
        - name: exo-07-france-nginx-container
          image: nginx:alpine
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/france-service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-07-france-nginx-service
spec:
  type: LoadBalancer
  selector:
    app: exo-07-france-nginx
    tier: frontend
  ports:
    - port: 80
      targetPort: 80
```

  * Japon

```yaml
# k8s/japan-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: exo-07-japan-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: exo-07-japan-api
      tier: backend
  template:
    metadata:
      name: exo-07-japan-api-pod
      labels:
        app: exo-07-japan-api
        tier: backend
    spec:
      tolerations:
        - key: "country"
          operator: "Equal"
          value: "japan"
          effect: "NoExecute"
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: "country"
                    operator: "In"
                    values: ["japan"]
      containers:
        - name: exo-07-japan-api-container
          image: registry-name/kube-exo-07-api:latest
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/japan-service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-07-japan-nginx-service
spec:
  type: LoadBalancer
  selector:
    app: exo-07-japan-nginx
    tier: backend
  ports:
    - port: 3000
      targetPort: 3000
```

  * USA

```yaml
# k8s/usa-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: exo-07-usa-2048
spec:
  replicas: 1
  selector:
    matchLabels:
      app: exo-07-usa-2048
      tier: frontend
  template:
    metadata:
      name: exo-07-usa-2048-pod
      labels:
        app: exo-07-usa-2048
        tier: frontend
    spec:
      tolerations:
        - key: "country"
          operator: "Equal"
          value: "usa"
          effect: "NoExecute"
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: "country"
                    operator: "In"
                    values: ["usa"]
      containers:
        - name: exo-07-usa-2048-container
          image: quchaonet/2048:latest
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/usa-service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-07-usa-2048-service
spec:
  type: LoadBalancer
  selector:
    app: exo-07-usa-2048
    tier: frontend
  ports:
    - port: 8080
      targetPort: 8080
```

* Lancer l'exécution des manifeste (demander la création des ressources à Kubernetes)

```bash
kubectl apply -f k8s/
```