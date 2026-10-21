# Créer une clé SSH locale qu'on utilisera pour Ansible ensuite 
ssh-keygen -f ~/.ssh/ansible_ed25519 -t ed25519 -N "" -C "ansible"

# Copier la clé dans le dossier prévu (à lancer depuis '10-IaC/setup_ansible')
cp ~/.ssh/ansible_ed25519 docker/authorized_keys

# Créer l'image du conteneur Docker utilisée par Terraform ensuite (depuis le dossier '10-IaC/setup_ansible/docker')
docker build -t lab-ansible-target:latest .

# Créer l'infrastructure exploitée par Ansible (depuis le dossier '10-IaC/setup_ansible/terraform')
terraform init 
terraform apply # yes

# Vérifier la présence de l'infrasctructure
docker ps # On doit voir les trois conteneurs: lab-web1, lab-web2, lab-db1
