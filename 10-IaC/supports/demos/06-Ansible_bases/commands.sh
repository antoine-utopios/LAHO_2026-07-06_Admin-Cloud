# Syntaxe d'un appel à une commande Ansible Ad Hoc 
ansible <cible> -m <module>

# Pour ajouter des arguments et leurs valeurs au module
ansible <cible> -m <module> -a <value>

# Pour lancer les commandes en tant que root
ansible <cible> -m <module> -b

## Vérifier que l'ensemble des serveurs de l'inventaire sont compatible avec notre Ansible
# Pour atteindre un groupe ansible <nom-groupe> -m ping
# Pour atteindre un groupe ansible sauf un hôte <nom-groupe>:!<nom-hôte> -m ping
# Pour atteindre deux groupes ansible <nom-groupe1>:<nom-groupe2> -m ping
# Pour atteindre un hôte ansible <nom-hôte> -m ping

ansible all -m ping 
