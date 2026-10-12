# TP — Pipeline Azure Virtual Machine

## Objectif

Appréhender l'utilisation d'un pipeline CI / CD dans le cadre d'une machine virtuelle Azure et observer les similitudes avec AWS

## Sujet 

Réaliser, via Gitlab CI, un pipeline de CI / CD en lien avec une machine virtuelle Azure: 

* Compiler l'application
* Réaliser les tests unitaires
    * Publier les rapports de tests
* Vérifier les vulnérabilités de l'application
    * Publier les rapports de vulnérabilité
* Packager l'application dans Gitlab Registry
* Se connecter en SSH à la machine virtuelle Azure équipée de Docker, y lancer un conteneur à partir de l'image déposée préalablement sur Gitlab Registry 

## Bonus 

Provoquer l'arrivée de la machine virtuelle par l'utilisation des commandes Azure CLI dans un job prévu à cet effet. Pour cela, vous pouvez utiliser l'image docker `mcr.microsoft.com/azure-cli:latest`