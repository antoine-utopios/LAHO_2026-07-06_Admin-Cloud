APP="app-formateur-cloud"
ASP="asp-formateur-cloud"
RG="rg-formateur-cloud"

# Réaliser la création du groupe de ressources (si non existant) 
# az group create \
#     --name $RG \
#     --output table

# Réaliser la création d'un AppService Plan avec le plan de tarification (sku) S1
az appservice plan create \
    --name "$ASP" \
    --resource-group "$RG" \
    --sku S1 \
    --is-linux

# Réaliser la création d'une WebApp dans l'AppService Plan créé précédemment
az webapp create \
    --name "$APP" \
    --resource-group "$RG" \
    --plan "$ASP" \
    --runtime "NODE:24-lts"

# Vérifier la page d'accueil de l'application via un curl sur son adresse (`"https://$APP.azurewebsites.net"`). Si la page d'accueil n'apparaît pas de suite, il faudra attendre un peu et recommencer (maximum 5min)
sleep 120
curl "https://$APP.azurewebsites.net"

# Changer la configuration de la WebApp dans les variables d'environnement (`GREETING` et `APP_VERSION`)
az webapp config appsettings set \
  --name "$APP" \
  --resource-group "$RG" \
  --settings GREETING="Production is running..." APP_VERSION="v1"

# Publier le code source de l'application dans l'App Service (archive `app-nodejs.zip`)
az webapp deploy \
  --name "$APP" \
  --resource-group "$RG" \
  --src-path app-nodejs.zip \
  --type zip

# Pour des raisons de surété, redémarrer ensuite la WebApp
az webapp restart \
    --name "$APP" \
    --resource-group "$RG"

# Vérifier que le déploiement a bien été effectué via un nouveau curl à l'adresse précédente (`"https://$APP.azurewebsites.net"`). Si la réponse en JSON n'est pas encore retournée, il faudra attendre un peu et recommencer (maximum 5min)
sleep 120
curl "https://$APP.azurewebsites.net"

# Créer un nouveau slot pour la WebApp
az webapp deployment slot create \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging

# Mettre d'autres variables d'environnement dans le slot
az webapp config appsettings set \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging \
  --settings GREETING="Staging is running..." APP_VERSION="v2"

# Publier le code source de l'application dans le nouveau slot
az webapp deploy \
  --name "$APP" \
  --resource-group "$RG" \
  --src-path app-nodejs.zip \
  --slot staging \
  --type zip

# Vérifier ensuite que le déploiement a bien été effectué via un nouveau curl à l'adresse précédente (`"https://$APP-$NOM_SLOT.azurewebsites.net"`). Si la réponse en JSON n'est pas encore retournée, il faudra attendre un peu et recommencer (maximum 5min)
sleep 120
curl "https://$APP-staging.azurewebsites.net"

# Il ne reste plus qu'a passer la version 2 en production via un swap.
az webapp deployment slot swap \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging \
  --target-slot production

# Pour tester le rollback, refaire ensuite un swap dans l'autre sens.
az webapp deployment slot swap \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging \
  --target-slot production

# Réaliser des slots settings pour la variable d'environnement `GREETING` afin que le message reste lié au slot et ne suive pas le swap.
az webapp config appsettings set \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging \
  --slot-settings GREETING="Staging is running..."

az webapp config appsettings set \
  --name "$APP" \
  --resource-group "$RG" \
  --slot-settings GREETING="Production is running..."

# Vérifier ensuite le comportement voulu en réalisant un swap et des curls
az webapp deployment slot swap \
  --name "$APP" \
  --resource-group "$RG" \
  --slot staging \
  --target-slot production

sleep 120
curl "https://$APP.azurewebsites.net"
curl "https://$APP-staging.azurewebsites.net"