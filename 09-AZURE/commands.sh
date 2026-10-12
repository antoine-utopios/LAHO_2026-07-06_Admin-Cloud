## Voir la version d'Azure CLI
az version

## Se connecter via le navigateur et un code de vérification
az login --use-device-code

## Lister les groupes de ressources au format tableau
az group list --output table 

## Créer un AppService Plan manuellement, avec la tarification voulue
az appservice plan create --name "asp-formateur-s1" --resource-group "rg-formateur-cloud" --sku S1 --is-linux

## Création de l'application
az webapp create --name "app-formateur-001" --resource-group "rg-formateur-cloud" --plan "asp-formateur-s1" --runtime "NODE:24-lts"