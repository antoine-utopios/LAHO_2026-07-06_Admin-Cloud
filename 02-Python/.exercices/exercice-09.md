# Exercice Python #9 - Stockage Users

## Objectifs

Réaliser un programme permettant de gérer un listing d'utilisateurs de façon persistante

## Sujet

Réaliser un programme permettant à l'utilisateur de:
  * Visualiser un ensemble d'utilisateurs
  * Ajouter un utilisateur au listing
  * Modifier l'un des utilisateurs du listing
  * Supprimer l'un des utilisateurs du listing

Un utilisateur comportera:
  - Un nom
  - Un prénom
  - Une date de naissance
  - Une adresse (voie, numéro de voie, code postal et commune)
  - Un numéro de téléphone
  - Un email

Les données devront être persistantes. Pour cela, utilisez l'un des formats au choix parmis ceux vu en cours, à savoir:
  - Texte brut
  - CSV
  - JSON
  - YAML

## BONUS

* Créer deux fichiers pour la persistance: un pour les utilisateurs, un pour les adresses
* Faire en sorte de permettre de créer des liaisons entre les utilisateurs et les adresses, pour qu'un utilisateur puisse avoir plusieurs adresse et qu'une adresse puisse héberger au besoin plusieurs utilisateurs. De la sorte, alléger le stockage des données. 