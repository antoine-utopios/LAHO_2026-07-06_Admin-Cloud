# Exercice Gitlab_CI #1 - Pipeline dans un runner local

## Objectifs

Appréhender l'ajout d'un runner local à Gitlab CI

## Sujet

Réaliser un job de test dans un runner local.

* Créer un groupe (si ce n'est pas déjà fait) permettant l'isolation du projet
* Ajouter un runner au niveau du groupe
* Désactiver l'autorisation d'utiliser les runner d'instance provennant de gitlab.com
* Créer un projet pour l'exercice
* Ajouter un fichier de pipeline `.gitlab-ci.yml` contenant un job de base (un Hello World par exemple)
* Lancer le pipeline et vérifier qu'il se lance bien dans notre runner local

## BONUS 

* Créer plusieurs runner locaux avec chacun une image docker différente par défaut
* Faire plusieurs jobs dans le pipeline, chacun se lançant dans un runner différent adapté aux besoins du job (par exemple un job utilisant la commande `docker version` dans un runner utilisant l'image `docker` et un job utilisant la commande `python --version` dans un runner utilisant l'image `python:slim`)