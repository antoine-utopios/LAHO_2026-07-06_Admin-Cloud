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