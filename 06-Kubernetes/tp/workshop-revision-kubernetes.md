# Workshop guidé — Révision Kubernetes en une journée

> Bloc : 13-cl-cont — Docker + Kubernetes (révision des jours 4 à 6)
> Durée : 1 journée (7 h, pauses comprises)
> Type : workshop guidé, en autonomie accompagnée, non noté
> Environnement : **minikube** (le cluster local du bloc) + fil rouge **StockLine**

## Principe de la journée

Vous allez reconstruire StockLine sur Kubernetes **objet par objet**, dans l'ordre
où Kubernetes en a besoin. À chaque étape, ce document vous dit exactement quoi
faire. Vous ne cherchez pas la solution : vous **observez** ce que fait le cluster,
et vous **expliquez** pourquoi.

Chaque étape suit le même format :

| Rubrique | Ce que vous y trouvez |
|---|---|
| 🎯 **Objectif** | ce que vous saurez faire à la fin de l'étape |
| 📖 **Rappel** | les notions du cours à avoir en tête (lisez-les AVANT de taper) |
| ⌨️ **À faire** | les commandes, dans l'ordre, à taper telles quelles |
| 👀 **Ce que vous devez voir** | la sortie attendue (les noms aléatoires `-7cfffd…` changent) |
| ✅ **Point de contrôle** | `./verifier.sh <n>` : tout doit être vert avant de continuer |
| ❓ **Question de révision** | à répondre par écrit dans votre fichier `reponses.md` |

> 💡 **Règle d'or** : si une commande ne donne pas le résultat attendu, ne passez
> pas à la suite. Diagnostiquez dans l'ordre `get` → `describe` (section *Events*)
> → `logs`, puis appelez le formateur.

## Programme de la journée

| Horaire | Étape | Notions révisées |
|---|---|---|
| 09:00 | 1. Préparation du poste et du cluster | contexte, namespace, nœuds |
| 09:30 | 2. Le Pod | pod, `kubectl run`, YAML généré, `exec`, `logs` |
| 10:00 | 3. Le Deployment | ReplicaSet, labels, auto-réparation, déclaratif |
| 10:35 | *Pause* | |
| 10:50 | 4. Le Service et le DNS | ClusterIP, selector, endpoints, DNS interne |
| 11:20 | 5. Le ConfigMap monté en fichier | ConfigMap, volumes |
| 11:45 | 6. Secret, PVC et base PostgreSQL | Secret, PVC/PV/StorageClass, stratégie Recreate |
| 12:15 | *Déjeuner* | |
| 13:15 | 7. L'API StockLine | env depuis ConfigMap/Secret, communication inter-services |
| 13:50 | 8. La preuve de persistance | cycle de vie pod vs données |
| 14:05 | 9. Mise à jour progressive et retour arrière | rolling update, révisions, `rollout undo` |
| 14:35 | 10. L'Ingress | contrôleur, règles host/chemin, réécriture |
| 15:00 | *Pause* | |
| 15:15 | 11. Probes, ressources et HPA | readiness/liveness, requests/limits, autoscaling |
| 15:45 | 12. Diagnostic des 6 pannes | ImagePullBackOff, CrashLoopBackOff, Pending, OOMKilled… |
| 16:15 | 13. Helm | chart, release, upgrade, rollback |
| 16:35 | Bilan : 8 questions éclair + nettoyage | |

## Architecture cible

```text
                     navigateur / curl  (Host: stockline.local)
                                │
                     ┌──────────▼──────────┐
                     │ Ingress "stockline" │   contrôleur ingress-nginx
                     └───┬─────────────┬───┘
                   /     │             │  /api/...  (réécrit en /...)
             ┌───────────▼──┐     ┌────▼─────────┐
             │ Service front│     │ Service api  │ ClusterIP :80
             └──────┬───────┘     └──────┬───────┘
            ┌───────▼──────┐     ┌───────▼───────┐        ┌─────────────┐
            │ Deployment   │     │ Deployment    │◄───────│ HPA api     │
            │ front (x2)   │     │ api (x2 → x5) │        │ 2 → 5, 60 % │
            │ nginx +      │     │ FastAPI :8000 │        └─────────────┘
            │ ConfigMap    │     │ env: ConfigMap│
            │ front-html   │     │    + Secret   │
            └──────────────┘     └───────┬───────┘
                                 ┌───────▼───────┐
                                 │ Service db    │ ClusterIP :5432
                                 └───────┬───────┘
                                 ┌───────▼───────┐    ┌──────────────┐
                                 │ Deployment db │────│ PVC db-data  │ 1 Gi
                                 │ postgres:16   │    └──────────────┘
                                 └───────────────┘
        namespace : stockline          + pod "sonde" (busybox) : votre boîte à outils
```

---

## Étape 1 — Préparation du poste et du cluster (30 min)

### 🎯 Objectif

Disposer d'un cluster minikube sain, de l'image de l'API, et d'un contexte
`kubectl` qui pointe sur le bon namespace.

### 📖 Rappel

- **kubectl** ne parle qu'à UN cluster à la fois : celui du **contexte courant**
  (fichier `~/.kube/config`). Au bloc 13, vous avez eu minikube et EKS : vérifier le
  contexte est le réflexe n°1.
- Un **namespace** est un espace de noms : il isole les objets (deux Services `api`
  peuvent coexister dans deux namespaces). Fixer le namespace par défaut du contexte
  évite d'écrire `-n stockline` partout.
- Les **addons** minikube installent des composants optionnels : `ingress`
  (contrôleur ingress-nginx) et `metrics-server` (métriques CPU/mémoire pour
  `kubectl top` et le HPA).

### ⌨️ À faire

1. Démarrez le cluster et activez les deux addons :

   ```bash
   minikube start --cpus 2 --memory 3072
   minikube addons enable ingress
   minikube addons enable metrics-server
   ```

2. Chargez l'image de l'API construite au jour 2 du bloc dans le cluster.
   Si `docker images stockline-api` ne l'affiche pas, reconstruisez-la d'abord
   (voir `code/13-cl-cont/stockline-docker/README.md`).

   ```bash
   docker images stockline-api            # stockline-api   1.0.0   …
   minikube image load stockline-api:1.0.0
   minikube image ls | grep stockline     # docker.io/library/stockline-api:1.0.0
   ```

3. Préparez votre dossier de travail et la variable qui pointe vers le code du bloc
   (adaptez le chemin vers VOTRE copie du dépôt) :

   ```bash
   mkdir -p ~/workshop-k8s && cd ~/workshop-k8s
   export K8S=~/formation-admin-cloud-2026/code/13-cl-cont/k8s
   ls $K8S/manifests                      # 00-namespace.yaml … 50-hpa.yaml
   cp $K8S/workshop/verifier.sh . && chmod +x verifier.sh
   touch reponses.md
   ```

4. Vérifiez le contexte et les nœuds :

   ```bash
   kubectl config current-context
   kubectl get nodes
   kubectl get pods -A
   ```

5. Créez le namespace et faites-en le namespace par défaut du contexte :

   ```bash
   kubectl create namespace stockline
   kubectl config set-context --current --namespace=stockline
   kubectl config view --minify | grep namespace
   ```

### 👀 Ce que vous devez voir

```text
minikube
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.3x.x
...
    namespace: stockline
```

`kubectl get pods -A` liste les pods système : `coredns`, `etcd-minikube`,
`kube-apiserver-minikube`, `kube-scheduler-minikube`, `ingress-nginx-controller-…`,
`metrics-server-…`.

### ✅ Point de contrôle

```bash
./verifier.sh 1
```

### ❓ Question de révision

1. Dans la liste `kubectl get pods -A`, associez chaque composant à son rôle :
   `kube-apiserver`, `etcd`, `kube-scheduler`, `coredns`. Lequel stocke l'état
   désiré du cluster ?

---

## Étape 2 — Le Pod (30 min)

### 🎯 Objectif

Créer un pod à partir d'un fichier YAML généré, l'inspecter, entrer dedans, et
constater qu'un pod seul n'est jamais recréé. Ce pod `sonde` vous servira de boîte
à outils réseau toute la journée.

### 📖 Rappel

- Le **Pod** est la plus petite unité déployable : un ou plusieurs conteneurs qui
  partagent la même IP et les mêmes volumes.
- `--dry-run=client -o yaml` fait générer le YAML par `kubectl` **sans rien créer** :
  c'est la façon la plus sûre d'écrire un manifest sans faute d'indentation.
- `kubectl apply -f` est **déclaratif** : vous décrivez l'état voulu, Kubernetes
  converge vers lui.

### ⌨️ À faire

1. Générez le manifest d'un pod busybox qui dort 10 heures, et lisez-le :

   ```bash
   kubectl run sonde --image=busybox:1.36 --dry-run=client -o yaml -- sleep 36000 > pod-sonde.yaml
   cat pod-sonde.yaml
   ```

2. Créez-le et attendez qu'il soit prêt :

   ```bash
   kubectl apply -f pod-sonde.yaml
   kubectl wait --for=condition=Ready pod/sonde --timeout=120s
   kubectl get pod sonde -o wide
   ```

3. Inspectez-le sous trois angles :

   ```bash
   kubectl describe pod sonde          # lisez la section Events, de bas en haut
   kubectl logs sonde                  # vide : sleep n'écrit rien, c'est normal
   kubectl exec sonde -- hostname
   kubectl exec sonde -- nslookup kubernetes.default.svc.cluster.local
   ```

4. Supprimez-le, puis constatez :

   ```bash
   kubectl delete pod sonde
   kubectl get pods
   ```

5. Recréez-le depuis le fichier (vous en aurez besoin jusqu'au soir) :

   ```bash
   kubectl apply -f pod-sonde.yaml
   kubectl wait --for=condition=Ready pod/sonde --timeout=120s
   ```

### 👀 Ce que vous devez voir

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: sonde
  name: sonde
spec:
  containers:
  - args:
    - sleep
    - "36000"
    image: busybox:1.36
    name: sonde
```

```text
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE
sonde   1/1     Running   0          4s    10.244.0.10   minikube

Name:	kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

Après le `delete` : `No resources found in stockline namespace.` Personne ne
recrée le pod.

### ✅ Point de contrôle

```bash
./verifier.sh 2
```

### ❓ Questions de révision

2. Pourquoi le pod supprimé n'a-t-il pas été recréé ? Quel objet aurait fallu
   utiliser pour qu'il le soit ?
3. Que signifient les colonnes `READY 1/1` et `RESTARTS 0` ?

---

## Étape 3 — Le Deployment (35 min)

### 🎯 Objectif

Déployer le front nginx en 2 replicas, observer la chaîne
Deployment → ReplicaSet → Pods, et vérifier l'auto-réparation.

### 📖 Rappel

- Le **Deployment** décrit l'état voulu (image, nombre de replicas). Il crée un
  **ReplicaSet**, qui maintient le bon nombre de **Pods**.
- Le lien entre ces objets passe par les **labels** : le `selector.matchLabels`
  du Deployment doit correspondre aux `labels` du `template` des pods.
- **Impératif** (`kubectl scale`) = une action ponctuelle. **Déclaratif**
  (`kubectl apply -f`) = le fichier fait foi. Le prochain `apply` écrase les
  actions impératives.

### ⌨️ À faire

1. Générez et lisez le manifest :

   ```bash
   kubectl create deployment front --image=nginx:1.27-alpine --replicas=2 \
     --dry-run=client -o yaml > front-deployment.yaml
   cat front-deployment.yaml
   ```

   Repérez les trois endroits où apparaît `app: front`.

2. Appliquez et suivez le déploiement :

   ```bash
   kubectl apply -f front-deployment.yaml
   kubectl rollout status deploy/front
   kubectl get deploy,rs,pods -l app=front --show-labels
   ```

3. Tuez un pod et regardez la réaction :

   ```bash
   kubectl delete $(kubectl get pods -l app=front -o name | head -1) --wait=false
   kubectl get pods -l app=front
   ```

4. Passez à 3 replicas en impératif, puis réappliquez le fichier :

   ```bash
   kubectl scale deploy/front --replicas=3
   kubectl get deploy front
   kubectl apply -f front-deployment.yaml
   kubectl get deploy front
   ```

### 👀 Ce que vous devez voir

```text
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
deployment.apps/front   2/2     2            2           7s    app=front

NAME                              DESIRED   CURRENT   READY   AGE   LABELS
replicaset.apps/front-d6bf85cf6   2         2         2       7s    app=front,pod-template-hash=d6bf85cf6

NAME                        READY   STATUS    RESTARTS   AGE   LABELS
pod/front-d6bf85cf6-5x5sn   1/1     Running   0          7s    app=front,pod-template-hash=d6bf85cf6
pod/front-d6bf85cf6-jcr7d   1/1     Running   0          7s    app=front,pod-template-hash=d6bf85cf6
```

Après la suppression, un **nouveau** pod apparaît (AGE de quelques secondes) :
le ReplicaSet a recréé le manquant. Après `scale` : `3/3`. Après le nouvel
`apply` : retour à `2/2`.

### ✅ Point de contrôle

```bash
./verifier.sh 3
```

### ❓ Questions de révision

4. Quel objet a recréé le pod supprimé ? Comment a-t-il su qu'il en manquait un ?
5. Pourquoi le passage à 3 replicas a-t-il été annulé ? Qu'en concluez-vous pour
   le travail en équipe sur un cluster ?

---

## Étape 4 — Le Service et le DNS (30 min)

### 🎯 Objectif

Donner au front une adresse stable et un nom DNS, et comprendre comment le
Service trouve ses pods.

### 📖 Rappel

- Les IP des pods changent à chaque recréation. Le **Service** offre une IP
  virtuelle (**ClusterIP**) et un **nom DNS** stables.
- Le Service choisit ses pods par **selector** (labels). La liste des pods
  retenus s'appelle les **endpoints** (objets `EndpointSlice`).
- `port` = port du Service ; `targetPort` = port du conteneur.
- Nom DNS complet : `<service>.<namespace>.svc.cluster.local`. Dans le même
  namespace, le nom court `<service>` suffit.

### ⌨️ À faire

1. Générez le Service, lisez-le, appliquez-le :

   ```bash
   kubectl expose deployment front --port=80 --target-port=80 \
     --dry-run=client -o yaml > front-service.yaml
   cat front-service.yaml
   kubectl apply -f front-service.yaml
   kubectl get svc front
   ```

2. Regardez les endpoints et comparez avec les IP des pods :

   ```bash
   kubectl get endpointslices -l kubernetes.io/service-name=front
   kubectl get pods -l app=front -o wide
   ```

3. Appelez le Service depuis la sonde, par son nom court puis par son nom complet :

   ```bash
   kubectl exec sonde -- wget -qO- http://front | head -4
   kubectl exec sonde -- nslookup front.stockline.svc.cluster.local
   ```

4. Accédez-y depuis votre poste avec un port-forward (laissez tourner, ouvrez
   `http://localhost:8081` dans le navigateur, puis `Ctrl+C`) :

   ```bash
   kubectl port-forward svc/front 8081:80
   ```

### 👀 Ce que vous devez voir

```text
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
front   ClusterIP   10.96.110.182   <none>        80/TCP    0s

NAME          ADDRESSTYPE   PORTS   ENDPOINTS                 AGE
front-tnvcl   IPv4          80      10.244.0.14,10.244.0.12   0s

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>

Name:	front.stockline.svc.cluster.local
Address: 10.96.110.182
```

Les deux IP des endpoints sont exactement celles des pods `front`. L'adresse
renvoyée par le DNS est la ClusterIP du Service, pas celle d'un pod.

> ℹ️ Le `nslookup` de busybox échoue souvent sur un nom court (`nslookup front`) :
> c'est une limite de busybox, pas du cluster. `wget http://front` fonctionne, lui.

### ✅ Point de contrôle

```bash
./verifier.sh 4
```

### ❓ Questions de révision

6. Si vous changiez le selector du Service en `app: vitrine`, que deviendraient les
   endpoints ? Que renverrait `wget http://front` ?
7. Pourquoi les autres pods doivent-ils appeler `front` et jamais `10.244.0.14` ?

---

## Étape 5 — Le ConfigMap monté en fichier (25 min)

### 🎯 Objectif

Remplacer la page d'accueil nginx par la page StockLine, fournie par un
ConfigMap monté comme un fichier.

### 📖 Rappel

- Un **ConfigMap** stocke de la configuration **non sensible** sous forme
  clé → valeur.
- Il se consomme de deux façons : en **variables d'environnement** (étape 7) ou
  **monté en volume** : chaque clé devient un fichier.
- Au bloc 13 (compose), la page était un *bind mount*. En Kubernetes, le même
  besoin se traite par un ConfigMap monté.

### ⌨️ À faire

1. Lisez puis appliquez le ConfigMap fourni. Repérez la clé `index.html` :

   ```bash
   head -20 $K8S/manifests/29-front-configmap.yaml
   kubectl apply -f $K8S/manifests/29-front-configmap.yaml
   kubectl get configmap front-html
   ```

2. Éditez `front-deployment.yaml` pour monter ce ConfigMap dans
   `/usr/share/nginx/html`. La section `spec.template.spec` doit devenir
   exactement celle-ci (attention à l'indentation) :

   ```yaml
       spec:
         containers:
         - image: nginx:1.27-alpine
           name: nginx
           volumeMounts:
           - name: html
             mountPath: /usr/share/nginx/html
             readOnly: true
         volumes:
         - name: html
           configMap:
             name: front-html
   ```

3. Appliquez et observez le remplacement des pods :

   ```bash
   kubectl apply -f front-deployment.yaml
   kubectl rollout status deploy/front
   kubectl exec deploy/front -- ls /usr/share/nginx/html
   kubectl exec sonde -- wget -qO- http://front | grep '<title>'
   ```

### 👀 Ce que vous devez voir

```text
Waiting for deployment "front" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "front" rollout to finish: 1 old replicas are pending termination...
deployment "front" successfully rolled out
index.html
<title>StockLine — Inventaire (Kubernetes)</title>
```

### ✅ Point de contrôle

```bash
./verifier.sh 5
```

### ❓ Question de révision

8. Pourquoi la modification du Deployment a-t-elle remplacé les pods un par un,
   alors que vous n'avez changé ni l'image ni le nombre de replicas ?

---

## Étape 6 — Secret, PVC et base PostgreSQL (30 min)

### 🎯 Objectif

Déployer PostgreSQL avec un mot de passe généré, stocké dans un Secret, et des
données sur un volume persistant.

### 📖 Rappel

- Un **Secret** ressemble à un ConfigMap, pour les données sensibles. Ses valeurs
  sont encodées en **base64**, ce qui **n'est pas du chiffrement**.
- Le **PVC** (PersistentVolumeClaim) est une **demande** de stockage (« 1 Gi en
  lecture-écriture »). La **StorageClass** par défaut crée à la volée le **PV**
  (PersistentVolume) qui la satisfait.
- Une base sur un volume `ReadWriteOnce` utilise la stratégie **Recreate** :
  jamais deux PostgreSQL sur le même volume.

### ⌨️ À faire

1. Créez le Secret avec un mot de passe aléatoire (il n'est écrit dans aucun fichier) :

   ```bash
   kubectl create secret generic db-credentials \
     --from-literal=POSTGRES_USER=stockline \
     --from-literal=POSTGRES_PASSWORD="$(openssl rand -hex 16)" \
     --from-literal=POSTGRES_DB=stockline
   kubectl get secret db-credentials -o yaml | grep -A3 '^data'
   kubectl get secret db-credentials -o jsonpath='{.data.POSTGRES_USER}' | base64 -d; echo
   ```

   > ⚠️ N'appliquez **pas** `10-db-secret.yaml` : il contient un mot de passe en clair
   > de démonstration. C'est justement ce qu'on évite.

2. Lisez puis appliquez la demande de stockage :

   ```bash
   cat $K8S/manifests/11-db-pvc.yaml
   kubectl apply -f $K8S/manifests/11-db-pvc.yaml
   kubectl get pvc db-data
   kubectl get storageclass
   ```

3. Lisez le Deployment de la base en cherchant `strategy`, `envFrom`,
   `volumeMounts` et `readinessProbe`, puis appliquez-le avec son Service :

   ```bash
   less $K8S/manifests/12-db-deployment.yaml
   kubectl apply -f $K8S/manifests/12-db-deployment.yaml -f $K8S/manifests/13-db-service.yaml
   kubectl rollout status deploy/db --timeout=180s
   kubectl get pvc db-data
   kubectl get pv
   kubectl exec deploy/db -- pg_isready -U stockline -d stockline
   ```

### 👀 Ce que vous devez voir

```text
data:
  POSTGRES_DB: c3RvY2tsaW5l
  POSTGRES_PASSWORD: …
  POSTGRES_USER: c3RvY2tsaW5l
stockline

NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
db-data   Bound    pvc-59e2fb7b-c014-4a38-a9c6-32cc5161aed7   1Gi        RWO            standard

deployment "db" successfully rolled out
/var/run/postgresql:5432 - accepting connections
```

Sur certains clusters, le PVC reste `Pending` jusqu'à ce qu'un pod l'utilise
(mode `WaitForFirstConsumer`), puis passe `Bound` : c'est normal.

### ✅ Point de contrôle

```bash
./verifier.sh 6
```

### ❓ Questions de révision

9. `c3RvY2tsaW5l` : que contient ce champ ? Quelle conclusion en tirez-vous sur la
   protection réelle d'un Secret ?
10. Qui a créé le PV `pvc-59e2…` ? Vous, le PVC, ou la StorageClass ?
11. Que se passerait-il avec la stratégie par défaut (`RollingUpdate`) lors d'une
    mise à jour de la base ?

---

## Étape 7 — L'API StockLine (35 min)

### 🎯 Objectif

Déployer l'API, la brancher à la base par son nom de Service, et enregistrer
un premier produit et un premier mouvement de stock.

### 📖 Rappel

- Une variable d'environnement peut venir d'un ConfigMap (`configMapKeyRef`) ou
  d'un Secret (`secretKeyRef`).
- La syntaxe `$(VAR)` assemble une valeur à partir de variables **déclarées plus
  haut dans la même liste**.
- Un pod joint un autre service par son **nom DNS** : `DB_HOST=db`.

### ⌨️ À faire

1. Lisez `21-api-deployment.yaml` : repérez d'où vient chaque variable, et la
   construction de `DATABASE_URL`. Puis appliquez les trois fichiers de l'API :

   ```bash
   less $K8S/manifests/21-api-deployment.yaml
   kubectl apply -f $K8S/manifests/20-api-configmap.yaml \
                 -f $K8S/manifests/21-api-deployment.yaml \
                 -f $K8S/manifests/22-api-service.yaml
   kubectl rollout status deploy/api --timeout=180s
   kubectl get pods -l app=api
   ```

2. Vérifiez la santé de l'API **et** de sa connexion à la base :

   ```bash
   kubectl exec sonde -- wget -qO- http://api/sante; echo
   ```

3. Regardez l'environnement réellement injecté dans le conteneur :

   ```bash
   kubectl exec deploy/api -- env | grep -E '^DB_|DATABASE_URL' | sort
   ```

4. Créez le produit SSD-500 :

   ```bash
   kubectl exec sonde -- wget -qO- --header 'Content-Type: application/json' \
     --post-data '{"reference":"SSD-500","nom":"Disque SSD 500 Go","prix_unitaire":59.9,"seuil_alerte":5}' \
     http://api/produits; echo
   ```

5. Enregistrez une entrée de 20 unités, puis lisez le stock :

   ```bash
   kubectl exec sonde -- wget -qO- --header 'Content-Type: application/json' \
     --post-data '{"produit_id":1,"type":"entree","quantite":20}' \
     http://api/mouvements; echo
   kubectl exec sonde -- wget -qO- http://api/stocks/1; echo
   ```

### 👀 Ce que vous devez voir

```text
{"statut":"ok","base_de_donnees":"ok","version":"1.0.0"}

DATABASE_URL=postgresql+psycopg2://stockline:<mot de passe>@db:5432/stockline
DB_HOST=db
DB_PORT=5432
DB_SERVICE_HOST=10.96.244.174
DB_SERVICE_PORT=5432
...

{"reference":"SSD-500","nom":"Disque SSD 500 Go","prix_unitaire":59.9,"seuil_alerte":5,"id":1,"cree_le":"…"}
{"produit_id":1,"type":"entree","quantite":20,"commentaire":null,"id":1,"cree_le":"…"}
{"produit_id":1,"reference":"SSD-500","nom":"Disque SSD 500 Go","quantite":20,"seuil_alerte":5,"alerte":false}
```

### ✅ Point de contrôle

```bash
./verifier.sh 7
```

### ❓ Questions de révision

12. Vous voyez des variables `DB_SERVICE_HOST` et `DB_SERVICE_PORT` que vous n'avez
    jamais déclarées. D'où viennent-elles ? Pourquoi préférer malgré tout le nom
    DNS `db` ?
13. Le mot de passe apparaît en clair dans `env`. Qui, dans l'équipe, doit avoir le
    droit de faire `kubectl exec` en production ?

---

## Étape 8 — La preuve de persistance (15 min)

### 🎯 Objectif

Démontrer que les données survivent à la destruction du pod de base.

### 📖 Rappel

- Le système de fichiers d'un conteneur disparaît avec lui.
- Seul un **volume persistant** (PVC) survit à la recréation du pod.

### ⌨️ À faire

```bash
kubectl get pods -l app=db
kubectl delete pod -l app=db
kubectl get pods -l app=db -w          # Ctrl+C quand le nouveau pod est 1/1 Running
kubectl exec sonde -- wget -qO- http://api/stocks/1; echo
```

### 👀 Ce que vous devez voir

Un nouveau nom de pod `db-…`, puis le même stock qu'à l'étape 7 :

```text
{"produit_id":1,"reference":"SSD-500","nom":"Disque SSD 500 Go","quantite":20,"seuil_alerte":5,"alerte":false}
```

### ✅ Point de contrôle

```bash
./verifier.sh 8
```

### ❓ Question de révision

14. Quelle commande détruirait réellement les données ? (indice : quel objet porte
    le lien vers le PV, et quelle est sa `RECLAIM POLICY` dans `kubectl get pv` ?)

---

## Étape 9 — Mise à jour progressive et retour arrière (30 min)

### 🎯 Objectif

Mettre à jour l'API sans interruption, déployer volontairement une version
cassée, constater que le service reste disponible, puis revenir en arrière.

### 📖 Rappel

- Changer le `template` d'un Deployment crée un **nouveau ReplicaSet**. Les pods
  sont remplacés progressivement (**rolling update**), selon `maxSurge` et
  `maxUnavailable` (25 % par défaut).
- Chaque ReplicaSet est une **révision**. `kubectl rollout undo` revient à la
  révision précédente.
- L'annotation `kubernetes.io/change-cause` renseigne la colonne `CHANGE-CAUSE`
  de l'historique.

### ⌨️ À faire

1. Fabriquez une « version 1.1.0 » (même contenu, nouveau tag) et chargez-la :

   ```bash
   docker tag stockline-api:1.0.0 stockline-api:1.1.0
   minikube image load stockline-api:1.1.0
   ```

2. Annotez la révision actuelle, puis déployez la 1.1.0 :

   ```bash
   kubectl annotate deploy/api kubernetes.io/change-cause="1.0.0 : version initiale" --overwrite
   kubectl set image deploy/api api=stockline-api:1.1.0
   kubectl annotate deploy/api kubernetes.io/change-cause="1.1.0 : mise à jour" --overwrite
   kubectl rollout status deploy/api
   kubectl rollout history deploy/api
   kubectl get rs -l app=api
   ```

3. Déployez une version qui n'existe pas, attendez 30 secondes, et observez :

   ```bash
   kubectl set image deploy/api api=stockline-api:9.9.9
   kubectl annotate deploy/api kubernetes.io/change-cause="9.9.9 : version fantôme" --overwrite
   sleep 30
   kubectl get pods -l app=api
   kubectl get deploy api
   kubectl exec sonde -- wget -qO- http://api/sante; echo
   ```

4. Revenez en arrière et relisez l'historique :

   ```bash
   kubectl rollout undo deploy/api
   kubectl rollout status deploy/api
   kubectl get deploy api -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
   kubectl rollout history deploy/api
   ```

### 👀 Ce que vous devez voir

Pendant la panne :

```text
NAME                   READY   STATUS             RESTARTS   AGE
api-5f8f8675c9-5n9pz   1/1     Running            0          39s
api-5f8f8675c9-dk6m5   1/1     Running            0          33s
api-745dc8466-p5xzc    0/1     ImagePullBackOff   0          25s

NAME   READY   UP-TO-DATE   AVAILABLE   AGE
api    2/2     1            2           62s

{"statut":"ok","base_de_donnees":"ok","version":"1.0.0"}
```

Après le retour arrière :

```text
stockline-api:1.1.0
REVISION  CHANGE-CAUSE
1         1.0.0 : version initiale
3         9.9.9 : version fantôme
4         1.1.0 : mise à jour
```

`kubectl rollout undo` affiche aussi un avertissement sur l'annotation
`last-applied-configuration` : il rappelle que votre fichier YAML, lui, n'a pas
changé. Le prochain `kubectl apply` de `21-api-deployment.yaml` remettrait la 1.0.0.

> ℹ️ Le champ `version` de `/sante` reste `1.0.0` : c'est le numéro écrit dans le
> code de l'API, et la « 1.1.0 » est la même image sous un autre tag.

### ✅ Point de contrôle

```bash
./verifier.sh 9
```

### ❓ Questions de révision

15. Pendant la panne, le service est resté disponible. Expliquez-le avec
    `maxUnavailable` et `maxSurge` (2 replicas, 25 %).
16. Pourquoi la révision 2 a-t-elle disparu de l'historique, remplacée par une
    révision 4 ?

---

## Étape 10 — L'Ingress (25 min)

### 🎯 Objectif

Exposer front et API derrière une seule entrée HTTP, routée par nom d'hôte et
par chemin.

### 📖 Rappel

- Un objet **Ingress** ne fait rien seul : il faut un **contrôleur**
  (ici ingress-nginx, installé par l'addon minikube) qui lit les règles et route.
- Le routage se fait sur l'en-tête **`Host`** et sur le **chemin**.
- L'API expose `/sante`, pas `/api/sante` : l'annotation `rewrite-target` retire
  le préfixe `/api`.

### ⌨️ À faire

1. Lisez puis appliquez l'Ingress :

   ```bash
   cat $K8S/manifests/40-ingress.yaml
   kubectl apply -f $K8S/manifests/40-ingress.yaml
   kubectl get ingress stockline
   kubectl -n ingress-nginx get svc ingress-nginx-controller
   ```

2. Ouvrez l'entrée du contrôleur sur votre poste (terminal dédié, laissez tourner) :

   ```bash
   kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
   ```

3. Dans un autre terminal, testez les trois cas :

   ```bash
   curl -s -H "Host: stockline.local" http://localhost:8080/api/sante; echo
   curl -s -H "Host: stockline.local" http://localhost:8080/api/produits; echo
   curl -s -H "Host: stockline.local" http://localhost:8080/ | grep '<title>'
   curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/
   ```

4. *(Facultatif, navigateur)* Ajoutez `127.0.0.1 stockline.local` à votre fichier
   `hosts` (`/etc/hosts`, ou `C:\Windows\System32\drivers\etc\hosts`), puis ouvrez
   `http://stockline.local:8080` : le tableau affiche SSD-500.

### 👀 Ce que vous devez voir

```text
NAME        CLASS   HOSTS             ADDRESS   PORTS   AGE
stockline   nginx   stockline.local             80      21s

{"statut":"ok","base_de_donnees":"ok","version":"1.0.0"}
[{"reference":"SSD-500","nom":"Disque SSD 500 Go","prix_unitaire":59.9,"seuil_alerte":5,"id":1,"cree_le":"…"}]
<title>StockLine — Inventaire (Kubernetes)</title>
404
```

### ✅ Point de contrôle

```bash
./verifier.sh 10
```

### ❓ Questions de révision

17. Pourquoi la dernière requête, sans en-tête `Host`, renvoie-t-elle 404 ?
18. Sur EKS, quel contrôleur remplace ingress-nginx, et que crée-t-il côté AWS ?

---

## Étape 11 — Probes, ressources et HPA (30 min)

### 🎯 Objectif

Relire les probes et les ressources de l'API, puis déclencher un
autoscaling horizontal sous charge.

### 📖 Rappel

- **readinessProbe** en échec : le pod est **retiré des endpoints** (plus de
  trafic), mais pas redémarré.
- **livenessProbe** en échec répété : le conteneur est **redémarré**.
- **requests** : ce qui est réservé au scheduling. **limits** : le plafond
  (mémoire dépassée → `OOMKilled`).
- Le **HPA** compare la CPU consommée aux **requests** : 60 % de 100m = 60m.
  Sans requests, il ne peut rien calculer.

### ⌨️ À faire

1. Relisez la configuration réelle de l'API :

   ```bash
   kubectl describe deploy api | grep -E -A3 'Limits|Requests|Liveness|Readiness' | head -14
   kubectl top pods
   ```

2. Créez le HPA et attendez qu'il lise une valeur (environ 30 à 60 s) :

   ```bash
   kubectl apply -f $K8S/manifests/50-hpa.yaml
   kubectl get hpa api -w          # Ctrl+C quand TARGETS affiche cpu: x%/60%
   ```

3. Lancez deux générateurs de charge, puis observez le HPA pendant 2 minutes :

   ```bash
   kubectl run charge --image=busybox:1.36 --restart=Never -- \
     /bin/sh -c 'while true; do wget -qO- http://api/produits >/dev/null; done'
   kubectl run charge2 --image=busybox:1.36 --restart=Never -- \
     /bin/sh -c 'while true; do wget -qO- http://api/produits >/dev/null; done'
   kubectl get hpa api -w
   ```

4. Dans un autre terminal, pendant la charge :

   ```bash
   kubectl get pods -l app=api
   kubectl top pods -l app=api
   ```

5. Arrêtez la charge (le HPA redescendra à 2 replicas après sa fenêtre de
   stabilisation de 60 s) :

   ```bash
   kubectl delete pod charge charge2
   ```

### 👀 Ce que vous devez voir

```text
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:      100m
      memory:   128Mi
    Liveness:   http-get http://:8000/sante delay=15s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:8000/sante delay=5s timeout=1s period=5s #success=1 #failure=3

NAME   REFERENCE        TARGETS         MINPODS   MAXPODS   REPLICAS
api    Deployment/api   cpu: 2%/60%     2         5         2
...                                                                  (charge lancée)
api    Deployment/api   cpu: 163%/60%   2         5         5
```

```text
NAME                   CPU(cores)   MEMORY(bytes)
api-5f8f8675c9-5n9pz   169m         61Mi
api-5f8f8675c9-dk6m5   165m         60Mi
api-5f8f8675c9-g2w86   162m         60Mi
...
```

Les valeurs exactes dépendent de votre machine ; ce qui compte est le passage de
2 à 5 replicas en moins d'une minute.

### ✅ Point de contrôle

```bash
./verifier.sh 11
```

### ❓ Questions de révision

19. Avec 2 pods à 165 % de leurs requests et une cible de 60 %, combien de
    replicas le HPA calcule-t-il ? Pourquoi n'en obtenez-vous que 5 ?
20. Vous voulez qu'un pod démarré mais pas encore connecté à la base ne reçoive
    aucun trafic. Readiness ou liveness ?

---

## Étape 12 — Diagnostic des 6 pannes (30 min)

### 🎯 Objectif

Identifier 6 pannes classiques **sans lire les YAML**, uniquement avec les
commandes d'observation.

### 📖 Rappel

La méthode, toujours dans cet ordre :

```bash
kubectl get pods                    # 1. le STATUS oriente
kubectl describe pod <pod>          # 2. les Events expliquent
kubectl logs <pod> --previous       # 3. les logs du conteneur précédent (crash)
kubectl get endpointslices          # 4. pour un Service qui ne répond pas
```

### ⌨️ À faire

1. Déployez les 6 applications cassées dans leur propre namespace :

   ```bash
   kubectl create namespace pannes
   for i in 1 2 3 4 5 6; do kubectl -n pannes apply -f $K8S/pannes/panne-$i.yaml; done
   sleep 60
   kubectl -n pannes get deploy,pods,svc
   ```

2. Pour chaque application, trouvez la cause avec `describe`, `logs`,
   `get endpointslices`, et remplissez ce tableau dans `reponses.md` :

   | Application | STATUS observé | Commande qui révèle la cause | Cause | Correction proposée |
   |---|---|---|---|---|
   | catalogue | | | | |
   | compta-db | | | | |
   | rapport | | | | |
   | moulinette | | | | |
   | vitrine | | | | |
   | boutique | | | | |

3. Seulement après avoir rempli le tableau, vérifiez vos hypothèses dans les YAML
   (`less $K8S/pannes/panne-<n>.yaml`), puis nettoyez :

   ```bash
   kubectl delete namespace pannes
   ```

### 👀 Ce que vous devez voir

```text
NAME                              READY   STATUS             RESTARTS
pod/boutique-6dd465ff4-8lfkj      1/1     Running            0
pod/catalogue-5f8d8ddb74-8jg4t    0/1     ImagePullBackOff   0
pod/compta-db-7b75764f69-lbnwg    0/1     Error              3
pod/moulinette-55c7d9b8b5-gx7np   0/1     OOMKilled          3
pod/rapport-b7bd9465c-kfjqx       0/1     Pending            0
pod/vitrine-6f7bdcdc-7r7vs        0/1     Running            0
```

Attention au piège : `boutique` a l'air parfaitement saine (`1/1 Running`).
Regardez son Service.

### ✅ Point de contrôle

```bash
./verifier.sh 12      # à lancer AVANT le delete namespace
```

Le formateur corrige le tableau collectivement.

### ❓ Question de révision

21. Parmi les 6 pannes, lesquelles `kubectl get pods` ne suffit PAS à voir ?

---

## Étape 13 — Helm (20 min)

### 🎯 Objectif

Redéployer toute la pile StockLine en une commande avec le chart du bloc,
puis faire une mise à jour et un retour arrière Helm.

### 📖 Rappel

- Un **chart** = des templates YAML + un fichier `values.yaml`. Une **release** =
  une installation du chart dans un namespace. Chaque `upgrade` ou `rollback` crée
  une **révision**.
- `helm template` affiche le YAML rendu **sans rien installer** : toujours le
  regarder avant.

### ⌨️ À faire

1. Supprimez la pile construite à la main (le namespace entier, sonde comprise) :

   ```bash
   kubectl delete namespace stockline
   ```

2. Vérifiez le chart et regardez ce qu'il va créer :

   ```bash
   helm lint $K8S/chart-stockline
   helm template stockline $K8S/chart-stockline -n stockline \
     --set db.auth.password=x | grep '^kind:' | sort | uniq -c
   ```

3. Installez, puis attendez que tout soit prêt :

   ```bash
   helm install stockline $K8S/chart-stockline -n stockline --create-namespace \
     --set db.auth.password="$(openssl rand -hex 16)"
   kubectl get pods -w          # Ctrl+C quand tout est 1/1 Running
   ```

4. Passez l'API à 3 replicas, puis revenez à la révision 1 :

   ```bash
   helm upgrade stockline $K8S/chart-stockline -n stockline --reuse-values --set api.replicas=3
   kubectl get deploy api
   helm rollback stockline 1 -n stockline
   kubectl get deploy api
   helm history stockline -n stockline
   ```

### 👀 Ce que vous devez voir

```text
1 chart(s) linted, 0 chart(s) failed
   2 kind: ConfigMap
   3 kind: Deployment
   1 kind: Ingress
   1 kind: PersistentVolumeClaim
   1 kind: Secret
   3 kind: Service

NAME                     READY   STATUS    RESTARTS      AGE
api-7cfffdfd9b-5dvfq     1/1     Running   2 (17s ago)   22s
db-6c5d896b4b-97g4t      1/1     Running   0             22s
...

REVISION  STATUS      CHART            APP VERSION  DESCRIPTION
1         superseded  stockline-0.1.0  1.0.0        Install complete
2         superseded  stockline-0.1.0  1.0.0        Upgrade complete
3         deployed    stockline-0.1.0  1.0.0        Rollback to 1
```

Les pods `api` redémarrent souvent 1 ou 2 fois au démarrage : ils sont prêts avant
PostgreSQL, la livenessProbe échoue, le conteneur redémarre, puis tout se stabilise.

### ✅ Point de contrôle

```bash
./verifier.sh 13
```

### ❓ Questions de révision

22. `helm lint` affiche `db.auth.password est obligatoire`. D'où vient ce message,
    et pourquoi est-ce une bonne pratique ?
23. Le produit SSD-500 existe-t-il encore ? Pourquoi ?

---

## Bilan — 8 questions éclair (10 min)

Répondez sans regarder vos notes, puis comparez avec votre voisin.

1. Quel objet garantit qu'un nombre donné de pods tourne en permanence ?
2. Un Service a 0 endpoint : quelles sont les deux causes les plus fréquentes ?
3. ConfigMap ou Secret pour l'URL d'une base ? Et pour son mot de passe ?
4. Quelle commande montre l'historique des versions d'un Deployment ?
5. Que signifie `CrashLoopBackOff` ? Quelle commande lancer en premier ?
6. Pourquoi le HPA a-t-il besoin des `requests` ?
7. Un pod est `Pending` depuis 5 minutes : où chercher la cause ?
8. Quelle est la différence entre `helm upgrade` et `kubectl apply` ?

## Nettoyage de fin de journée (5 min)

```bash
helm uninstall stockline -n stockline
kubectl delete namespace stockline
kubectl config set-context --current --namespace=default
minikube stop                       # ou minikube delete pour tout effacer
```

Vérification : `kubectl get namespaces` ne liste plus ni `stockline` ni `pannes`.

## Dépannage courant

| Symptôme | Cause probable | Correction |
|---|---|---|
| Pods `api` en `ErrImagePull` / `ImagePullBackOff` dès l'étape 7 | l'image n'est pas dans minikube | `minikube image load stockline-api:1.0.0`, puis `kubectl delete pod -l app=api` |
| `./verifier.sh` : « namespace par défaut = default » | contexte non modifié | `kubectl config set-context --current --namespace=stockline` |
| `kubectl top` : `Metrics API not available` | metrics-server pas encore prêt | `minikube addons enable metrics-server`, attendre 1 minute |
| HPA `TARGETS <unknown>/60%` | pas de métriques, ou pas de `requests` | vérifier `kubectl top pods`, puis les requests du Deployment |
| `curl` sur `localhost:8080` : connexion refusée | le port-forward de l'étape 10 est arrêté | le relancer dans un terminal dédié |
| Pod `db` en `CrashLoopBackOff` à l'étape 6 | Secret absent ou incomplet | `kubectl describe pod -l app=db`, recréer le Secret |
| `error: the server doesn't have a resource type` | mauvais cluster | `kubectl config current-context` |

## Pour aller plus loin

- Rejouez l'étape 12 en corrigeant chaque YAML jusqu'à obtenir 6 applications saines.
- Activez le HPA dans le chart : `--set api.autoscaling.enabled=true`.
- Relisez le cheatsheet `cheatsheet/13-cl-cont-j4-j7.md`, section « Spécificités EKS » :
  c'est le même déploiement, sur AWS.
