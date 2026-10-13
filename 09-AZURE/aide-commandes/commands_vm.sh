## --- Machines virtuelles ---

# Vérifier les tailles de VM disponibles (et non restreintes) dans une région
az vm list-skus \
    --location "westeurope" \
    --size Standard_B2 \
    --resource-type virtualMachines \
    --output table

# Vérifier le quota de vCPU de l'abonnement dans une région
az vm list-usage \
    --location "westeurope" \
    --output table

# Lister les images courantes (Ubuntu, Debian, Windows...)
az vm image list \
    --output table

# Lister les images Ubuntu de l'éditeur Canonical
az vm image list \
    --publisher Canonical \
    --offer ubuntu-24_04-lts \
    --all \
    --output table

# Créer une VM Linux (clé SSH générée si absente, pas de mot de passe)
# Facturée à l'heure tant qu'elle est allouée : Standard_B2s coûte quelques centimes par heure
az vm create \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --image Ubuntu2404 \
    --size Standard_B2s \
    --admin-username azureuser \
    --generate-ssh-keys \
    --public-ip-sku Standard

# Créer une VM sans IP publique (accessible uniquement depuis le VNet)
az vm create \
    --name "vm-formateur-private" \
    --resource-group "rg-formateur-cloud" \
    --image Ubuntu2404 \
    --size Standard_B2s \
    --admin-username azureuser \
    --generate-ssh-keys \
    --public-ip-address ""

# Créer une VM avec un fichier cloud-init (installe des paquets au premier démarrage)
az vm create \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --image Ubuntu2404 \
    --size Standard_B2s \
    --admin-username azureuser \
    --generate-ssh-keys \
    --custom-data cloud-init.yaml

# Lister les VM d'un groupe de ressources, avec les IP et l'état d'alimentation
az vm list \
    --resource-group "rg-formateur-cloud" \
    --show-details \
    --query "[].{name:name, size:hardwareProfile.vmSize, power:powerState, ip:publicIps}" \
    --output table

# Afficher l'état d'alimentation d'une VM
az vm get-instance-view \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --query "instanceView.statuses[1].displayStatus" \
    --output tsv

# Récupérer l'IP publique d'une VM
az vm show \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --show-details \
    --query publicIps \
    --output tsv

# Se connecter en SSH (depuis la WSL)
ssh azureuser@<public-ip>

# Se connecter en SSH via Azure CLI (nécessite l'extension ssh, fonctionne avec l'auth Entra ID)
az ssh vm \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

## --- Cycle de vie et facturation ---

# Arrêter uniquement l'OS : la VM est TOUJOURS FACTURÉE en calcul (les ressources restent allouées)
az vm stop \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Désallouer la VM : la facturation du calcul s'arrête (disques et IP publique statique restent facturés)
az vm deallocate \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Démarrer une VM
az vm start \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Redémarrer une VM
az vm restart \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Programmer un arrêt automatique chaque jour à 19h00 UTC (garde-fou contre les VM oubliées)
az vm auto-shutdown \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --time 1900

# Supprimer uniquement la VM (son disque, sa carte réseau et son IP publique restent et continuent de coûter)
az vm delete \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --yes

## --- Taille (scale up) ---

# Lister les tailles vers lesquelles la VM peut être redimensionnée
az vm list-vm-resize-options \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Redimensionner une VM (provoque un redémarrage)
az vm resize \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --size Standard_B2ms

## --- Disques ---

# Lister les disques d'un groupe de ressources
az disk list \
    --resource-group "rg-formateur-cloud" \
    --output table

# Créer et attacher un nouveau disque de données de 32 Go en une seule commande
az vm disk attach \
    --vm-name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --name "disk-data-formateur" \
    --new \
    --size-gb 32 \
    --sku StandardSSD_LRS

# Détacher un disque de données (le disque est conservé et reste facturé)
az vm disk detach \
    --vm-name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --name "disk-data-formateur"

# Créer un snapshot du disque OS
OS_DISK_ID=$(az vm show \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --query storageProfile.osDisk.managedDisk.id \
    --output tsv)

az snapshot create \
    --name "snap-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --source "$OS_DISK_ID"

# Supprimer un disque
az disk delete \
    --name "disk-data-formateur" \
    --resource-group "rg-formateur-cloud" \
    --yes

## --- Réseau de la VM ---

# Lister les ressources réseau créées avec la VM (NIC, NSG, VNet, IP publique)
az network nic list \
    --resource-group "rg-formateur-cloud" \
    --output table

az network public-ip list \
    --resource-group "rg-formateur-cloud" \
    --output table

# Ouvrir un port sur la VM (crée une règle entrante dans le NSG)
az vm open-port \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --port 80 \
    --priority 1010

# Lister les règles du Network Security Group
az network nsg rule list \
    --nsg-name "vm-formateur-cloudNSG" \
    --resource-group "rg-formateur-cloud" \
    --output table

# Restreindre le SSH à ta propre IP publique (recommandé plutôt que 0.0.0.0/0)
az network nsg rule update \
    --name default-allow-ssh \
    --nsg-name "vm-formateur-cloudNSG" \
    --resource-group "rg-formateur-cloud" \
    --source-address-prefixes "$(curl -s https://ifconfig.me)/32"

## --- Exécuter des commandes et configurer ---

# Exécuter une commande shell dans la VM sans SSH
az vm run-command invoke \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --command-id RunShellScript \
    --scripts "sudo apt-get update && sudo apt-get install -y nginx"

# Afficher le journal de démarrage (boot diagnostics), utile quand la VM ne répond pas
az vm boot-diagnostics get-boot-log \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Activer l'identité managée système de la VM
az vm identity assign \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud"

# Ajouter des tags (pratique pour retrouver ce qu'il faut supprimer)
az vm update \
    --name "vm-formateur-cloud" \
    --resource-group "rg-formateur-cloud" \
    --set tags.purpose=lab

# Vérifier les ressources liées à la VM avant de nettoyer
az resource list \
    --resource-group "rg-formateur-cloud" \
    --output table