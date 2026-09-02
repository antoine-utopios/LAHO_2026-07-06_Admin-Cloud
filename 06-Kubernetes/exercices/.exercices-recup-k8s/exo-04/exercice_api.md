# Exercice Kubernetes #4 - Réalisation d'un déploiement mise à jour

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement d'un applicatif personnel. Il pourra s'agir par exemple d'une API réalisée avec Express. Cet applicatif sera mis à jour par la suite de sorte à tester le mécanisme des rollouts de K8s.

* Créer l'image de notre applicatif
* Héberger notre image dans un registre d'image de conteneur public
* Créer un cluster
* Se connecter au cluster
* Déployer un pod de l'application via son image publique
* Créer un service Kubernetes permettant d'exposer le déploiement au monde extérieur
* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte
* Tester le fonctionnement de notre applicatif via un client REST
* Créer une nouvelle version de notre applicatif avec de nouveaux endpoints
* Mettre à jour le déploiement au sein du cluster
* Tester la présence des nouvelles routes dans le client REST