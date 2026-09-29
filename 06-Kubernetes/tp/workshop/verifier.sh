#!/usr/bin/env bash
# =============================================================================
# verifier.sh — points de contrôle du workshop de révision Kubernetes
# (bloc 13-cl-cont). À lancer à la fin de chaque étape :
#
#   ./verifier.sh 4        # vérifie l'état attendu à la fin de l'étape 4
#   ./verifier.sh tout     # rejoue tous les contrôles des étapes 1 à 11
#
# Le script ne modifie RIEN dans le cluster : il ne fait que lire
# (get / exec de commandes en lecture dans le pod « sonde »).
# =============================================================================
set -uo pipefail

NS="stockline"
OK=0
KO=0

vert()  { printf '  \033[32m✅ %s\033[0m\n' "$1"; OK=$((OK+1)); }
rouge() { printf '  \033[31m❌ %s\033[0m\n' "$1"; [[ -n "${2:-}" ]] && printf '     ↳ piste : %s\n' "$2"; KO=$((KO+1)); }
titre() { printf '\n\033[1m== Étape %s — %s\033[0m\n' "$1" "$2"; }

# check "<libellé>" "<piste si échec>" commande...
check() {
  local libelle="$1" piste="$2"; shift 2
  if "$@" >/dev/null 2>&1; then vert "$libelle"; else rouge "$libelle" "$piste"; fi
}

k() { kubectl -n "$NS" "$@"; }

# Nombre de pods prêts d'un Deployment (0 si absent)
pret() { k get deploy "$1" -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -E '^[0-9]+$' || echo 0; }

# Exécute une commande dans le pod sonde (boîte à outils busybox)
sonde() { k exec sonde -- "$@"; }

etape1() {
  titre 1 "Préparation du poste et du cluster"
  check "kubectl joint le cluster" "minikube status ; minikube start" kubectl get --raw /readyz
  check "au moins un nœud Ready" "kubectl get nodes" \
    bash -c "kubectl get nodes --no-headers | awk '\$2 ~ /^Ready/' | grep -q ."
  check "namespace '$NS' créé" "kubectl create namespace $NS" kubectl get namespace "$NS"
  local courant
  courant=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
  if [[ "$courant" == "$NS" ]]; then vert "namespace par défaut du contexte = $NS"
  else rouge "namespace par défaut du contexte = '$courant' (attendu : $NS)" \
    "kubectl config set-context --current --namespace=$NS"; fi
}

etape2() {
  titre 2 "Le Pod"
  check "pod 'sonde' présent" "kubectl apply -f pod-sonde.yaml" k get pod sonde
  check "pod 'sonde' en phase Running" "kubectl describe pod sonde (section Events)" \
    bash -c "[[ \$(kubectl -n $NS get pod sonde -o jsonpath='{.status.phase}') == Running ]]"
  check "pod 'sonde' créé depuis un fichier (annotation last-applied)" \
    "kubectl delete pod sonde puis kubectl apply -f pod-sonde.yaml" \
    bash -c "kubectl -n $NS get pod sonde -o jsonpath='{.metadata.annotations}' | grep -q last-applied"
  check "la sonde résout le DNS du cluster" "le pod sonde tourne-t-il ?" \
    sonde nslookup kubernetes.default.svc.cluster.local
}

etape3() {
  titre 3 "Le Deployment"
  check "deployment 'front' présent" "kubectl apply -f front-deployment.yaml" k get deploy front
  local img
  img=$(k get deploy front -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  [[ "$img" == "nginx:1.27-alpine" ]] && vert "image nginx:1.27-alpine" \
    || rouge "image = '$img' (attendu : nginx:1.27-alpine)" "vérifiez front-deployment.yaml"
  [[ "$(pret front)" -ge 2 ]] && vert "front : au moins 2 pods Ready ($(pret front))" \
    || rouge "front : $(pret front) pod(s) Ready (attendu : 2)" "kubectl get pods -l app=front"
  check "un ReplicaSet porte le Deployment" "kubectl get rs -l app=front" \
    bash -c "kubectl -n $NS get rs -l app=front --no-headers | grep -q ."
}

etape4() {
  titre 4 "Le Service et le DNS"
  check "service 'front' présent" "kubectl apply -f front-service.yaml" k get svc front
  local nb
  nb=$(k get endpointslices -l kubernetes.io/service-name=front \
        -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' 2>/dev/null | grep -c .)
  [[ "$nb" -ge 2 ]] && vert "le service 'front' a $nb endpoints" \
    || rouge "le service 'front' a $nb endpoint(s) (attendu : ≥ 2)" "selector du Service = labels des pods ?"
  check "la sonde joint http://front" "kubectl exec sonde -- wget -qO- http://front" \
    sonde wget -qO- -T 3 http://front
}

etape5() {
  titre 5 "Le ConfigMap monté en fichier"
  check "configmap 'front-html' présent" "kubectl apply -f \$K8S/manifests/29-front-configmap.yaml" \
    k get configmap front-html
  check "le Deployment front monte le ConfigMap" "section volumes + volumeMounts du front" \
    bash -c "kubectl -n $NS get deploy front -o jsonpath='{.spec.template.spec.volumes[*].configMap.name}' | grep -q front-html"
  check "http://front sert la page StockLine" "kubectl rollout status deploy/front" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 3 http://front | grep -q 'StockLine'"
}

etape6() {
  titre 6 "Secret, PVC et base PostgreSQL"
  check "secret 'db-credentials' présent" "kubectl create secret generic db-credentials …" \
    k get secret db-credentials
  check "le secret contient POSTGRES_PASSWORD" "--from-literal=POSTGRES_PASSWORD=…" \
    bash -c "kubectl -n $NS get secret db-credentials -o jsonpath='{.data.POSTGRES_PASSWORD}' | grep -q ."
  check "PVC 'db-data' Bound" "kubectl describe pvc db-data" \
    bash -c "[[ \$(kubectl -n $NS get pvc db-data -o jsonpath='{.status.phase}') == Bound ]]"
  [[ "$(pret db)" -ge 1 ]] && vert "db : 1 pod Ready" || rouge "db : aucun pod Ready" "kubectl logs deploy/db"
  check "la sonde joint db:5432" "service 'db' appliqué ?" sonde nc -z -w 3 db 5432
}

etape7() {
  titre 7 "L'API StockLine"
  check "configmap 'api-config' présent" "kubectl apply -f \$K8S/manifests/20-api-configmap.yaml" \
    k get configmap api-config
  [[ "$(pret api)" -ge 2 ]] && vert "api : $(pret api) pods Ready" \
    || rouge "api : $(pret api) pod(s) Ready (attendu : 2)" "image chargée dans le cluster ? kubectl describe pod -l app=api"
  check "GET http://api/sante répond statut ok + base ok" "kubectl logs deploy/api" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 5 http://api/sante | grep -q '\"base_de_donnees\":\"ok\"'"
  check "le produit SSD-500 existe" "POST /produits (étape 7, point 5)" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 5 http://api/produits | grep -q 'SSD-500'"
}

etape8() {
  titre 8 "La preuve de persistance"
  local age
  age=$(k get pods -l app=db -o jsonpath='{.items[0].metadata.creationTimestamp}' 2>/dev/null)
  local cree_api
  cree_api=$(k get deploy api -o jsonpath='{.metadata.creationTimestamp}' 2>/dev/null)
  if [[ -n "$age" && -n "$cree_api" && "$age" > "$cree_api" ]]; then
    vert "le pod db a été recréé après le déploiement de l'API ($age)"
  else
    rouge "le pod db n'a pas été supprimé depuis l'étape 7" "kubectl delete pod -l app=db"
  fi
  check "SSD-500 a survécu à la recréation du pod db" "le PVC est-il bien monté ?" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 5 http://api/produits | grep -q 'SSD-500'"
}

etape9() {
  titre 9 "Mise à jour progressive et retour arrière"
  local rev
  rev=$(k get rs -l app=api --no-headers 2>/dev/null | grep -c .)
  [[ "$rev" -ge 2 ]] && vert "l'API a connu $rev ReplicaSets (révisions)" \
    || rouge "un seul ReplicaSet pour l'API" "kubectl set image deploy/api api=stockline-api:1.1.0"
  local img
  img=$(k get deploy api -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  [[ "$img" == "stockline-api:1.1.0" ]] && vert "image courante stockline-api:1.1.0 (retour arrière réussi)" \
    || rouge "image courante = '$img' (attendu : stockline-api:1.1.0)" "kubectl rollout undo deploy/api"
  check "aucun pod de l'API en ImagePullBackOff" "kubectl rollout undo deploy/api" \
    bash -c "! kubectl -n $NS get pods -l app=api --no-headers | grep -Eq 'ImagePull|ErrImage'"
  [[ "$(pret api)" -ge 2 ]] && vert "api : $(pret api) pods Ready" || rouge "api : $(pret api) pod(s) Ready" "kubectl rollout status deploy/api"
}

etape10() {
  titre 10 "L'Ingress"
  check "ingress 'stockline' présent" "kubectl apply -f \$K8S/manifests/40-ingress.yaml" k get ingress stockline
  check "contrôleur ingress-nginx démarré" "minikube addons enable ingress" \
    bash -c "kubectl -n ingress-nginx get pods -l app.kubernetes.io/component=controller --no-headers | grep -q Running"
  local ip
  ip=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
  check "ingress : / → front (page StockLine)" "règles de l'ingress" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 5 --header 'Host: stockline.local' http://$ip/ | grep -q StockLine"
  check "ingress : /api/sante → api" "annotation rewrite-target" \
    bash -c "kubectl -n $NS exec sonde -- wget -qO- -T 5 --header 'Host: stockline.local' http://$ip/api/sante | grep -q '\"statut\":\"ok\"'"
}

etape11() {
  titre 11 "Probes, ressources et HPA"
  check "readinessProbe et livenessProbe sur l'API" "21-api-deployment.yaml" \
    bash -c "kubectl -n $NS get deploy api -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' | grep -q '/sante/sante'"
  check "requests CPU définies sur l'API" "sans requests, le HPA ne peut rien calculer" \
    bash -c "kubectl -n $NS get deploy api -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' | grep -q ."
  check "metrics-server répond (kubectl top)" "minikube addons enable metrics-server, attendre 1 min" \
    k top pods
  check "HPA 'api' présent" "kubectl apply -f \$K8S/manifests/50-hpa.yaml" k get hpa api
  check "le HPA lit la CPU (pas <unknown>)" "requests CPU + metrics-server" \
    bash -c "kubectl -n $NS get hpa api -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' | grep -Eq '^[0-9]+$'"
  local maxi
  maxi=$(k get hpa api -o jsonpath='{.status.desiredReplicas}' 2>/dev/null)
  echo "     (info) replicas souhaités par le HPA en ce moment : ${maxi:-?}"
}

etape12() {
  titre 12 "Diagnostic des 6 pannes"
  if kubectl get namespace pannes >/dev/null 2>&1; then
    local restes
    restes=$(kubectl -n pannes get pods --no-headers 2>/dev/null | grep -c .)
    echo "     (info) $restes pod(s) encore présents dans le namespace pannes"
    echo "     Ce contrôle ne note pas votre diagnostic : remplissez le tableau de l'étape 12."
    vert "namespace 'pannes' présent"
  else
    rouge "namespace 'pannes' absent" "kubectl create namespace pannes"
  fi
}

etape13() {
  titre 13 "Helm"
  check "release helm 'stockline' déployée" "helm install stockline \$K8S/chart-stockline -n $NS …" \
    bash -c "helm -n $NS status stockline 2>/dev/null | grep -q 'STATUS: deployed'"
  local rev
  rev=$(helm -n "$NS" history stockline --max 20 2>/dev/null | tail -n +2 | grep -c .)
  [[ "$rev" -ge 3 ]] && vert "$rev révisions (install, upgrade, rollback)" \
    || rouge "$rev révision(s) (attendu : ≥ 3)" "helm upgrade … puis helm rollback stockline 1"
  check "les pods de la release sont Running" "kubectl get pods" \
    bash -c "kubectl -n $NS get pods --no-headers | grep -q Running && ! kubectl -n $NS get pods --no-headers | grep -Ev 'Running|Completed' | grep -q ."
}

case "${1:-}" in
  1|2|3|4|5|6|7|8|9|10|11|12|13) "etape$1" ;;
  tout) for i in 1 2 3 4 5 6 7 8 9 10 11; do "etape$i"; done ;;
  *) echo "Usage : $0 <numéro d'étape 1-13 | tout>"; exit 2 ;;
esac

printf '\nBilan : %d contrôle(s) OK, %d en échec.\n' "$OK" "$KO"
[[ "$KO" -eq 0 ]] && echo "👉 Étape validée, passez à la suivante." || echo "👉 Corrigez les points en rouge avant de continuer."
exit $(( KO > 0 ))
