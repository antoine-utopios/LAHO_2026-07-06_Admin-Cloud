# Exercice 2 - Utilisation de variables et de Outputs

## Objectifs

Appréhender la syntaxe HCL avec son utilisation de variables et d'outputs

## Sujet

Via un projet Terraform, vous allez réaliser plusieurs ressources:
- Trois conteneurs de type serveur web basé sur une image de NGINX au choix (Nom du conteneur dynamique, image à utiliser dynamique, allocation des ports dynamique et utilisation d'une boucle pour leur création)
- Un conteneur de base de données type MySQL / PostgreSQL (Nom du conteneur dynamique, image à utiliser dynamique, allocation des ports dynamique)

L'infrastructure devra utiliser le moins de répétitions possibles et faire usage de variables pour la rendre dynamique et permettre facilement une version production et une version développement via deux fichiers de variables spéficiques (type `prod.local.tfvars` et `dev.local.tfvars` qui ne seront pas commités)