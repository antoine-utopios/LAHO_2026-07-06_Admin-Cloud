# Initialiser le contexte Terraform
terraform init

# Mettre à jour la syntaxe
terraform fmt

# Vérifier les fichier Terraform
terraform validate

# Voir ce qui va être modifié / appliqué
terraform plan

# Précédence des variables
# 1 - Valeurs par défaut
# 2 - Variables d'environnement système: TF_VAR_key=value
# 3 - Fichier 'terraform.tfvars' qui doit se trouver à l'emplacement du projet Terraform
# 4 - Fichier '*.auto.tfvars' qui doivent se trouver à l'emplacement du projet Terraform
# 5 - Option '-var' ou '-var-file' (le fichier peut cette fois-ci se trouver n'importe où)

## Ajout de variables dans la planification
terraform plan -var="key=value"

## Ajout de variables dans la planification (fichier)
terraform plan -var-file="chemin/vers/fichier"

# Appliquer le plan Terraform
terraform apply 

# Retirer ce que Terraform a appliqué
terraform destroy

# Observer l'état Terraform - Listing des adresses
terraform state list

# Observer l'état détaillé d'une entité Terraform
terraform state show <adresse-entite>