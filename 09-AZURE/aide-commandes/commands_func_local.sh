## --- Déploiement ---

# Vérification de l'installation de node (doit être 20 ou supérieur)
node --version

# Installer func via NPM
npm install -g azure-functions-core-tools@4

# Vérification de l'installation du runtime func
func --version

# Enregistrement des providers
for ns in Microsoft.Web Microsoft.Storage Microsoft.Insights Microsoft.OperationalInsights; do
  az provider register --namespace "$ns"
done

# Varification de l'enregistrement des Providers
for ns in Microsoft.Web Microsoft.Storage Microsoft.Insights Microsoft.OperationalInsights; do
  echo -n "$ns: "
  az provider show --namespace "$ns" --query registrationState --output tsv
done

# Installer les dépendances (dans le dossier app)
npm install

# Fichier local des paramèètres du Runtime à générer dans 'app' (ne pas commit)
cat > local.settings.json <<'EOF'
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true"
  }
}
EOF

## --- Tests des fonctions ---

# Terminal 1 (depuis app/) - Lancer Azurite:
npx --yes azurite --silent --location ./.azurite --debug ./.azurite/debug.log

# Terminal 2 (depuis app/) - Lancer le Runtime:
func start

# Terminal 3 - Faire des appels HTTP pour déclencher les fonctions
curl "http://localhost:7071/api/hello?name=Azure"
curl -i -X POST "http://localhost:7071/api/enqueue" -d "order-1234"
curl -i -X POST "http://localhost:7071/api/enqueue" -d "please fail"

# Observation des Queues
az storage message peek --queue-name processed --connection-string "UseDevelopmentStorage=true" --num-messages 5
az storage message peek --queue-name orders-poison --connection-string "UseDevelopmentStorage=true" --num-messages 5