# TP 3 — Jour 2 : la même API sur Azure + comparatif argumenté

> Bloc : 10 — CL-TP3 — TP AWS Serverless + Azure Python
> Durée estimée : 1 journée (~5 h 30 effectives)
> Difficulté : 3,5 / 5
> Type : TP de validation **noté sur 20**, **individuel**

## Mise en situation

Hier soir, vous avez livré l'API marketplace en serverless AWS. Ce matin,
message de la direction de Negoce+ :

> « Beau travail. Maintenant la deuxième moitié de la commande : la **même API
> sur Azure**, avec le même niveau d'exigence — secrets protégés, supervision
> active, destruction propre. Et à 16 h 30, je veux votre **recommandation** :
> AWS ou Azure pour la marketplace ? Chiffres et arguments, pas d'opinions. »

Vous avez **deux voies possibles** — les deux sont acceptées et notées à la
même grille. Vous devrez **justifier votre choix par écrit** :

- **Voie A — App Service** : vous réutilisez l'application FastAPI du fil
  rouge telle quelle (celle du bloc Azure J4). Base : **PostgreSQL flexible**.
- **Voie B — Azure Functions** : vous réécrivez les endpoints dans le modèle
  Python v2 (décorateurs), comme les Lambdas d'hier. Données : **Table
  Storage** (ou PostgreSQL si vous y tenez — justifiez).

Dans les deux cas : **zéro secret en clair** (Key Vault + managed identity),
**Application Insights actif**, tests, teardown `az group delete`.

## Objectifs

- Déployer l'API StockLine sur un service **PaaS/serverless Azure** et
  **argumenter le choix** App Service vs Functions.
- Choisir et justifier le service de données (PostgreSQL flexible vs Table
  Storage).
- Appliquer le pattern **Key Vault + managed identity** : aucun secret dans la
  configuration ni dans le code.
- Activer et exploiter **Application Insights**.
- Produire le **livrable comparatif AWS vs Azure** attendu par la direction.

## Règles du TP noté

Identiques à hier : individuel, entraide orale seulement, 20 minutes de blocage
maximum avant d'appeler, grille publiée dès le briefing.

## Prérequis techniques

- Abonnement Azure **à crédits** individuel, `az login` fait, région
  **francecentral**.
- `PREFIX` exporté (le même trigramme qu'hier).
- Voie A : le code du fil rouge (`code/stockline/`).
- Voie B : Azure Functions Core Tools v4 (`func --version` → 4.x, installés au
  bloc Azure J4).

### Vérification de l'environnement

```bash
export PREFIX=abc
az account show --query name -o tsv        # votre abonnement à crédits
az group list -o table                     # il ne doit rien rester du bloc 09
python3 --version                          # 3.12.x
```

## Architecture cible

```text
  VOIE A — App Service                    VOIE B — Functions
  =====================                   ===================

        Internet                                Internet
           |                                       |
           v                                       v
  App Service  app-tp3-<prefix>          Function App  func-tp3-<prefix>
  (plan B1 Linux, Python 3.12,           (plan consumption Linux,
   FastAPI du fil rouge, gunicorn)        Python 3.12, modèle v2)
     |    |    managed identity             |    |    managed identity
     |    +---------------+                 |    +---------------+
     v                    v                 v                    v
  PostgreSQL flexible   Key Vault        Table Storage        Key Vault
  pg-tp3-<prefix>       kv-tp3-<prefix>  (compte st...)       kv-tp3-<prefix>
  (B1ms, base            secret :         table "stockline"    secret : chaîne
   stockline)            database-url     (PartitionKey/RowKey) de connexion
     ^                    |                 ^                    |
     |   référence @Microsoft.KeyVault(...) |   référence @Microsoft.KeyVault(...)
     +--------------------+                 +--------------------+

  Dans les DEUX voies :
  - Application Insights  ai-tp3-<prefix>  (requêtes, erreurs, latences)
  - TOUT vit dans UN groupe : rg-tp3-<prefix>  → teardown en UNE commande
```

💰 **Coût (crédits)** : voie A ≈ 0,90 €/jour (plan B1 ~0,45 € + PostgreSQL
B1ms ~0,45 €) **tant que ça existe** — c'est un argument du comparatif. Voie
B ≈ 0 € au repos (consumption : 1 M d'exécutions offertes/mois, stockage
quelques centimes). Teardown du soir **obligatoire et noté** dans les deux cas.

## Étapes

### Étape 1 — Choisir sa voie et son service de données (30 min) — *jalon « GO conception »*

Objectif : un choix **assumé par écrit** avant la première ressource.

1. Rédigez en tête de votre `COMPARATIF.md` un encadré « Mes choix » (5-10
   lignes) : voie A ou B, service de données, et **3 arguments minimum**
   (adhérence au code existant, coût au repos, modèle de données, effort de
   réécriture, correspondance avec la version AWS d'hier…).
2. Critères de décision honnêtes :
   - vous voulez capitaliser sur FastAPI et SQLAlchemy → voie A ;
   - vous voulez le vrai symétrique du serverless AWS d'hier (et un coût au
     repos nul) → voie B ;
   - PostgreSQL : relationnel, requêtes riches, mais facture au repos ;
   - Table Storage : clé/valeur comme DynamoDB, centimes, mais pas de SQL.
3. Faites viser ce choix par le formateur (GO conception).

Point de contrôle : encadré « Mes choix » visé ; `az group list` ne montre
encore aucune ressource TP3.

### Étape 2 — Socle : groupe, données, Key Vault (1 h 15)

Objectif : le socle de données et le coffre à secrets, dans **un seul groupe**.

1. Créez `rg-tp3-${PREFIX}` (tags `Projet=stockline-tp3`,
   `Proprietaire=${PREFIX}`). **Tout** le TP vit dedans : c'est votre teardown.
2. Voie A : créez le PostgreSQL flexible `pg-tp3-${PREFIX}` (Burstable
   `Standard_B1ms`, 32 Go, version 16, base `stockline`,
   `--public-access 0.0.0.0` pour autoriser les services Azure). Mot de passe
   **généré** (`openssl rand -base64 24 | tr -d '/+='`), jamais tapé en clair
   dans un fichier. ⏱ La création prend 5-10 min : préparez la suite pendant.
   Voie B : créez le compte de stockage (nom : minuscules/chiffres, unique au
   monde — dérivez un suffixe) et la table `stockline` ; insérez 2-3 produits
   de démonstration (`az storage entity insert` — attention aux types :
   `prix_unitaire@odata.type=Edm.Double`).
3. Créez le Key Vault `kv-tp3-${PREFIX}` (`--enable-rbac-authorization true`),
   donnez-vous `Key Vault Secrets Officer` (RBAC : posséder le coffre ne donne
   pas l'accès aux données — et la propagation peut prendre plusieurs minutes),
   puis déposez LE secret : `database-url` (voie A) ou
   `tables-connection-string` (voie B).

Point de contrôle : `az keyvault secret show --vault-name kv-tp3-${PREFIX}
--name <secret> --query name` répond ; le service de données est `Ready`/`available` ;
**aucun mot de passe dans votre historique** (`history | grep -i pass` → rien).

### Étape 3 — Déployer l'application (1 h 30)

Objectif : l'API répond sur `https://…azurewebsites.net`.

Voie A — App Service :

1. Application Insights `ai-tp3-${PREFIX}` (récupérez la `connectionString`).
2. Plan `plan-tp3-${PREFIX}` (B1, Linux) + Web App `app-tp3-${PREFIX}`
   (runtime `PYTHON:3.12`).
3. Startup command : `gunicorn --bind=0.0.0.0:8000 -w 2 -k
   uvicorn.workers.UvicornWorker app.main:app`.
4. App settings : `SCM_DO_BUILD_DURING_DEPLOYMENT=true`,
   `APPLICATIONINSIGHTS_CONNECTION_STRING=<connexion AI>`, et pour l'instant
   **pas** de `DATABASE_URL` (elle arrivera par référence Key Vault à l'étape 4).
5. Zip du code (app/ + front/ + requirements.txt, avec `psycopg2-binary` et
   `gunicorn` activés) puis `az webapp deploy … --type zip` (build Oryx : 2-4 min).

Voie B — Functions :

1. Application Insights `ai-tp3-${PREFIX}`.
2. Function App `func-tp3-${PREFIX}` : `--consumption-plan-location
   francecentral --runtime python --runtime-version 3.12 --functions-version 4
   --os-type Linux --app-insights ai-tp3-${PREFIX}`, adossée à votre compte de
   stockage.
3. Réécrivez les endpoints dans `function_app.py` (modèle v2, décorateurs
   `@app.route`) : `/sante`, `/produits` (GET/POST), `/produits/{reference}`,
   `/mouvements` (POST), `/mouvements/{reference}`, `/stocks/{reference}` —
   mêmes règles métier et mêmes codes HTTP qu'hier. Astuce d'égalité de
   périmètre : `"routePrefix": ""` dans host.json supprime le `/api` par défaut.
   Rappel Table Storage : `#` est **interdit** dans PartitionKey/RowKey —
   adaptez la convention d'hier (`MVT_<ref>` plutôt que `MVT#<ref>`).
4. Publiez : `func azure functionapp publish func-tp3-${PREFIX} --python`.

Point de contrôle : `curl https://<app>.azurewebsites.net/sante` répond — même
si la base n'est pas encore branchée proprement (voie A : `/sante` peut dire
`base_de_donnees: indisponible` tant que l'étape 4 n'est pas faite ; c'est un
diagnostic, pas un échec).

### Étape 4 — Managed identity + référence Key Vault (1 h) — *le cœur noté /4*

Objectif : l'application lit son secret **sans qu'aucun humain ni fichier ne le
détienne**.

1. Activez l'identité system-assigned :
   `az webapp identity assign` (ou `az functionapp identity assign`) →
   notez le `principalId`.
2. Donnez à ce principal le rôle **`Key Vault Secrets User`** sur le scope du
   coffre — lecture des secrets, rien d'autre. Sauriez-vous dire pourquoi pas
   `Secrets Officer` ?
3. Posez l'app setting **en référence** :
   `DATABASE_URL=@Microsoft.KeyVault(SecretUri=https://kv-tp3-${PREFIX}.vault.azure.net/secrets/database-url/)`
   (voie B : `TABLES_CONNECTION_STRING=@…/secrets/tables-connection-string/)`).
4. Redémarrez, puis **prouvez** les trois points : (a) la config ne contient
   que la référence (`az webapp config appsettings list … --query
   "[?name=='DATABASE_URL'].value"`), (b) l'app fonctionne quand même
   (`/sante` → ok), (c) portail → Environment variables → colonne *Source* =
   « Key Vault Reference » résolue (coche verte).

Point de contrôle : les trois preuves capturées. ⚠️ La propagation RBAC peut
prendre 5-10 min : une référence non résolue juste après l'assignation n'est
pas une panne — allez préparer l'étape 5 et revenez.

### Étape 5 — Tests + Application Insights (45 min)

Objectif : la même campagne de tests qu'hier, et la supervision qui la voit.

1. Rejouez la **campagne curl d'hier** (mêmes appels, mêmes codes attendus —
   c'est la définition du « même périmètre » pour le comparatif). Ajoutez une
   mesure simple de latence à froid puis à chaud :
   `curl -s -o /dev/null -w '%{time_total}\n' "$URL/produits"` (3 fois).
2. Générez un peu de trafic (une boucle de 50 GET), puis dans Application
   Insights : **Live Metrics** pendant la boucle, puis onglet *Failures* (vos
   404/400 volontaires doivent s'y voir) et une requête KQL simple :

   ```kusto
   requests
   | where timestamp > ago(30m)
   | summarize nb=count(), p95=percentile(duration, 95) by resultCode
   | order by nb desc
   ```

3. Capturez : la campagne (codes obtenus), le résultat KQL, une vue Failures.

Point de contrôle : mêmes codes HTTP qu'hier sur toute la campagne ; le
formateur peut voir vos requêtes dans Application Insights.

### Étape 6 — Le livrable comparatif (45 min) — *noté /3*

Objectif : la recommandation que la direction attend à 16 h 30.

Complétez `COMPARATIF.md` avec **la grille imposée** ci-dessous (remplissez
chaque case avec vos mesures et observations des deux journées, pas avec des
généralités) :

```markdown
## Grille comparative AWS vs Azure — API marketplace StockLine

| Critère | AWS (Lambda + API GW + DynamoDB) | Azure (voie choisie) |
|---|---|---|
| Coût estimé AU REPOS (€/mois) | | |
| Coût estimé EN PIC (hypothèse : 1 M req/mois) | | |
| Temps que J'AI mis à déployer (réel, en h) | | |
| Nombre d'étapes/ressources à créer | | |
| Complexité du moindre privilège (IAM vs RBAC+MI) | | |
| Gestion des secrets (mécanisme, limites) | | |
| Supervision (outil, mise en route, ce que j'y vois) | | |
| Latence mesurée à froid / à chaud (ms) | | |
| Verrouillage (qu'est-ce qui serait à réécrire pour partir ?) | | |
| Facilité du teardown | | |

## Recommandation (1 page maximum)
- Contexte et hypothèses (trafic, équipe, compétences)
- Mon choix pour la marketplace Negoce+ : …
- Les 3 arguments décisifs : …
- Ce qui pourrait inverser la décision : …
```

Exigences : les coûts sont **chiffrés** (même approximativement, avec
l'hypothèse écrite), la ligne verrouillage cite du **concret** (quel code,
quel service), la recommandation **tranche** (pas de « ça dépend » sans
critère de bascule).

### Étape 7 — Teardown + rendu (30 min)

1. Sous les yeux du formateur : `PREFIX=abc ./teardown.sh` — ou à la main :

   ```bash
   az group delete --name "rg-tp3-${PREFIX}" --yes --no-wait
   # puis, une fois le groupe parti (le nom du coffre reste réservé sinon) :
   az keyvault purge --name "kv-tp3-${PREFIX}"
   az group list --query "[?contains(name, 'tp3')].name" -o table   # → vide
   ```

2. Déposez le rendu complet avant 17 h.

Point de contrôle : `az group list` vide de tout `tp3`, contresigné.

## Livrables (dépôt individuel, avant 17 h)

| # | Livrable | Forme |
|---|---|---|
| 1 | Encadré « Mes choix » visé (voie + données, 3 arguments) | Markdown |
| 2 | Code déployé (zip FastAPI adapté OU function_app.py complet) | Python |
| 3 | Scripts/historique de déploiement | bash |
| 4 | Les 3 preuves Key Vault + managed identity | captures/commandes |
| 5 | Campagne de tests + captures Application Insights (KQL, Failures) | Markdown |
| 6 | `COMPARATIF.md` : grille imposée remplie + recommandation 1 page | Markdown |
| 7 | Preuve de teardown (`az group list` vide, contresigné) | capture |

## Barème (détail dans `grille-evaluation.md`)

| Critère | Points |
|---|---|
| Déploiement (voie au choix ; app en ligne, config propre, choix justifié) | /6 |
| Données (service justifié, schéma cohérent, seed, accès depuis l'app) | /3 |
| Secrets + identity (Key Vault, MI, référence résolue, zéro secret en clair) | /4 |
| Supervision (App Insights actif, trafic visible, une requête KQL exploitée) | /2 |
| Comparatif argumenté (grille chiffrée + recommandation qui tranche) | /3 |
| Teardown + doc | /2 |
| **Total** | **/20** |

## Dépannage courant

<details>
<summary>La référence @Microsoft.KeyVault n'est pas résolue (Source ≠ coche verte, l'app ne démarre pas)</summary>

Cause : dans 90 % des cas, la **propagation RBAC** (jusqu'à 10 min) ou un rôle
manquant/mal scopé sur le coffre ; sinon une faute de frappe dans le SecretUri.
Solution : vérifiez `az role assignment list --scope <id du coffre> -o table`
(le principal de l'app doit y être en `Key Vault Secrets User`) ; testez le
SecretUri en le collant dans un navigateur authentifié ; attendez, redémarrez
l'app, revérifiez la colonne *Source*.

</details>

<details>
<summary>Voie A : « Application Error » à l'ouverture de l'URL</summary>

Cause : l'app ne démarre pas — startup command absente/fausse, dépendance
manquante (gunicorn, psycopg2), ou `DATABASE_URL` illisible.
Solution : `az webapp log tail -g rg-tp3-$PREFIX -n app-tp3-$PREFIX` et lisez
la vraie stack trace ; vérifiez la startup command (`az webapp config show
--query linuxFxVersion,appCommandLine`) ; vérifiez que le build Oryx a bien eu
lieu (`SCM_DO_BUILD_DURING_DEPLOYMENT=true` AVANT le deploy).

</details>

<details>
<summary>Voie A : /sante répond mais dit base_de_donnees: indisponible</summary>

Cause : l'app tourne, PostgreSQL ne répond pas : firewall du serveur flexible
(la règle « services Azure » manque), `sslmode=require` absent de l'URL, ou
mot de passe faux dans le secret.
Solution : `az postgres flexible-server firewall-rule list` ; reconstruisez
la `database-url` et re-déposez-la dans le coffre (nouvelle version du secret),
puis redémarrez l'app.

</details>

<details>
<summary>Voie B : func publish réussit mais les routes répondent 404</summary>

Cause : le modèle v2 n'a **pas indexé** vos fonctions (souvent : une exception
à l'import de `function_app.py` — par exemple `TABLES_CONNECTION_STRING`
absent au moment du chargement) ; ou vous appelez `/produits` alors que le
`routePrefix` par défaut impose `/api/produits`.
Solution : `az functionapp function list -g rg-tp3-$PREFIX -n func-tp3-$PREFIX
-o table` — si la liste est vide, lisez le logstream au démarrage : l'erreur
d'import s'y affiche. Vérifiez le `routePrefix` de host.json.

</details>

<details>
<summary>Voie B : « This region has quota of 0 instances » ou création consumption refusée</summary>

Cause : quota du plan consumption sur l'abonnement à crédits dans la région.
Solution : réessayez en `--consumption-plan-location westeurope` (signalez-le
dans la doc), ou basculez la Function App sur le plan B1 existant — le
formateur valide ce repli sans pénalité, notez-le dans le comparatif (ça NUANCE
la promesse serverless !).

</details>

<details>
<summary>Rien n'apparaît dans Application Insights alors que l'app reçoit du trafic</summary>

Cause : `APPLICATIONINSIGHTS_CONNECTION_STRING` absent/faux (voie A), ou
simple latence d'ingestion (2-5 min hors Live Metrics).
Solution : Live Metrics est le seul temps réel — ouvrez-le PENDANT la boucle
de trafic ; vérifiez l'app setting ; attendez 5 min avant de conclure pour les
onglets Failures/Logs.

</details>

<details>
<summary>Le teardown échoue : « the resource group is in deprovisioning state » ou le nom du Key Vault est « déjà utilisé » à la recréation</summary>

Cause : suppression asynchrone encore en cours ; et le Key Vault supprimé
reste en **soft delete** 90 jours (nom réservé).
Solution : patientez pour le groupe (`az group list` pour suivre) ; purgez le
coffre : `az keyvault purge --name kv-tp3-$PREFIX` une fois le groupe parti.

</details>

## Bonus (seulement si tout est validé, teardown compris)

1. **Slot de staging** (voie A) : passez le plan en S1 (`az appservice plan
   update --sku S1`), créez un slot `staging`, déployez-y une version modifiée
   de `/sante`, puis `az webapp deployment slot swap` — le déploiement
   sans coupure. 💰 S1 ≈ 3× B1 : repassez en B1 ou teardownez dans l'heure.
2. **Alerte budget Azure** : `az consumption budget` (ou portail → Cost
   Management → Budgets) : 10 € avec alerte à 80 %.
3. **Autoscale** (voie A, si S1) : une règle CPU > 70 % → +1 instance ;
   comparez avec « rien à faire » côté Lambda — un argument de plus pour la
   grille.

## Pour aller plus loin

Le débrief collectif de 16 h 30 confrontera les recommandations de chacun —
gardez trois arguments prêts à défendre à l'oral. Au bloc suivant (CL-IAC),
vous apprendrez à décrire tout ce que vous avez construit à la main ces deux
jours… en quelques fichiers Terraform.
