## COMMANDES AZURE CLI - WebApp

# Créer un AppService Plan manuellement, avec la tarification F1 (free) ou S1 (Standard, permet les slots)
az appservice plan create \
    --name "asp-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --sku F1 \
    --is-linux

# Création de la Web App, avec un Runtime Node.js 24 LTS
az webapp create \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --plan "asp-formateur-cloud" \
    --runtime "NODE:24-lts"

# Créer un slot pour l'application
az webapp deployment slot create \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --slot staging

# Vérification de l'état de l'application
az webapp show \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --query state \
    --output tsv

# Lister les slots d'une WebApp
az webapp deployment slot list \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Déployer une application via une archive
az webapp deploy \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --src-path app.zip \
  --type zip

# Déployer une application via une archive (slot)
az webapp deploy \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --src-path app.zip \
  --slot staging \
  --type zip

# Redémarrer une Application
az webapp restart \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Redémarrer une Application (slot spécifique)
az webapp restart \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --slot staging

# Réaliser un Swap des slots (staging vers production)
az webapp deployment slot swap \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --slot staging \
  --target-slot production

# Configuration de l'App Service
az webapp config appsettings set \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --settings VAR_A="value" VAR_B="value" ...

# Configuration de l'App Service (slot spécifique)
az webapp config appsettings set \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --slot staging \
  --settings VAR_A="value" VAR_B="value" ...

# Configuration de l'application (slot settings, reste figé dans le slot, ne suivra pas un swap)
az webapp config appsettings set \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --slot staging \
  --slot-settings VAR_A="value"

# Lister les paramètres enregistrés
az webapp config appsettings list \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Lister les paramètres enregistrés pour un slot particulier
az webapp config appsettings list \
    --name "app-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --slot staging \
    --output table

# Lire les logs de l'application 
az webapp log config \
  --name "app-formateur-cloud" \
  --resource-group "rg-formateur-cloud" \
  --application-logging filesystem \
  --level information

# Vérification du déploiement
curl "https://app-formateur-cloud.azurewebsites.net"

# Vérification des ressources liées
az resource list \
    --resource-group "rg-formateur-cloud" \
    --output table