# Exercice Kubernetes #3 - Réalisation d'un déploiement multiple

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement d'un site web personnalisé. Le site web devra posséder idéalement plusieurs pages, un fichier de CSS ainsi qu'une page d'accueil porteuse du titre `Exercice 03 terminé!` mis en valeur via du CSS.

* Créer l'image de notre applicatif
* Héberger notre image dans un registre d'image de conteneur public
* Créer un cluster
* Se connecter au cluster
* Déployer un pod de l'application via son image publique
* Créer un service Kubernetes permettant d'exposer le déploiement au monde extérieur
* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte
* Scaler notre applicatif en une version disposant de 3 réplicats