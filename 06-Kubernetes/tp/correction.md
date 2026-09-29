# Correction du TP - Révision de Kubernetes

## Etape 1

1. Démarrez le cluster et activez les deux addons :

```bash
minikube start --cpus 2 --memory 3072
minikube addons enable ingress
minikube addons enable metrics-server
```

2. Conteneuriser et chargez l'image de l'API dans le cluster.

```bash
cd stockline-docker
docker build -t stockline-api:1.0.0 .
docker images stockline-api            # stockline-api   1.0.0   …
minikube image load stockline-api:1.0.0
minikube image ls | grep stockline     # docker.io/library/stockline-api:1.0.0
```

3. Préparez votre dossier de travail et la variable qui pointe vers le code du bloc (adaptez le chemin vers VOTRE copie du dépôt) :

```bash
mkdir -p workshop-k8s
export K8S=$(pwd)
ls $K8S/manifests                      # 00-namespace.yaml … 50-hpa.yaml
chmod +x $K8S/workshop/verifier.sh
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

## Etape 2

1. Générez le manifest d'un pod busybox qui dort 10 heures, et lisez-le :

```bash
kubectl run sonde --image=busybox:1.36 --dry-run=client -o yaml -- sleep 36000 > workshop-k8s/pod-sonde.yaml
cat workshop-k8s/pod-sonde.yaml
```

2. Créez-le et attendez qu'il soit prêt :

```bash
kubectl apply -f workshop-k8s/pod-sonde.yaml
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

## Etape 3

1. Générez et lisez le manifest :

```bash
kubectl create deployment front --image=nginx:1.27-alpine --replicas=2 \
    --dry-run=client -o yaml > workshop-k8s/front-deployment.yaml
cat workshop-k8s/front-deployment.yaml
```

2. Appliquez et suivez le déploiement :

```bash
kubectl apply -f workshop-k8s/front-deployment.yaml
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
kubectl apply -f workshop-k8s/front-deployment.yaml
kubectl get deploy front
```
## Etape 4

1. Générez le Service, lisez-le, appliquez-le :

```bash
kubectl expose deployment front --port=80 --target-port=80 \
    --dry-run=client -o yaml > workshop-k8s/front-service.yaml
cat workshop-k8s/front-service.yaml
kubectl apply -f workshop-k8s/front-service.yaml
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

## Etape 5

1. Lisez puis appliquez le ConfigMap fourni. Repérez la clé `index.html` :

```bash
head -20 $K8S/manifests/29-front-configmap.yaml
kubectl apply -f $K8S/manifests/29-front-configmap.yaml
kubectl get configmap front-html
```

2. Éditez `front-deployment.yaml` en `front-deployment-5.yaml` pour monter ce ConfigMap dans `/usr/share/nginx/html`. La section `spec.template.spec` doit devenir exactement celle-ci (attention à l'indentation) :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: front
  name: front
spec:
  replicas: 2
  selector:
    matchLabels:
      app: front
  strategy: {}
  template:
    metadata:
      labels:
        app: front
      spec:
        containers:
        - image: nginx:1.27-alpine
          name: nginx
          resources: {}
          volumeMounts:
          - name: html
            mountPath: /usr/share/nginx/html
            readOnly: true
        volumes:
        - name: html
          configMap:
            name: front-html
status: {}
```

3. Appliquez et observez le remplacement des pods :

```bash
kubectl apply -f workshop-k8s/front-deployment-5.yaml
kubectl rollout status deploy/front
kubectl exec deploy/front -- ls /usr/share/nginx/html
kubectl exec sonde -- wget -qO- http://front | grep '<title>'
```

## Etape 6

1. Créez le Secret avec un mot de passe aléatoire (il n'est écrit dans aucun fichier) :

```bash
kubectl create secret generic db-credentials \
    --from-literal=POSTGRES_USER=stockline \
    --from-literal=POSTGRES_PASSWORD="$(openssl rand -hex 16)" \
    --from-literal=POSTGRES_DB=stockline
kubectl get secret db-credentials -o yaml | grep -A3 '^data'
kubectl get secret db-credentials -o jsonpath='{.data.POSTGRES_USER}' | base64 -d; echo
```

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

## Etape 7

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

## Etape 8

```bash
kubectl get pods -l app=db
kubectl delete pod -l app=db
kubectl get pods -l app=db -w          # Ctrl+C quand le nouveau pod est 1/1 Running
kubectl exec sonde -- wget -qO- http://api/stocks/1; echo
```

## Etape 9

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

## Etape 10

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

4. *(Facultatif, navigateur)* Ajoutez `127.0.0.1 stockline.local` à votre fichier `hosts` (`/etc/hosts`, ou `C:\Windows\System32\drivers\etc\hosts`), puis ouvrez `http://stockline.local:8080` : le tableau affiche SSD-500.

## Etape 11

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

## Etape 12

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

3. Seulement après avoir rempli le tableau, vérifiez vos hypothèses dans les YAML (`less $K8S/pannes/panne-<n>.yaml`), puis nettoyez :

```bash
kubectl delete namespace pannes
```

## Etape 13

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
