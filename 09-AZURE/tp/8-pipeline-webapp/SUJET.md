# Exercice 08 - Pipeline GitLab CI : déploiement continu d'une WebApp avec slots

## Objectifs

- Appréhender l'intégration d'Azure CLI dans un pipeline GitLab CI
- Authentifier un pipeline auprès d'Azure avec un service principal (principe du moindre privilège)
- Automatiser le déploiement d'un applicatif dans le slot `staging` d'une WebApp
- Mettre en place un smoke test bloquant et une mise en production par swap avec validation manuelle
- Appréhender le rollback d'un déploiement via un nouveau swap

## Prérequis

- L'exercice 07 est terminé : vous disposez d'un groupe de ressources, d'un App Service Plan **S1**, d'une WebApp et d'un slot `staging`
- Un projet GitLab (gitlab.com ou instance de la formation) contenant le code de l'applicatif (archive `app-nodejs.zip` décompressée dans un dossier `app/`)
- Azure CLI installée et connectée (`az login`)

> Attention : le plan S1 est facturé à l'heure tant que le groupe de ressources existe. Pensez au nettoyage en fin d'exercice.

## Sujet

Vous devez écrire un fichier `.gitlab-ci.yml` qui, à chaque push sur la branche par défaut :

1. construit une archive zip de l'applicatif ;
2. la déploie dans le slot `staging` de la WebApp ;
3. vérifie que l'application répond sur son endpoint `/health` ;
4. après validation manuelle, bascule la nouvelle version en production par un swap.

### Partie 1 - Préparer l'accès à Azure

Un pipeline ne peut pas utiliser votre compte personnel : il lui faut une identité dédiée.

* Créer un **service principal** avec le rôle `Contributor`, limité **au seul groupe de ressources** de l'exercice (et non à tout l'abonnement)
* Noter les trois valeurs renvoyées (`appId`, `password`, `tenant`) : le mot de passe n'est affiché qu'une seule fois
* Récupérer l'identifiant de votre abonnement

Dans GitLab (**Settings -> CI/CD -> Variables**), créer les variables suivantes :

| Variable | Contenu |
|---|---|
| `AZURE_CLIENT_ID` | `appId` du service principal |
| `AZURE_CLIENT_SECRET` | `password` du service principal |
| `AZURE_TENANT_ID` | `tenant` du service principal |
| `AZURE_SUBSCRIPTION_ID` | identifiant de l'abonnement |
| `AZURE_RESOURCE_GROUP` | nom du groupe de ressources |
| `AZURE_WEBAPP_NAME` | nom de la WebApp (sans `.azurewebsites.net`) |

Questions :
* Pourquoi marquer `AZURE_CLIENT_SECRET` comme *Masked* ? Et toutes les variables comme *Protected* ?
* Que se passe-t-il pour une variable *Protected* sur une branche qui n'est pas protégée ?

> Astuce : si vous travaillez depuis Git Bash sous Windows, les arguments commençant par `/` sont convertis en chemins Windows. Préfixez la commande par `MSYS_NO_PATHCONV=1` ou travaillez depuis la WSL.

### Partie 2 - Le job de build

Écrire un job `build` (stage `build`) qui :

* utilise une image Node.js **alignée sur le runtime de la WebApp** (Node 20) ;
* installe les dépendances de production uniquement ;
* produit l'archive `app.zip` et la transmet aux jobs suivants (artifacts).

Questions :
* Pourquoi limiter la durée de vie de l'artifact ?
* Que se passerait-il si l'image de build utilisait une version de Node différente de celle de la WebApp ?

### Partie 3 - Le déploiement dans le slot staging

Écrire un job `deploy_staging` (stage `staging`) qui :

* utilise l'image officielle `mcr.microsoft.com/azure-cli` (attention à l'`entrypoint`) ;
* se connecte à Azure avec le service principal, puis sélectionne l'abonnement ;
* déploie `app.zip` dans le slot `staging` ;
* ne s'exécute que sur la branche par défaut ;
* déclare un `environment` nommé `staging` avec l'URL du slot.

Questions :
* À quoi sert la déclaration d'un `environment` dans GitLab ?
* Pourquoi faut-il se déconnecter (`az logout`) en fin de job ? Dans quelle section le placer ?

### Partie 4 - Le smoke test

Écrire un job `smoke_test_staging` qui :

* interroge l'URL `/health` du slot staging et **échoue** si la réponse n'est pas un succès ;
* tolère un démarrage à froid (plusieurs tentatives espacées dans le temps) ;
* utilise une image légère embarquant `curl` (ne pas supposer que l'image `azure-cli` en dispose).

Questions :
* Pourquoi ce test est-il un job séparé du déploiement ?
* Quelle option de `curl` fait échouer la commande sur un code HTTP d'erreur ?

### Partie 5 - Le swap vers la production

Écrire un job `swap_to_production` (stage `production`) qui :

* ne démarre que si le smoke test a réussi ;
* nécessite une **validation manuelle** (bouton *Play* dans GitLab) ;
* réalise le swap du slot `staging` vers `production` ;
* déclare un `environment` nommé `production`.

### Partie 6 - Factoriser

Les jobs `deploy_staging` et `swap_to_production` répètent la même connexion à Azure.

* Factoriser l'image et les sections `before_script` / `after_script` dans un **template caché** (job dont le nom commence par un point), réutilisé avec `extends`.

### Partie 7 - Exécution, vérification et rollback

* Pousser le fichier `.gitlab-ci.yml` sur la branche par défaut et suivre l'exécution du pipeline
* Vérifier avec `curl` que le slot `staging` répond avec la nouvelle version, et que la production répond encore avec l'ancienne
* Déclencher le job manuel de swap, puis vérifier que la production répond avec la nouvelle version
* **Rollback** : relancer le swap (depuis GitLab ou en CLI) et vérifier le retour à la version précédente

Questions :
* Pourquoi le rollback est-il quasi instantané ?
* Dans quels cas un swap peut-il échouer ?

## Pour aller plus loin (bonus)

* Définir `GREETING` comme **slot setting** pour qu'il ne suive pas le swap, et vérifier le comportement après un swap
* Ajouter une règle empêchant le déploiement sur les merge requests
* Remplacer le secret par une authentification **OIDC** (`id_token` GitLab + *federated credential* Entra ID), afin de ne plus stocker aucun secret dans GitLab

## Nettoyage

```bash
az group delete --name <resource-group> --yes --no-wait
az ad sp delete --id <appId>
az group list --output table
```

Pensez également à supprimer les variables GitLab devenues inutiles.

## Critères de réussite

- [ ] Le pipeline s'exécute sans erreur sur la branche par défaut
- [ ] Aucun secret n'apparaît dans le fichier `.gitlab-ci.yml` ni dans les logs
- [ ] Le service principal est limité au groupe de ressources
- [ ] Le swap n'est possible qu'après un smoke test réussi et une validation manuelle
- [ ] Le rollback a été testé
- [ ] Les ressources Azure ont été supprimées en fin d'exercice