# Exercice Kubernetes #3 - Déploiement d'une base de données MySQL

## Objectifs

Appréhender l'utilisation des variables d'environnement dans un environnement cluster K8s

## Sujet 

Réaliser, via kind ou minikube ainsi que l'utilisation de l'approche déclarative, le déploiement d'une base de données de type MySQL dans un cluster perso. 

* Pour cela, faire en sorte que les variables d'environnement demandées par les conteneurs MySQL soient peuplées via les clés env et envFrom dans le fichier de déploiement YAML. 
* Réaliser un service permettant l'accès de la base de données par des APIs potentielles présentes dans le cluster