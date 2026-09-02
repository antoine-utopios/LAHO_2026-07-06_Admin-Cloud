# Exercice Kubernetes #9 - Déploiement de Postgres dans un cluster K8s

Vous êtes chargé de déployer une instance **PostgreSQL** dans un cluster Kubernetes local.
L'exigence principale est que les données de la base **survivent au redémarrage ou à la suppression du Pod**.

Pour cela, vous allez utiliser deux ressources Kubernetes fondamentales :

- Un **PersistentVolume (PV)** : représente une unité de stockage physique dans le cluster.
- Un **PersistentVolumeClaim (PVC)** : est la *demande* de stockage faite par un Pod. Il lie le Pod au PV.

* Créez un fichier `kind-config.yaml`
* Créez un fichier `namespace.yaml`
* Créez un fichier `pv.yaml`
* Créez un fichier `pvc.yaml`
* Créez un fichier `secret.yaml`
* Créez un fichier `deployment.yaml`
* Créez un fichier `service.yaml` pour accéder à PostgreSQL depuis l'extérieur du cluster