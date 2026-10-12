# Exercice 06 - Utilisation des slots dans Azure App Service

## Objectifs 

Appréhender le passage d'une version à l'autre d'un applicatif dans un App Service Azure

## Sujet 

Réaliser le déploiement de deux version d'un [applicatif](./app-nodejs.zip)

Pour cela, vous utiliserez un AppService Plan de type S1 (Standard) de sorte à avoir accès à la fonctionnalité des slots

* Réaliser la création du groupe de ressources (si non existant) 
* Réaliser la création d'un AppService Plan de SKU S1
* Réaliser la création d'un application WebApp dans l'AppService Plan créé précédemment
* Changer sa configuration dans les variables d'environnement (`GREETING` et `APP_VERSION`)
* Publier le code source de l'application dans l'App Service via le Centre de déploiement
* Créer un nouveau slot dans l'interface Azure Portail
* Mettre d'autres variables d'environnement dans le slot que vous venez de créer
* Publier le code source de l'application dans le nouveau slot
* Vérifier via les noms de domaines que les déploiements sont bien effectifs
* Pour passer d'une version à l'autre de l'applicatif, réaliser des swaps dans l'interface des déploiements sur Azure Portail