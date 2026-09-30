# TP de vérification des connaissances AWS

## Objectifs 

Appréhender le fonctionnement d'Amazon ECR et de son branchement via un pipeline CI / CD 

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
    * Job de publication sur AWS des sauvegardes
        * Récupération des fichiers provenant des jobs précédents
        * Archivage de l'ensemble des fichiers (dans une archive `.tar` ou `.zip` par exemple)
        * Publier les rapports de tests sur un bucket S3
    * Job de packaging: 
        * Créer un dépot d'image de conteneur sur AWS ECR
        * Utiliser l'image Docker `amazon/aws-cli` (ne pas oublier de changer son point d'entrée de base)
            * Lui fournir des crédentials via une clé compatible avec l'utilisation de la CLI (`ACCESS_KEY_ID` et `SECRET_ACCESS_KEY`)
            * Utiliser les variables d'environnement de la documentation officielle de l'utilisation d'AWS CLI de sorte à pouvoir profiter directement de nos credentials
        * Peupler les variables d'environnement dans le dépot Git de sorte à répondre aux pré-requis du job (ne pas oublier d'ajouter la variable locale de nom de l'image)
3. Réaliser ensuite le déploiement de l'image de conteneur déposée au préalable sur ECR via un cluster ECS ainsi qu'une définition de tâche au nombre de 3 tâches. 

## BONUS - Job de déploiement 

Pour les plus déterminés, réaliser un job final permettant la mise en place directement, via la CLI d'AWS, de l'image de notre application déposée sur ECR dans une définition de tâche ECS. Pour cela, utiliser encore une fois l'image `amazon/aws-cli`.

## Rappels - Commandes à utiliser pour ECR (Bash)

```bash
## Variables à utiliser dans Gitlab CI pour utiliser un runner amawon/cli
# - AWS_DEFAULT_REGION: La région dans laquelle on veut effectuer les actions de l'invité de commande
# - AWS_ACCESS_KEY_ID: L'utilisateur servant à s'authentifier
# - AWS_SECRET_ACCESS_KEY: Le mot de passe servant à s'authentifier
# - AWS_ECR_IMAGE_NAME: Le nom du registre d'image de conteneur créé sur AWS en amont 


export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text )
export AWS_REGISTRY=$ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_REGISTRY

# Si les paramètres permettent la mutabilité, on peut modifier le tag 'latest'
docker build -t $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:latest .
docker push $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:latest

# Si les paramètres ne permettent pas la mutabilité, on doit créer un nouveau tag à chaque fois
docker build -t -t $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:$CI_COMMIT_SHORT_SHA .
docker push $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:$CI_COMMIT_SHORT_SHA
```