# Exercice 3 - Utilisation des modules

## Objectifs

Appréhender l'utilisation des modules dans Terraform

## Sujet

Réaliser deux modules permettant la mise en place: 
- D'un site web avec injection d'un préfixe de nom de conteneur, d'un sufixe de nom de conteneur, d'un port externe et d'un nom d'image Docker
- D'une base de données MySQL avec injection d'un préfixe de nom de conteneur, d'un sufixe de nom de conteneur, d'un port externe, d'un nom d'image Docker et des variables d'environnement (`MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `MYSQL_USER`, `MYSQL_DATABASE`)

Dans un projet Terraform, vous allez réaliser, via l'utilisation des modules, créer plusieurs ressources:
- Trois conteneurs de type serveur web
- Deux conteneurs de base de données

L'infrastructure devra utiliser le moins de répétitions possibles et faire usage de variables pour la rendre dynamique et permettre facilement une version production et une version développement via deux fichiers de variables spéficiques (type `prod.local.tfvars` et `dev.local.tfvars` qui ne seront pas commités)