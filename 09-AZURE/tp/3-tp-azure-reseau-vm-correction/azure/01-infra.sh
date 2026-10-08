#!/usr/bin/env bash
# CORRECTION — Partie 2 : création de l'infrastructure Azure (az CLI)
set -euo pipefail
cd "$(dirname "$0")/.."

RG=${RG:-rg-tp-3tiers}
LOC=${LOC:-francecentral}
VNET=vnet-tp
ADMIN=azureuser
VM_SIZE=${VM_SIZE:-Standard_B1ms}
IMAGE=Ubuntu2404
CLOUD_INIT=azure/cloud-init/docker.yaml
MY_IP=$(curl -s https://api.ipify.org)
echo ">> IP publique admin autorisée en SSH : $MY_IP"

# 1. Groupe de ressources
az group create -n "$RG" -l "$LOC" -o none

# 2. VNet + 3 sous-réseaux
az network vnet create -g "$RG" -n "$VNET" --address-prefixes 10.0.0.0/16 \
  --subnet-name snet-front --subnet-prefixes 10.0.1.0/24 -o none
az network vnet subnet create -g "$RG" --vnet-name "$VNET" -n snet-back --address-prefixes 10.0.2.0/24 -o none
az network vnet subnet create -g "$RG" --vnet-name "$VNET" -n snet-db   --address-prefixes 10.0.3.0/24 -o none

# 3. NAT Gateway : accès Internet sortant (apt, docker pull, pip) pour les VM sans IP publique
az network public-ip create -g "$RG" -n pip-natgw --sku Standard -o none
az network nat gateway create -g "$RG" -n natgw-tp --public-ip-addresses pip-natgw -o none
for SNET in snet-back snet-db; do
  az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n "$SNET" --nat-gateway natgw-tp -o none
done

# 4. NSG (un par sous-réseau)
rule() { # rule <nsg> <nom> <priorité> <Allow|Deny> <source> <port>
  az network nsg rule create -g "$RG" --nsg-name "$1" -n "$2" --priority "$3" \
    --direction Inbound --access "$4" --protocol "*" \
    --source-address-prefixes "$5" --destination-address-prefixes "*" \
    --destination-port-ranges "$6" -o none
}

az network nsg create -g "$RG" -n nsg-front -o none
rule nsg-front Allow-HTTP-Internet 100 Allow Internet    80
rule nsg-front Allow-SSH-Admin     110 Allow "$MY_IP"    22

az network nsg create -g "$RG" -n nsg-back -o none
rule nsg-back  Allow-API-from-front 100  Allow 10.0.1.0/24    5000
rule nsg-back  Allow-SSH-from-front 110  Allow 10.0.1.0/24    22
rule nsg-back  Deny-VNet-Inbound    4000 Deny  VirtualNetwork "*"

az network nsg create -g "$RG" -n nsg-db -o none
rule nsg-db    Allow-MySQL-from-back 100  Allow 10.0.2.0/24    3306
rule nsg-db    Allow-SSH-from-front  110  Allow 10.0.1.0/24    22
rule nsg-db    Deny-VNet-Inbound     4000 Deny  VirtualNetwork "*"

for T in front back db; do
  az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n "snet-$T" --network-security-group "nsg-$T" -o none
done

# 5. Les 3 VM (IP privées fixes, Docker installé via cloud-init)
vm() { # vm <nom> <subnet> <ip privée> <ip publique ou "">
  az vm create -g "$RG" -n "$1" --image "$IMAGE" --size "$VM_SIZE" \
    --vnet-name "$VNET" --subnet "$2" --private-ip-address "$3" \
    --public-ip-address "$4" --public-ip-sku Standard --nsg "" \
    --admin-username "$ADMIN" --generate-ssh-keys \
    --custom-data "$CLOUD_INIT" -o none
}

vm vm-db    snet-db    10.0.3.4 ""
vm vm-back  snet-back  10.0.2.4 ""
vm vm-front snet-front 10.0.1.4 pip-vm-front

FRONT_IP=$(az vm show -d -g "$RG" -n vm-front --query publicIps -o tsv)
echo ">> Infrastructure prête. IP publique du front : $FRONT_IP"
