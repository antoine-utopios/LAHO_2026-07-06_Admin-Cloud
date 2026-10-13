## --- Azure Functions ---

# Enregistrer les providers nécessaires (une seule fois par abonnement)
az provider register \
    --namespace Microsoft.Web

az provider register \
    --namespace Microsoft.Storage

## --- Développement local (Core Tools) ---

# Vérifier la version des Core Tools
func --version

# Initialiser un projet Node.js (modèle de programmation v4)
func init "func-formateur-cloud" \
    --worker-runtime node \
    --language javascript \
    --model V4

# Créer une nouvelle fonction à partir d'un modèle (HTTP trigger, par exemple)
func new \
    --name hello \
    --template "HTTP trigger"

# Lancer l'émulateur de stockage Azurite (nécessaire pour les triggers non HTTP en local)
npx --yes azurite \
    --silent \
    --location ./.azurite \
    --debug ./.azurite/debug.log

# Démarrer le runtime en local (http://localhost:7071)
func start

# Tester une fonction HTTP en local
curl "http://localhost:7071/api/hello?name=Azure"

## --- Création des ressources ---

# Créer un compte de stockage (obligatoire pour une Function App, nom unique, 3 à 24 caractères minuscules et chiffres)
az storage account create \
    --name "stfuncformateur$RANDOM" \
    --resource-group "rg-formateur-cloud" \
    --location "westeurope" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false

# Lister les régions où le plan Flex Consumption est disponible
az functionapp list-flexconsumption-locations \
    --output table

# Lister les runtimes disponibles sur Flex Consumption pour Node.js
az functionapp list-flexconsumption-runtimes \
    --location "westeurope" \
    --runtime node \
    --output table

# Créer une Function App sur le plan Flex Consumption (scale to zero)
az functionapp create \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --storage-account "stfuncformateur12345" \
    --flexconsumption-location "westeurope" \
    --runtime node \
    --runtime-version 20

# Créer une Function App sur le plan Consumption classique (si Flex n'est pas disponible)
az functionapp create \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --storage-account "stfuncformateur12345" \
    --consumption-plan-location "westeurope" \
    --os-type Linux \
    --functions-version 4 \
    --runtime node \
    --runtime-version 20

# Vérifier l'état d'une Function App
az functionapp show \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --query state \
    --output tsv

# Lister les Function Apps d'un groupe de ressources
az functionapp list \
    --resource-group "rg-formateur-cloud" \
    --output table

# Vérifier les ressources créées avec la Function App
az resource list \
    --resource-group "rg-formateur-cloud" \
    --output table

## --- Déploiement ---

# Déployer le code depuis le dossier du projet avec les Core Tools
func azure functionapp publish "func-formateur-cloud"

# Déployer une archive zip
az functionapp deployment source config-zip \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --src app.zip

# Lister les fonctions déployées
az functionapp function list \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Afficher les détails d'une fonction (dont son URL d'invocation)
az functionapp function show \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --function-name hello \
    --query invokeUrlTemplate \
    --output tsv

# Appeler une fonction HTTP anonyme
curl "https://func-formateur-cloud.azurewebsites.net/api/hello?name=Azure"

## --- Clés d'accès ---

# Récupérer la clé par défaut de l'application (clé hôte)
az functionapp keys list \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --query functionKeys.default \
    --output tsv

# Lister les clés d'une fonction précise
az functionapp function keys list \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --function-name enqueue

# Appeler une fonction protégée (authLevel function) avec la clé en paramètre
curl -X POST "https://func-formateur-cloud.azurewebsites.net/api/enqueue?code=<key>" \
    -d "order-1234"

# Appeler une fonction protégée avec la clé en en-tête
curl -X POST "https://func-formateur-cloud.azurewebsites.net/api/enqueue" \
    -H "x-functions-key: <key>" \
    -d "order-1234"

## --- Configuration ---

# Définir des paramètres d'application (variables d'environnement)
az functionapp config appsettings set \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --settings VAR_A="value" VAR_B="value"

# Lister les paramètres d'application
az functionapp config appsettings list \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Supprimer un paramètre d'application
az functionapp config appsettings delete \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --setting-names VAR_A

# Activer l'identité managée système de la Function App
az functionapp identity assign \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Limiter le nombre maximal d'instances (Flex Consumption), utile pour maîtriser les coûts
az functionapp scale config set \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --maximum-instance-count 10

## --- Cycle de vie ---

# Arrêter une Function App (les appels échouent, plus d'exécution)
az functionapp stop \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Démarrer une Function App
az functionapp start \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Redémarrer une Function App
az functionapp restart \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Supprimer uniquement la Function App (le compte de stockage reste et continue de coûter)
az functionapp delete \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

## --- Logs et diagnostic ---

# Suivre les logs en direct avec les Core Tools
func azure functionapp logstream "func-formateur-cloud"

# Suivre les logs en direct avec Azure CLI
az webapp log tail \
    --name "func-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

## --- Storage Queue (trigger et bindings) ---

# Récupérer la chaîne de connexion du compte de stockage
CONN=$(az storage account show-connection-string \
    --name "stfuncformateur12345" \
    --resource-group "rg-formateur-cloud" \
    --query connectionString \
    --output tsv)

# Lister les queues du compte de stockage
az storage queue list \
    --connection-string "$CONN" \
    --output table

# Créer une queue
az storage queue create \
    --name orders \
    --connection-string "$CONN"

# Envoyer un message dans une queue
az storage message put \
    --queue-name orders \
    --content "order-1234" \
    --connection-string "$CONN"

# Consulter les messages sans les retirer (peek)
az storage message peek \
    --queue-name orders \
    --num-messages 5 \
    --connection-string "$CONN"

# Consulter la poison queue (messages en échec après plusieurs tentatives)
az storage message peek \
    --queue-name orders-poison \
    --num-messages 5 \
    --connection-string "$CONN"

# Vider une queue
az storage message clear \
    --queue-name orders \
    --connection-string "$CONN"

# Supprimer une queue
az storage queue delete \
    --name orders \
    --connection-string "$CONN"

## --- Nettoyage ---

# Supprimer tout le groupe de ressources (Function App, stockage, Application Insights...)
az group delete \
    --name "rg-formateur-cloud" \
    --yes \
    --no-wait

# Vérifier qu'il ne reste rien
az group list \
    --output table