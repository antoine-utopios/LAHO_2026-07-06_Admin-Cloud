# Exercice Kubernetes #8 - Stockage de fichiers

Déployer une API qui écrit des logs dans un fichier, observer le comportement sans volume, puis introduire un volume `emptyDir` / `hostPath`

Les fichiers `app.py` et `Dockerfile` sont fournis dans le dossier de l'exercice.

L'API expose trois routes :

| Méthode | Route | Description |
|---------|-------|-------------|
| `POST` | `/log` | Écrit un message dans `/app/logs/events.log` |
| `GET` | `/log` | Retourne le contenu du fichier sous forme de tableau JSON |
| `POST` | `/crash` | Arrête le processus (simule un crash applicatif) |

* Créer un cluster KinD dédié.

```yaml
# kind/basic-cluster.yaml

apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: demo
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```

* Construire l'image Docker et chargé l'image dans le cluster.

```bash
docker build -t registry-name/image-name /path/to/Dockerfile

docker push registry-name/image-name
```

* Déployer l'API **sans volume** et observé le comportement des données après un crash.

```yaml
# k8s/deployment-basic.yaml

apiVersion: apps/v1
kind: Deployment

metadata:
  name: exo-08-deployment

spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
      tier: backend
  template:
    metadata:
      name: exo-08-pod
      labels:
        app: api
        tier: backend
    spec:
      containers:
        - name: exo-08-container
          image: registry-name/kube-exo-08
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-08-service
spec:
  type: LoadBalancer
  selector:
    app: api
    tier: backend
  ports:
    - port: 5000
      targetPort: 5000
```

* Déployer l'API **avec un volume `emptyDir`** monté sur `/app/logs` et observer la différence.

```yaml
# k8s/deployment-emptyDir.yaml

apiVersion: apps/v1
kind: Deployment

metadata:
  name: exo-08-deployment

spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
      tier: backend
  template:
    metadata:
      name: exo-08-pod
      labels:
        app: api
        tier: backend
    spec:
      volumes:
        - name: exo-08-data
          emptyDir: {}
      containers:
        - name: exo-08-container
          image: registry-name/kube-exo-08
          volumeMounts:
            - name: exo-08-data
              mountPath: /app/logs/
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-08-service
spec:
  type: LoadBalancer
  selector:
    app: api
    tier: backend
  ports:
    - port: 5000
      targetPort: 5000
```

* Déployer l'API **avec un volume `hostPath`** monté sur `/app/logs` et observer la différence.

```yaml
# k8s/deployment-emptyDir.yaml

apiVersion: apps/v1
kind: Deployment

metadata:
  name: exo-08-deployment

spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
      tier: backend
  template:
    metadata:
      name: exo-08-pod
      labels:
        app: api
        tier: backend
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
      volumes:
        - name: exo-08-data
          hostPath:
            path: /data/exo-08
            type: DirectoryOrCreate
      containers:
        - name: exo-08-container
          image: registry-name/kube-exo-08
          volumeMounts:
            - name: exo-08-data
              mountPath: /app/logs/
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

```yaml
# k8s/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: exo-08-service
spec:
  type: LoadBalancer
  selector:
    app: api
    tier: backend
  ports:
    - port: 5000
      targetPort: 5000
```

Une fois le pod en état `Running`, tu dois être capable de répondre aux questions suivantes par l'expérimentation :

**Sans volume — après un crash (`POST /crash`) :**
- Le pod redémarre-t-il automatiquement ?

La route semble poser problème, donc non. En théorie, le pod ne redémarre pas, le conteneur oui.

- Les données sont-elles toujours présentes après le redémarrage ?

Non.

**Avec `emptyDir` — après un crash (`POST /crash`) :**
- Les données sont-elles toujours présentes après le redémarrage du conteneur ?

Non.

**Avec `emptyDir` — après une suppression du pod (`kubectl delete pod …`) :**
- Un nouveau pod est-il recréé par le Deployment ?

Oui

- Les données sont-elles toujours présentes dans le nouveau pod ?

Non

**Avec `hostPath` — après une suppression du pod (`kubectl delete pod …`) :**
- Un nouveau pod est-il recréé par le Deployment ?

Oui

- Les données sont-elles toujours présentes dans le nouveau pod ?

C'est aléatoire

- Et si le pod est déployé sur le même noeud via l'utilisation de teintes et de l'affinité ?

Oui