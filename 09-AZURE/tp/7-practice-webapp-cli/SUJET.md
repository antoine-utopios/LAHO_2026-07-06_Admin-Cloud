# Exercice 07 - Utilisation de la CLI Azure dans le but de déployer une WebApp avec slots

## Objectifs 

- Appréhender l'usage d'Azure CLI dans le but de réaliser le déploiement d'un applicatif via une WebApp
- Appréhender le passage et le déploiement d'une nouvelle version de l'applicatif par utilisation de slots
- Appréhender le retour en arrière via un rollback (nouveau swap des slots) 

## Sujet 

Réaliser, par l'utilisation de la CLI Azure, le déploiement de deux version d'un [applicatif fourni](./app-nodejs.zip)

Pour cela, vous utiliserez un AppService Plan de type S1 (Standard) de sorte à avoir accès à la fonctionnalité des slots

Dans l'ordre, vous devrez:

* Réaliser la création du groupe de ressources (si non existant) 
* Réaliser la création d'un AppService Plan avec le plan de tarification (sku) S1
* Réaliser la création d'une WebApp dans l'AppService Plan créé précédemment

Arrivé à ce stade, il devrait être possible de voir la page d'accueil de l'application via un curl sur son adresse (`"https://$APP.azurewebsites.net"`). Si la page d'accueil n'apparaît pas de suite, il faudra attendre un peu et recommencer (maximum 5min)

Une fois fait, il est temps de déployer notre applicatif en ligne. Pour cela: 
* Changer la configuration de la WebApp dans les variables d'environnement (`GREETING` et `APP_VERSION`)
* Publier le code source de l'application dans l'App Service (archive `app-nodejs.zip`)
* Pour des raisons de surété, redémarrer ensuite la WebApp

Il est ensuite possible de vérifier que le déploiement a bien été effectué via un nouveau curl à l'adresse précédente (`"https://$APP.azurewebsites.net"`). Si la réponse en JSON n'est pas encore retournée, il faudra attendre un peu et recommencer (maximum 5min)

On passe ensuite à l'ajout d'une configuration alternative, une pseudo "nouvelle version" de l'applicatif: 
* Créer un nouveau slot pour la WebApp
* Mettre d'autres variables d'environnement dans le slot
* Publier le code source de l'application dans le nouveau slot

Vérifier ensuite que le déploiement a bien été effectué via un nouveau curl à l'adresse précédente (`"https://$APP-$NOM_SLOT.azurewebsites.net"`). Si la réponse en JSON n'est pas encore retournée, il faudra attendre un peu et recommencer (maximum 5min)
* Il ne reste plus qu'a passer la version 2 en production via un swap.
* Pour tester le rollback, refaire ensuite un swap dans l'autre sens.

Afin de fixer aux slots les messages retournés par les applicatifs, réaliser des slots settings pour la variable d'environnement `GREETING` afin que le message reste lié au slot et ne suive pas le swap.
* Vérifier ensuite le comportement voulu en réalisant un swap et des curls