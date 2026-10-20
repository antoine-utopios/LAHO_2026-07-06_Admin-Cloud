## INSTALLER LA WSL
wsl --install

## LISTER LES DISTROS LOCALES
wsl --list --verbose

## INSTALLER UNE WSL POUR LES LABS M2I
wsl --install -d Ubuntu-24.04 --name lab-m2i

## OUVRIR VS CODE DANS LE DOSSIER $HOME DE LA WSL (Si l'extension est bien installée)
code ~

## Installer les paquets utilitaires
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl wget gnupg lsb-release \
  software-properties-common unzip git jq python3 python3-pip pipx \
  openssh-client build-essential
pipx ensurepath

## Installer Docker Engine
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
sudo systemctl enable --now docker

## Installer Terraform 
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update && sudo apt install -y terraform
terraform -version

## Installer Ansible 
pipx install --include-deps ansible
pipx inject ansible passlib jmespath    # useful extra libs
ansible --version


## Installer Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version

az login --use-device-code
az account show

## Vérification
docker --version && docker compose version
terraform -version
ansible --version
az version --output table