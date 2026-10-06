# Démo AWS Lambda — Gestion de commandes 100 % serverless

## Objectif du projet

Sur un cas concret, **comment construire une application complète sans aucun serveur** avec
AWS Lambda, et **comment l'exploiter** une fois en ligne.

L'application gère des **commandes clients** :
- on crée et on consulte des commandes depuis une **page web** ou une **API** ;
- on importe des commandes en masse en **déposant un fichier CSV** dans un bucket S3 ;
- un **rapport** (nombre de commandes, chiffre d'affaires, top 3 des produits) est produit
  **automatiquement toutes les 5 minutes**.

Chacune de ces trois fonctionnalités est une **fonction Lambda** déclenchée d'une manière différente.
C'est le cœur de la démo : **Lambda ne s'exécute que lorsqu'un événement arrive**.

| Fonctionnalité | Événement déclencheur | Service AWS | Fonction Lambda |
|---|---|---|---|
| Page web et API | une **requête HTTP** | API Gateway | `commandes-api` |
| Import en masse | le **dépôt d'un fichier** | Amazon S3 | `commandes-import` |
| Rapport périodique | l'**horloge** (toutes les 5 min) | Amazon EventBridge | `commandes-rapport` |

Les commandes sont stockées dans **DynamoDB**, les fichiers et les rapports dans **S3**, les journaux
dans **CloudWatch**.

## Déroulé (≈ 1 h 30)

| Partie | Où | Contenu |
|---|---|---|
| 1 — Construction | **Console AWS** | table DynamoDB, bucket S3, 3 fonctions, leurs rôles IAM, les 3 déclencheurs |
| 2 — Exploitation | **Terminal (AWS CLI)** | appels d'API, logs en direct, versions et alias, canary, retour arrière, concurrence |
| 3 — Nettoyage | CLI + console | suppression de toutes les ressources |


## Prérequis

- Un compte AWS et un accès à la console, région **eu-west-3 (Paris)** sélectionnée en haut à droite.
- Pour la partie 2 : **AWS CLI v2** configurée sur le poste (`aws sts get-caller-identity` doit répondre),
  ou **AWS CloudShell** (icône `>_` dans la console), et ce dossier copié sur le poste.
- Connaître son **numéro de compte AWS** (12 chiffres) : menu en haut à droite de la console, ou
  `aws sts get-caller-identity --query Account --output text`.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `fonctions/commandes-api/lambda_function.py` | API HTTP + page web |
| `fonctions/commandes-import/lambda_function.py` | import des fichiers CSV déposés dans S3 |
| `fonctions/commandes-rapport/lambda_function.py` | rapport planifié écrit dans S3 |
| `iam/policy-commandes-*.json` | droits de chaque fonction (à copier dans la console IAM) |
| `donnees/commandes-janvier.csv` | 6 commandes valides à importer |
| `donnees/commandes-erreurs.csv` | 5 lignes dont 3 invalides (montre le rejet des erreurs) |
| `evenements/*.json` | événements de test à coller dans l'onglet **Test** de la console Lambda |
| `architecture-lambda.html` | schéma d'architecture |
