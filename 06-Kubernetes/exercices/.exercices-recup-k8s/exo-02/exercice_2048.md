# Exercice Kubernetes #2 - Réalisation d'un déploiement d'applicatif Java

## Sujet 

Réaliser, via minikube ainsi que l'interface en ligne de commande kubectl, un déploiement de l'application 2048 déservie par un serveur Tomcat (image docker de `quchaonet`)

* Créer un cluster
* Se connecter au cluster
* Déployer un pod de l'application voulue
* Créer un service Kubernetes de type `LoadBalancer` permettant d'exposer le déploiement au monde extérieur
* Créer un tunnel via minikube permettant d'accéder à notre service depuis l'ordinateur hôte