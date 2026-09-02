# Exercice Kubernetes #10 - Déploiement d'une application full-stack

Vous êtes chargé de déployer l'intégralité d'une application dans un cluster Kubernetes local. Cette application possède plusieurs couches métier. Ces couches tourneront dans un cluster réalisé avec KinD et séparés du reste de ce dernier via l'utilisation d'un namespace dédié.

Petites précisions concernant les applicatifs: 
* Les API de tâches et de gestion des utilisateurs ont besoin d'une variable d'environnement: `AUTH_ADDRESS`, de sorte à communiquer avec l'API d'authentification et de permettre la vérification des tokens JWT. 
* L'API de gestion des tâches stocke ces dernières dans un fichier, dont l'emplacement est fixé par la variable d'environnement `TASKS_FOLDER`

Pour cela, vous allez créer les ressources Kubernetes fondamentales compatible avec les applicatifs et ressources suivants :
* Instancier un nouveau cluster avec `KinD`
  * Créez un fichier `kind-config.yaml` pour configurer un cluster avec kind
* Réaliser le namespace pour l'application fullstack dans le but de l'isoler du reste des applicatifs futurs
  * Créez un fichier `namespace.yaml` pour séparer l'application du reste du cluster
* Une API d'authentification
  * Créez un fichier `auth-deployment.yaml` pour permettre le déploiement de l'API
  * Créez un fichier `auth-service.yaml` pour accéder à l'API d'authentification depuis l'intérieur du cluster
  * Créez un fichier `auth-access-configmap.yaml` pour peuples les variables d'environnements des futurs autres APIs et leur donner l'endpoint de l'API d'authentification
* Une API de stockage des tâches
* Créez les fichiers `tasks-pv.yaml` et `tasks-pvc.yaml` pour gérer un stockage des tâches futures
* Créez un fichier `tasks-deployment.yaml` pour permettre le déploiement de l'API
* Créez un fichier `tasks-service.yaml` pour accéder à l'API des tâches depuis l'intérieur du cluster
* Une API de stockage des utilisateurs
  * Créez un fichier `users-deployment.yaml` pour permettre le déploiement de l'API
  * Créez un fichier `users-service.yaml` pour accéder à l'API des utilisateurs depuis l'intérieur du cluster
* Un frontend réalisé avec React
  * Créez un fichier `frontend-deployment.yaml` pour permettre le déploiement de l'applicatif React
  * Créez un fichier `frontend-service.yaml` pour accéder à l'application React depuis l'extérieur du cluster

