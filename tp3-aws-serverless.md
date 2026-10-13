# TP 3 — Jour 1 : l'API StockLine serverless sur AWS

> Bloc : 10 — CL-TP3 — TP AWS Serverless + Azure Python
> Durée estimée : 1 journée (~5 h 30 effectives)
> Difficulté : 3,5 / 5
> Type : TP de validation **noté sur 20**, **individuel**

## Mise en situation

Negoce+ ouvre une **marketplace** : des revendeurs partenaires interrogeront le
catalogue StockLine à toute heure. Le trafic sera **quasi nul la nuit** et fera
des **pics imprévisibles** lors des ventes flash. La direction a été claire :

> « L'architecture 3-tiers du TP2 nous coûte même quand personne ne l'utilise.
> Pour la marketplace, je veux une API qui coûte **~0 € au repos** et qui
> encaisse les pics **sans que personne ne redimensionne quoi que ce soit**.
> Et comme on hésite entre AWS et Azure, vous livrerez **les deux** : AWS
> aujourd'hui, Azure demain, avec un comparatif argumenté. »

Aujourd'hui : la version **AWS serverless** — DynamoDB, Lambda, API Gateway.
Vous avez tout vu en CL-AWS2 ; ce TP vous demande de l'assembler **seul(e)**,
proprement, et de le prouver.

## Objectifs

- Concevoir une table DynamoDB **unique** qui héberge produits ET mouvements,
  et justifier ses clés.
- Écrire et déployer **3 fonctions Lambda Python 3.12** (produits, mouvements,
  stocks), chacune avec **son propre rôle IAM au moindre privilège**.
- Exposer l'ensemble derrière une **HTTP API** (API Gateway) avec les bonnes
  routes.
- Prouver le fonctionnement par une **campagne de tests curl** et lire les
  **logs CloudWatch**.
- Détruire l'infrastructure par un **teardown scripté et vérifié**.

## Règles du TP noté

- Travail **individuel** : l'entraide orale est permise, le copier-coller de
  code entre postes ne l'est pas (contrôle par sondage : on vous demandera
  d'expliquer n'importe quelle ligne de votre rendu).
- Bloqué plus de 20 minutes → appelez le formateur (indices gradués, seuls les
  indices de niveau 3 sont consignés).
- La grille d'évaluation (`tp/10-cl-tp3/grille-evaluation.md`) est publiée dès
  le briefing : travaillez avec elle sous les yeux.

## Prérequis techniques

- Compte AWS **sandbox** individuel, CLI v2 configurée, région **eu-west-3**.
- `PREFIX` exporté (votre trigramme) — toutes vos ressources le portent.
- Python 3.12, `zip`, `curl`, `jq` (facultatif mais confortable).

### Vérification de l'environnement

```bash
export PREFIX=abc          # ← votre trigramme
aws sts get-caller-identity --query Account --output text   # votre compte sandbox
aws configure get region                                    # doit répondre eu-west-3
python3 --version                                           # 3.12.x
```

## Architecture cible

```text
                       Internet (revendeurs marketplace)
                                    |
                                    v
                    API Gateway — HTTP API  ${PREFIX}-tp3-api
                    (CORS, routes, stage $default auto-deploy)
                    |               |                |
        GET/POST /produits    POST /mouvements   GET /stocks/{ref}
        GET /produits/{ref}   GET /mouvements/{ref}
        GET /sante                  |                |
                    |               |                |
                    v               v                v
              +-----------+  +-------------+  +-----------+
              | Lambda    |  | Lambda      |  | Lambda    |
              | produits  |  | mouvements  |  | stocks    |
              +-----------+  +-------------+  +-----------+
                    |               |                |
              rôle IAM n°1    rôle IAM n°2     rôle IAM n°3
              (R/W table)     (R/W table)      (LECTURE SEULE)
                    |               |                |
                    +---------------+----------------+
                                    |
                                    v
                    DynamoDB  ${PREFIX}-tp3-stockline
                    (table unique, à la demande, pk + sk)
                                    |
                    CloudWatch Logs : un log group par fonction

  0 serveur ; 0 € au repos ; l'échelle est gérée par AWS.
```

💰 **Coût** : ~0 €. DynamoDB à la demande, Lambda (1 M requêtes/mois offertes)
et HTTP API (1 M requêtes/mois la première année) sont dans le free-tier au
volume de ce TP. Aucune ressource « qui tourne » : rien ne facture au repos.
Le teardown du soir reste **obligatoire et noté**.

## Étapes

### Étape 1 — Conception de la table (45 min) — *jalon « GO conception »*

Objectif : une table DynamoDB **unique** qui répond à toutes les requêtes de
l'API **sans jamais faire de Scan**.

1. Sur papier ou en Markdown (`CONCEPTION.md`), listez les **patterns d'accès**
   de l'API : lister les produits ; lire un produit ; créer un produit ;
   enregistrer un mouvement ; lister les mouvements d'un produit ; calculer le
   stock d'un produit.
2. Proposez le schéma de clés (`pk`, `sk`) : quels items, quelles valeurs de
   clés, quel pattern d'accès chaque choix sert-il ? Précisez **pourquoi
   l'historique d'un produit sort trié chronologiquement** avec votre choix
   de `sk`.
3. Faites valider votre conception par le formateur **avant** de créer quoi
   que ce soit (comme au TP2 : pas une ressource avant le GO).
4. Créez la table (mode **à la demande** — justifiez ce choix face au scénario
   « pics imprévisibles ») :

   ```bash
   aws dynamodb create-table \
     --table-name "${PREFIX}-tp3-stockline" \
     --attribute-definitions AttributeName=pk,AttributeType=S AttributeName=sk,AttributeType=S \
     --key-schema AttributeName=pk,KeyType=HASH AttributeName=sk,KeyType=RANGE \
     --billing-mode PAY_PER_REQUEST \
     --tags Key=Projet,Value=stockline-tp3 Key=Proprietaire,Value=$PREFIX
   ```

Point de contrôle : `aws dynamodb describe-table --table-name
"${PREFIX}-tp3-stockline" --query 'Table.TableStatus'` répond `ACTIVE`, et
votre `CONCEPTION.md` porte le visa du formateur.

### Étape 2 — Première fonction : `produits` (1 h 15) — *jalon de fin de matinée*

Objectif : la fonction `${PREFIX}-tp3-produits` répond en direct (invocation
CLI) **avant** toute considération d'API Gateway.

1. Écrivez `lambda_produits.py` (handler `handler`) : routes `GET /sante`,
   `GET /produits`, `POST /produits`, `GET /produits/{reference}` — événement
   HTTP API **payload 2.0** (`routeKey`, `pathParameters`, `body`). Le nom de
   la table arrive par la variable d'environnement `TABLE_NAME`. Validez les
   entrées (champs requis, prix positif) et pensez au piège `Decimal` :
   DynamoDB **refuse les float** en écriture et **renvoie des Decimal** en
   lecture.
2. Créez le rôle `${PREFIX}-tp3-produits-role` : trust policy `lambda.amazonaws.com`,
   politique inline limitée à **ses logs** (`/aws/lambda/${PREFIX}-tp3-produits*`)
   et à **cette table** (`GetItem`, `PutItem`, `Query` — rien d'autre, pas de `*`).
3. Créez la fonction : runtime `python3.12`, architecture `arm64`, 256 Mo,
   timeout 10 s, `--environment "Variables={TABLE_NAME=${PREFIX}-tp3-stockline}"`.
4. Testez **sans API Gateway**, avec un événement simulé :

   ```bash
   aws lambda invoke --function-name "${PREFIX}-tp3-produits" \
     --cli-binary-format raw-in-base64-out \
     --payload '{"routeKey":"GET /sante"}' /tmp/sortie.json && cat /tmp/sortie.json
   ```

Point de contrôle (fin de matinée, montré au formateur) : l'invocation CLI
ci-dessus renvoie `statusCode: 200`, et un POST simulé
(`{"routeKey":"POST /produits","body":"{\"reference\":\"TEST-1\",\"nom\":\"Test\",\"prix_unitaire\":9.90}"}`)
crée réellement l'item dans la table (`aws dynamodb get-item` le prouve).

### Étape 3 — Les deux autres fonctions (1 h 15)

Objectif : `mouvements` et `stocks` opérationnelles, chacune avec **son** rôle.

1. `lambda_mouvements.py` : `POST /mouvements` (valide type
   `entree`/`sortie`, quantité > 0, **refuse un mouvement sur un produit
   inexistant** → 404) et `GET /mouvements/{reference}` (historique trié).
   Rôle n°2 : logs de SA fonction + `GetItem`/`PutItem`/`Query` sur la table.
2. `lambda_stocks.py` : `GET /stocks/{reference}` — stock **calculé** (somme
   des entrées − somme des sorties, par `Query` sur la partition des
   mouvements, avec pagination `LastEvaluatedKey`), champ `alerte` si le stock
   passe sous `seuil_alerte`.
   Rôle n°3 : cette fonction ne fait que lire → **aucun `PutItem`** dans sa
   politique. Sauriez-vous expliquer ce que cette restriction apporte le jour
   où ce code est compromis ?
3. Testez chacune par `aws lambda invoke` avec des événements simulés, comme à
   l'étape 2.

Point de contrôle : séquence CLI complète — POST produit → POST mouvement
entrée ×10 → POST mouvement sortie ×3 → GET stock répond `quantite: 7`.
Et la preuve du moindre privilège : un `PutItem` tenté avec le rôle `stocks`
(dans le code, temporairement) échoue en `AccessDeniedException`.

### Étape 4 — API Gateway (45 min)

Objectif : une seule HTTP API expose les 7 routes, chaque route vers la bonne
fonction.

1. Créez l'HTTP API `${PREFIX}-tp3-api` avec la configuration CORS
   (`AllowOrigins=*`, `AllowMethods=GET,POST,OPTIONS`, `AllowHeaders=content-type`).
2. Créez **3 intégrations** `AWS_PROXY` (une par fonction, payload **2.0**).
3. Créez les 7 routes et rattachez chacune à la bonne intégration :
   `GET /sante`, `GET /produits`, `POST /produits`, `GET /produits/{reference}`
   → produits ; `POST /mouvements`, `GET /mouvements/{reference}` → mouvements ;
   `GET /stocks/{reference}` → stocks.
4. Créez le stage `$default` en auto-deploy.
5. N'oubliez pas la **resource-based policy** : chaque fonction doit autoriser
   API Gateway à l'invoquer (`aws lambda add-permission … --principal
   apigateway.amazonaws.com --source-arn arn:aws:execute-api:…:${API_ID}/*/*`).
   Sans elle : **500/403 côté API, aucune trace côté Lambda** — c'est LE piège
   classique.

Point de contrôle : `curl https://${API_ID}.execute-api.eu-west-3.amazonaws.com/sante`
renvoie 200 depuis votre poste, et chaque famille de routes répond.

### Étape 5 — Campagne de tests + logs (45 min)

Objectif : prouver le fonctionnement de bout en bout et savoir lire les logs.

1. Écrivez (ou déroulez et capturez) la campagne curl complète — chaque appel
   avec son code HTTP attendu :

   ```bash
   URL="https://${API_ID}.execute-api.eu-west-3.amazonaws.com"
   curl -s -o /dev/null -w '%{http_code}\n' "$URL/sante"                    # 200
   curl -s "$URL/produits" | jq                                            # 200, liste
   curl -s -w '\n%{http_code}\n' -X POST "$URL/produits" \
     -H 'Content-Type: application/json' \
     -d '{"reference":"ECR-27","nom":"Écran 27 pouces","prix_unitaire":229.00,"seuil_alerte":2}'   # 201
   curl -s -w '\n%{http_code}\n' -X POST "$URL/produits" \
     -H 'Content-Type: application/json' -d '{"nom":"incomplet"}'          # 400
   curl -s -w '\n%{http_code}\n' -X POST "$URL/mouvements" \
     -H 'Content-Type: application/json' \
     -d '{"reference":"ECR-27","type":"entree","quantite":10}'             # 201
   curl -s -w '\n%{http_code}\n' -X POST "$URL/mouvements" \
     -H 'Content-Type: application/json' \
     -d '{"reference":"FANTOME","type":"entree","quantite":1}'             # 404
   curl -s "$URL/mouvements/ECR-27" | jq                                   # 200, historique
   curl -s "$URL/stocks/ECR-27" | jq                                       # 200, quantite 10
   curl -s -w '\n%{http_code}\n' "$URL/stocks/FANTOME"                     # 404
   ```

2. Provoquez une **erreur volontaire** (POST avec un corps JSON invalide) puis
   retrouvez-la dans les logs :

   ```bash
   aws logs tail "/aws/lambda/${PREFIX}-tp3-produits" --since 15m --follow
   ```

3. Capturez dans votre doc : la campagne complète (commandes + codes obtenus)
   et un extrait de log montrant un `request_id`.

Point de contrôle : tous les codes obtenus = codes attendus (dont les 400/404) ;
vous savez montrer au formateur la ligne de log d'une requête précise.

### Étape 6 — Teardown scripté + documentation (45 min)

Objectif : tout détruire, prouver qu'il ne reste rien, livrer une doc utilisable.

1. Écrivez `teardown.sh` : suppression **dans l'ordre inverse** (API → fonctions
   → table → rôles — politiques inline d'abord — → log groups), chaque étape
   tolérante à l'absence, **vérification finale** qui liste ce qui porterait
   encore `${PREFIX}-tp3`.
2. Rédigez `EXPLOITATION.md` (une page) : URL de l'API, comment redéployer une
   fonction, comment lire les logs, coût au repos/en pic, limites assumées.
3. **Ne lancez le teardown qu'après validation du formateur** (il constate
   l'API vivante, puis contresigne la vérification vide).

Point de contrôle : la vérification finale du teardown ne liste **rien** ;
le formateur contresigne.

## Livrables (dépôt individuel, avant 17 h)

| # | Livrable | Forme |
|---|---|---|
| 1 | `CONCEPTION.md` — schéma de table justifié (patterns d'accès → clés) | Markdown, visa formateur |
| 2 | `lambda_produits.py`, `lambda_mouvements.py`, `lambda_stocks.py` | Python 3.12 |
| 3 | Politiques IAM (3 fichiers JSON) + trust policy | JSON |
| 4 | Scripts ou historique des commandes de déploiement | bash |
| 5 | Campagne de tests (commandes + codes HTTP obtenus) + extrait de logs | Markdown ou capture |
| 6 | `teardown.sh` + sortie de la vérification finale vide | bash + capture |
| 7 | `EXPLOITATION.md` | Markdown, 1 page |

## Barème (détail dans `grille-evaluation.md`)

| Critère | Points |
|---|---|
| Conception de la table (patterns d'accès, clés justifiées, pas de Scan) | /3 |
| Les 3 fonctions (correction, validation des entrées, codes HTTP, qualité) | /6 |
| API Gateway (routes → bonnes fonctions, stage, CORS, permissions d'invocation) | /3 |
| IAM au moindre privilège (3 rôles distincts, ressources ciblées, stocks sans écriture) | /4 |
| Tests + logs (campagne complète avec cas d'erreur, lecture de logs démontrée) | /2 |
| Teardown + documentation | /2 |
| **Total** | **/20** |

## Dépannage courant

<details>
<summary>L'API renvoie 500 (ou « Internal Server Error ») mais AUCUNE trace n'apparaît dans les logs Lambda</summary>

Cause : API Gateway n'a pas le droit d'invoquer la fonction — la
resource-based policy (`lambda add-permission`) manque ou son `--source-arn`
ne correspond pas à l'API. La requête n'atteint jamais la fonction, donc rien
dans ses logs.
Solution : `aws lambda get-policy --function-name <fn>` pour vérifier ;
ajoutez la permission avec le bon `--source-arn
arn:aws:execute-api:eu-west-3:<compte>:<API_ID>/*/*`.

</details>

<details>
<summary>Le navigateur (ou un front) échoue avec une erreur CORS, alors que curl fonctionne</summary>

Cause : curl ne fait pas de contrôle CORS, le navigateur si. La configuration
CORS de l'HTTP API est absente ou incomplète (méthode POST ou en-tête
`content-type` non autorisés), ou vous répondez vous-même aux OPTIONS sans les
bons en-têtes.
Solution : portez le CORS **au niveau de l'API** (`--cors-configuration
AllowOrigins="*",AllowMethods="GET,POST,OPTIONS",AllowHeaders="content-type"`) ;
vérifiez avec `curl -i -X OPTIONS "$URL/produits" -H 'Origin: http://test'
-H 'Access-Control-Request-Method: POST'` → les en-têtes `access-control-*`
doivent apparaître.

</details>

<details>
<summary>Toutes les routes renvoient 404 « Route inconnue » alors que les routes existent dans API Gateway</summary>

Cause : mismatch de **payload format**. En 1.0, l'événement n'a pas de
`routeKey` au même format ; votre routeur ne reconnaît rien. Ou bien la route
API Gateway est `GET /produits/{reference}` mais votre code compare à
`GET /produits/{ref}` : le `routeKey` reprend **exactement** le nom du
paramètre déclaré.
Solution : intégration en `--payload-format-version "2.0"` ; loggez
`event["routeKey"]` en début de handler et comparez à la lettre près.

</details>

<details>
<summary>« Float types are not supported. Use Decimal types instead. »</summary>

Cause : vous passez un float Python (`59.90`) à `put_item` — boto3 refuse.
Solution : `Decimal(str(valeur))` à l'écriture (via `str` pour éviter
l'imprécision binaire) ; à la lecture, un `json.JSONEncoder` qui convertit les
`Decimal` (voir vos notes de CL-AWS2 J2).

</details>

<details>
<summary>« AccessDeniedException … is not authorized to perform: dynamodb:Query »</summary>

Cause : c'est votre moindre privilège qui travaille — l'action ou la ressource
manque dans la politique du rôle de CETTE fonction (chaque fonction a le sien).
Solution : identifiez la fonction fautive (le message cite le rôle), ajoutez
**uniquement** l'action nécessaire sur **l'ARN de la table**. Si c'est la
fonction `stocks` qui tente un `PutItem` : le problème est dans le code, pas
dans la politique.

</details>

<details>
<summary>La fonction vient d'être créée et la création échoue : « The role defined for the function cannot be assumed by Lambda »</summary>

Cause : propagation IAM — le rôle vient d'être créé, le service Lambda ne le
voit pas encore.
Solution : attendez 10-15 s et relancez la création. (C'est pour cela que les
scripts sérieux mettent un `sleep` après `create-role`.)

</details>

<details>
<summary>`aws logs tail` répond « The specified log group does not exist »</summary>

Cause : le log group n'est créé qu'à la **première invocation** de la
fonction — ou la fonction n'a pas le droit `logs:CreateLogGroup` dans son rôle
(elle s'exécute alors, mais en silence).
Solution : invoquez la fonction une fois, puis réessayez. Si toujours rien
après invocation : vérifiez la politique du rôle (les 3 actions `logs:*` sur
`/aws/lambda/<fonction>*`).

</details>

## Bonus (seulement si tout est validé, teardown compris)

1. **Throttling API Gateway** : limitez le stage à 10 req/s / burst 5
   (`aws apigatewayv2 update-stage … --default-route-settings
   ThrottlingRateLimit=10,ThrottlingBurstLimit=5`), prouvez le 429 avec une
   boucle curl. Reliez ça au scénario : que protège-t-on, et de quoi ?
2. **Alarme budget** : un budget AWS de 5 $ avec alerte à 80 % (`aws budgets
   create-budget`) — l'outil que Negoce+ exigera avant la mise en production.
3. **GSI de recherche** : un index `nom → reference` pour chercher un produit
   par nom sans Scan ; expliquez le coût d'un GSI en mode à la demande.

## Pour aller plus loin

Demain, la **même API** sur Azure — App Service ou Functions, à vous de
choisir — puis le comparatif que la direction attend. Gardez précieusement vos
mesures d'aujourd'hui (latences, comportement à froid, ressentis) : elles
alimenteront votre recommandation.
