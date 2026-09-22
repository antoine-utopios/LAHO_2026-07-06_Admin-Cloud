# Exercice AWS - AMIs & Application Load Balancer 

## Objectifs 

Appréhender le fonctionnement d'Amazon ECR et de son branchement via un pipeline CI / CD 

## Sujet

Réaliser, via Gitlab CI, un job de packaging permettant de déposer notre image d'applicatif sur AWS ECR.

Pour cela, il faudra: 
* Créer un dépot d'image de conteneur sur AWS ECR
* Utiliser l'image Docker `amazon/aws-cli` (ne pas oublier de changer son point d'entrée de base)
    * Lui fournir des crédentials via une clé compatible avec l'utilisation de la CLI (`ACCESS_KEY_ID` et `SECRET_ACCESS_KEY`)
    * Utiliser les variables d'environnement de la documentation officielle de l'utilisation d'AWS CLI de sorte à pouvoir profiter directement de nos credentials
* Peupler les variables d'environnement dans le dépot Git de sorte à répondre aux pré-requis du job (ne pas oublier d'ajouter la variable locale de nom de l'image)

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