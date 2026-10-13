## COMMANDES AZURE CLI - Bases

# Voir la version d'Azure CLI
az version

# Se connecter via le navigateur et un code de vérification
az login \
    --use-device-code

# Enregistrer un provider, par exemple le provider Web
az provider register \
    --namespace Microsoft.Web

# Vérifier l'état d'un provider
az provider show \
    --namespace Microsoft.Web \
    --query registrationState \
    --output tsv

# Lister les groupes de ressources au format tableau
az group list \
    --output table 

# Lister les ressources d'un groupe de ressources
az resource list \
    --resource-group "rg-formateur-cloud" \
    --output table

# Supprimer un groupe de ressources
az group delete \
    --name "rg-formateur-cloud" \
    --yes \
    --no-wait
