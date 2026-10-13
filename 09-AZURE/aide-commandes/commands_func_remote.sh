## --- Déploiement ---

# Création des valeurs communes au projet
export RG="rg-formateur-cloud"
export LOCATION="francecentral"
export STORAGE="stfunc$RANDOM$RANDOM"
export APP="func-lab-$RANDOM"

## Création du compte de stockage
az storage account create \
  --name "$STORAGE" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

# Création du plan de consommation
az functionapp create \
  --name "$APP" \
  --resource-group "$RG" \
  --storage-account "$STORAGE" \
  --flexconsumption-location "$LOCATION" \
  --runtime node \
  --runtime-version 20

# Vérification de la création des ressources
az resource list \
  --resource-group "$RG" \
  --output table

# Déployer le code
cd app && func azure functionapp publish "$APP" && cd ..
az functionapp function list \
  --name "$APP" \
  --resource-group "$RG" \
  --output table

# Récupération de la clé pour la fonction enqueue.js (authentification nécessaire)
KEY=$(az functionapp keys list \
  --name "$APP" \
  --resource-group "$RG" \
  --query functionKeys.default \
  --output tsv)

# Récupération de la chaine de connexion vers le compte de stockage
CONN=$(az storage account show-connection-string \
  --name "$STORAGE" \
  --resource-group "$RG" \
  --query connectionString \
  --output tsv)

## --- Tests des fonctions ---

# Appel HTTP vers la fonction 'hello.json'
curl "https://$APP.azurewebsites.net/api/hello?name=Azure"

# Appels HTTP pour déposer dans la queue orders (Sans authentification, 401)
curl -i -X POST "https://$APP.azurewebsites.net/api/enqueue" -d "order-0001"

# Appels HTTP pour déposer dans la queue orders (Avec authentification, 202)
curl -i -X POST "https://$APP.azurewebsites.net/api/enqueue?code=$KEY" -d "order-1234"

# Envoi d'un message qui va échouer (car contient 'fail')
curl -i -X POST "https://$APP.azurewebsites.net/api/enqueue?code=$KEY" -d "please fail"

# Voir le contenu de la queue des messages traités
az storage message peek \
  --queue-name processed \
  --connection-string "$CONN" \
  --num-messages 5

# Vérifier le fonctionnement de la queue des messages problématiques
az storage message peek \
  --queue-name orders-poison \
  --connection-string "$CONN" \
  --num-messages 5