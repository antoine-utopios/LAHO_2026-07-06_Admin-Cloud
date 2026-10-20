# Exercice 4 - Manipulation du State

## Objectifs

Appréhender la gestion du state dans Terraform

## Sujet

Via Terraform, réaliser, en plusieurs temps, des manipulations d'une infrastructure.

### Etape A - La Base

Réaliser un projet Terraform permettant, de façon dynamique (utilisation de variables), de créer un conteneur docker permettant de jouer au jeu 2048 ainsi qu'une base de données MySQL.

Le dynamisme des éléments sera assuré via l'utilisation de variables telle que les images Docker à utiliser, lesquelles seront pour certaines sécurisées via des secrets (qui ne doivent pas être commités). 

La création d'un serveur web ou d'une base de données sera assurée par un module pour chacune des ressources:
- Le module serveur web acceptera en entrée le nom de l'image, les ports à exposer, le nom de conteneur à générer ainsi qu'un environnement et proposera en sortie l'url du serveur à interoger
- Le module de base de donnée acceptera en entrée le nom de l'image, les ports à exposer, le nom du conteneur à générer, l'environnement système et proposera en sortie une chaîne de connexion

### Etape B - Ajout d'une référence

Ajouter via une référence à une entité externe à Terraform le fait que les conteneurs partagent le même sous-réseau. Ce réseau sera déjà présent dans l'environnement Docker et ne devra pas être géré en interne par Terraform (pas `managed` dans son state). Faire en sorte que le conteneur du serveur web soit dépendant de la base de données et qu'il ne soit pas possible de le créer avant que le conteneur de base de données ne soit présent dans l'infrastructure.

### Etape C - Multiplication du serveur web

Via l'utilisation d'une boucle et d'un mapping, faire en sorte de multiplier le serveur web sans les recréer. Pour cela, faire en sorte de simplement éditer leur adresses dans le state afin que les modification ne proposent pas de provoquer un ensemble de suppression / création de conteneurs. 

### Etape D - Libération de la BdD

Libérer le conteneur de base de données, son image ainsi que le réseau Docker de sorte à ce que le projet Terraform ne gère désormais plus que les conteneurs de serveur web ainsi que leur image. Conserver  cependant une dépendance explicite entre le conteneur de l'API et la base de données