# Exercice Python #10 - Appels API

## Objectifs

Appréhender le fonctionnement des APIs et du lancement de programme CLI Python

## Sujet

Réaliser un programme permettant, via l'utilisation d'arguments au lancement et d'appels APIs, de récupérer les informations météorologiques sur une ville donnée.

Pour cela, vous utiliserez par exemple des arguments permettant de:
  * Choisir le nombre de jours à récupérer lors de l'extraction des prévisions (par défaut sur une semaine entière)
  * Choisir un mode verbeux ou pas, affichant des détails tels que `Appel API vers https://....`

L'API à utiliser peut être par exemple `https://open-meteo.com/` ou `https://openweathermap.org/api`. 

Attention, certaines APIs nécessittent la création d'un compte dans le but d'avoir accès à une clé API, qu'il faudra ajouter dans les requêtes, soit par un Header particulier, soit dans le endpoint.