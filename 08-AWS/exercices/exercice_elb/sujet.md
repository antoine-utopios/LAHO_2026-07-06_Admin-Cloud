# Exercice AWS - AMIs & Application Load Balancer 

## Objectifs 

Appréhender le fonctionnement et l'utilisation d'AMIs, d'un ALB et d'un déploiement via pipeline CI / CD dans AWS

## Sujet

Réaliser en plusieurs étapes un déploiement professionnel d'une application web dans un environnement résistant à la charge (environnement cloud AWS).

1. Commencer par un déploiement sur une seule instance
    * Créer un groupe de sécurité pour notre future instance EC2
    * Réaliser le déploiement sur AWS d'une instance EC2 classique, avec sa propre paire de clé SSH et le groupe de sécurité créé précédemment
    * Se connecter en SSH sur la machine et y installer le nécessaire au déploiement dockerizé (installer docker sur la machine `script-install-docker.sh`)
2. Réaliser un pipeline Gitlab CI dans le but de faire une compilation, un testing, une vérification des vulnérabilités, un packaging et un déploiement dans notre instance EC2 créée en étape 1
    * Créer un dépot Git sur Gitlab et y placer le code source de l'application (dossier `app` présent dans le dossier de l'exercice)
    * Job de compilation: Faire une vérification de la compilation de l'API Node.js via les commandes `npm run build`
    * Job de tests: Réaliser l'ensemble des tests unitaires de l'application et en publier les rapports sous la forme d'artéfacts exploitables par le code reviewer en cas de pull request (`npm test`)
    * Job de vérification des vulnérabilités: Via l'utilisation de Trivy, faire en sorte de tester les vulnérabilités présentes dans les dépendances de notre applicatif (Penser à utiliser l'image docker `aquasec/trivy`)
    * Job de packaging: Compilation et Publication  d'une image de conteneur dans le registre des images de conteneurs disponible dans le dépot sur Gitlab (pensez à utiliser les variables d'environnement telles que `CI_REGISTRY_USER`)
    * Job de déploiement: Faire en sorte, via les variables d'environnement que l'on configurera dans le dépot git (telle que `EC2_PRIVATE_KEY_B64`), de pouvoir se connecter en SSH à la machine virtuelle et d'y lancer le conteneur Docker
3. Faire en sorte de sauvegarder l'état de l'instance pour ensuite le multiplier
    * Réaliser une sauvegarde sous la forme d'une AMI de notre déploiement mono-instance dans le but de pouvoir l'exporter dans une autre zone AWS / le multiplier
4. Créer plusieurs instances d'un seul coup à partir de la sauvegarde AMI
    * Créer des instances, cette fois-ci, via l'AMI et au nombre supérieur ou égal à 2
5. Regrouper l'ensemble des instances dans un groupe cible, de sorte à pouvoir l'atteindre via notre Load Balancer 
    * Créer un groupe de sécurité pour regrouper les instances
    * Cibler les instances en HTTP dans ce même groupe de sécurité
6. Créer un Load Balancer dans le but de cibler le groupe créé précédemment
    * Créer un groupe de sécurité pour le Load Balancer
    * Editer le groupe de sécurité des instances pour ne permettre l'accès qu'au groupe de sécurité du Load Balancer
    * Cibler le groupe cible via le Load Balancer
7. Tester l'accès aux instances via des appels en HTTP sur votre navigateur (le nom de domaine du Load Balancer, en HTTP)
