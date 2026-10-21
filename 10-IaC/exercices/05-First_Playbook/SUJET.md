# Exercice 5 - Création d'un premier playbook

## Objectifs 

Appréhender le fonctionnement d'Ansible dans un environnement local
Appréhender la syntaxe et l'écriture de playbooks Ansible

## Sujet 

Via Terraform, créer l'infrastructure locale de base (dossier `setup_ansible`).

Puis, en faisant usage d'un playbook Ansible, réaliser les tâches suivantes:
* Sur les serveurs webs:
    * Installer NGINX
    * Créer un fichier de page d'accueil contenant un Hello World quelconque
    * Vérifier que le site web est joignable via un curl
* Sur le serveur de base de données:
    * Installer un serveur MySQL
    * Vérifier que celle-ci est joignable