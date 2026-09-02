# Exercice Kubernetes #6 - Réalisation d'un déploiement de serveurs webs multiples

## Sujet 

Réaliser, via minikube ainsi l'approche déclarative de K8s, un déploiement via un pod d'un conteneur de type NGINX dont la page d'accueil devra retourner l'adresse IP privée du serveur sur lequel elle tourne. 

* Créer ou trouver une image répondant aux besoins métiers
* La rendre disponible pour notre cluster 
* Créer un cluster
* Se connecter au cluster
* Créer les fichiers de manifeste
  * Créer le fichier de déploiement
  * Créer le fichier de service exposé au monde extérieur
* Tester le déploiement vis un tunnel dans minikube