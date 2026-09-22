# Exercice AWS - AMIs & Application Load Balancer 

## Objectifs 

Appréhender le fonctionnement et l'utilisation de l'image Docker AWS CLI dans le cadre d'un job de dépot de fichier en tant qu'artifact

## Sujet

Réaliser un job Gitlab CI permettant la publication de rapports de tests sur un bucket S3:
* Job de compilation
    * Récupérer le code source de l'application fournie depuis le dépot Gitlab CI
    * Tenter une compilation de l'application
* Job des tests unitaires
    * Récupérer le code source de l'application fournie depuis le dépot Gitlab CI
    * Réaliser les tests unitaires et générer des fichiers de rapports de tests
    * Publier les rapports de tests de sorte à les rendre exploitables par Gitlab CI
* Job de vérification des vulnérabilités
    * Récupérer le code source de l'application fournie depuis le dépot Gitlab CI
    * Réaliser un test des vulnérabilités potentielles des dépendances utilisées par l'application
    * Publier les rapports des vulnérabilités de l'applicatif pour les rendre exploitables par Gitlab CI
* Job de publication sur AWS des sauvegardes
    * Récupération des fichiers provenant des jobs précédents
    * Archivage de l'ensemble des fichiers (dans une archive `.tar` ou `.zip` par exemple)
    * Publier les rapports de tests sur un bucket S3