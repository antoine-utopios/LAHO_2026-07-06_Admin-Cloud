# TP — De GitLab CI/CD à Kubernetes

**Durée :** 1 journée
**Modalité :** individuel ou binôme

## Contexte

L'entreprise fictive **MicroShop** déploie aujourd'hui son application via un pipeline GitLab CI qui :

1. construit une image Docker de l'application,
2. la pousse sur le registre privé GitLab,
3. se connecte en SSH sur un serveur distant pour tirer l'image et relancer le conteneur.

C'est exactement le pipeline que vous savez déjà écrire.

La direction technique décide de migrer l'hébergement vers un **cluster Kubernetes**. Votre mission aujourd'hui : adapter le pipeline existant pour qu'il déploie sur Kubernetes au lieu de SSH, en réutilisant ce que vous savez déjà faire (variables CI/CD, registre privé, secrets encodés en base64).

## Prérequis fournis

- Un namespace Kubernetes personnel sur le cluster de formation
- Un projet GitLab avec Container Registry activé
- Un dépôt de départ contenant le pipeline SSH existant

Aucune connaissance Kubernetes préalable n'est nécessaire : la Partie 2 vous donne les bases indispensables.

## Déroulé de la journée

| Horaire | Bloc |
|---|---|
| 9h00 – 9h30 | Partie 0 — Mise en place |
| 9h30 – 10h30 | Partie 1 — Pipeline CI (build & push) |
| 10h30 – 12h00 | Partie 2 — Déploiement Kubernetes manuel |
| 12h00 – 13h00 | Pause déjeuner |
| 13h00 – 15h00 | Partie 3 — Intégration du déploiement dans le pipeline |
| 15h00 – 16h00 | Partie 4 — Pour aller plus loin (bonus) |
| 16h00 – 16h30 | Restitution |

---

## Partie 0 — Mise en place

1. Vérifiez l'accès à votre projet GitLab et à son Container Registry.
2. Récupérez les identifiants d'accès à votre namespace Kubernetes personnel (fournis par le formateur).
3. Testez la connexion :
   ```bash
   kubectl get pods -n <mon-namespace>
   ```
4. Clonez le dépôt de départ fourni.

---

## Partie 1 — Pipeline CI : build & push

Faites fonctionner les stages `build` et `push` à partir du dépôt fourni.

**Consigne :** au lieu de taguer l'image en `latest`, taguez-la avec `$CI_COMMIT_SHORT_SHA`, en plus du tag `latest`.

**À vous de jouer :** notez en une ou deux phrases pourquoi taguer par SHA est important quand on va déployer sur Kubernetes. Vous en discuterez à l'oral en fin de journée.

---

## Partie 2 — Déploiement Kubernetes manuel

Avant de toucher au pipeline, déployez **à la main** (avec `kubectl`, sans CI) l'image que vous venez de pousser.

Complétez le manifeste suivant :

```yaml
# deployment.yaml (à compléter)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: microshop
spec:
  replicas: ???
  selector:
    matchLabels:
      app: ???
  template:
    metadata:
      labels:
        app: ???
    spec:
      imagePullSecrets:
        - name: ???        # à créer : secret d'authentification au registre GitLab
      containers:
        - name: microshop
          image: ???        # image du registre privé GitLab, tag SHA
          ports:
            - containerPort: ???
```

**Tâches :**

1. Créez le `Secret` de type `docker-registry` permettant à Kubernetes de tirer l'image depuis le registre privé GitLab (c'est l'équivalent du `docker login` que vous faisiez en SSH avec `CI_REGISTRY_USER` / `CI_REGISTRY_PASSWORD`).
2. Complétez et appliquez le `Deployment` ci-dessus.
3. Créez un `Service` pour exposer l'application.
4. Vérifiez que les pods démarrent correctement :
   ```bash
   kubectl get pods -n <ns>
   kubectl describe pod <pod> -n <ns>
   kubectl logs <pod> -n <ns>
   ```

---

## Partie 3 — Intégration dans le pipeline GitLab CI

Remplacez maintenant le stage `deploy` SSH par un stage `deploy` Kubernetes, en réutilisant le même principe que pour `SERVER_SSH_PRIVATE_KEY_BASE64` : une variable CI/CD encodée en base64, décodée dans le job, puis utilisée pour s'authentifier.

**Variables CI/CD à créer** (en masqué/protégé, dans les paramètres du projet GitLab) :

| Variable | Contenu |
|---|---|
| `KUBE_CONFIG_BASE64` | Votre kubeconfig, encodé en base64 |
| `K8S_NAMESPACE` | Votre namespace Kubernetes |

Squelette de job à compléter :

```yaml
deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - echo "$KUBE_CONFIG_BASE64" | base64 -d > kubeconfig
    - export KUBECONFIG=kubeconfig
    - kubectl set image deployment/microshop microshop=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA -n $K8S_NAMESPACE
    - kubectl rollout status deployment/microshop -n $K8S_NAMESPACE
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

**Tâches :**

1. Écrivez le job `deploy` ci-dessus (ou intégralement seul si vous vous sentez à l'aise, sans le squelette).
2. Assurez-vous que le `Deployment` et le `Secret` de la Partie 2 existent déjà dans votre namespace.
3. Déclenchez le pipeline et vérifiez le déploiement via les logs du job (`kubectl rollout status`).
4. Faites un second commit et vérifiez qu'un nouveau rollout se déclenche automatiquement avec le nouveau tag SHA.

---

## Partie 4 — Pour aller plus loin (bonus)

Si vous avez terminé les parties précédentes, choisissez une ou plusieurs pistes :

- **Rollback :** déclenchez volontairement un déploiement cassé (mauvais tag), puis effectuez un `kubectl rollout undo`. Réfléchissez à comment automatiser ce rollback dans le pipeline.
- **Probes :** ajoutez un `readinessProbe` / `livenessProbe` au Deployment et observez l'effet sur un rollout.
- **Environnements GitLab :** déclarez un `environment: name: staging` dans le job de déploiement pour bénéficier du dashboard d'environnements GitLab.
- **Validation manuelle :** ajoutez un job `deploy-prod` avec `when: manual`, déclenché uniquement sur tag Git.
- **ConfigMap :** externalisez une variable de configuration applicative dans un `ConfigMap` plutôt qu'en dur dans l'image.

---

## Livrables attendus en fin de journée

- Le dépôt GitLab avec l'historique de commits montrant votre progression
- Le fichier `.gitlab-ci.yml` final avec le stage `deploy` Kubernetes fonctionnel
- Les manifestes Kubernetes (`deployment.yaml`, `service.yaml`) — sans valeurs sensibles en clair dans le dépôt
- Une capture d'écran ou un export texte de `kubectl get all -n <namespace>` à l'état final
- Un court README expliquant vos choix et les difficultés rencontrées

---

## Aide-mémoire kubectl

```bash
kubectl get pods -n <ns>
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl get events -n <ns> --sort-by='.lastTimestamp'
kubectl create secret docker-registry regcred \
  --docker-server=$CI_REGISTRY \
  --docker-username=<user> \
  --docker-password=<token> \
  -n <ns>
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns>
kubectl set image deployment/<name> <container>=<image> -n <ns>
```

## Glossaire express

| Terme | Définition courte |
|---|---|
| Pod | Plus petite unité déployable, contient un ou plusieurs conteneurs |
| Deployment | Gère un ensemble de Pods identiques et leurs mises à jour |
| Service | Point d'accès réseau stable vers un ensemble de Pods |
| Secret | Objet stockant des données sensibles (mots de passe, tokens, `.dockerconfigjson`) |
| Namespace | Espace de nommage isolant des ressources dans un même cluster |
| Rollout | Processus de mise à jour progressive d'un Deployment |
