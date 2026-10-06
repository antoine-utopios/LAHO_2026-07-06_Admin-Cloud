# TP — Déployer « Rick & Morty Explorer » sur Amazon ECS Fargate

**Durée** : 1 h 30 à 2 h — **Région** : eu-west-3 (Paris) — **Travail** : individuel ou en binôme

## Contexte

Votre équipe vous confie la mise en ligne de **Rick & Morty Explorer**, une application web
Spring Boot / Thymeleaf qui affiche les personnages, lieux et épisodes de la série en interrogeant
l'API publique https://rickandmortyapi.com.

Code source : https://github.com/mohamedutopios/rick-morty-thymeleaf.git

Ce que vous savez de l'application :
- elle est livrée avec un `Dockerfile` et un `docker-compose.yml` ;
- elle écoute sur le port **8080** ;
- elle n'a **pas de base de données** ;
- la page d'accueil affiche la valeur de la variable d'environnement **`APP_ENV`** ;
- elle expose **`/actuator/health`** (santé) et **`/debug/characters`** (test de l'appel à l'API externe).

## Contraintes imposées

- Exécution sur **Amazon ECS avec Fargate**.
- **Aucun load balancer** : l'application doit être joignable directement depuis Internet.
- **Aucune base de données.**
- L'image doit être stockée dans **Amazon ECR**.
- Les journaux de l'application doivent être consultables dans **CloudWatch**.
- ECS doit pouvoir détecter seul qu'un conteneur ne répond plus (**health check**).
- Toutes vos ressources AWS commencent par **`rm-`** (ou `rm-<initiales>-` sur un compte partagé).
- Taille de tâche : **0,5 vCPU / 1 Go**.

Le schéma `architecture-tp.html` fourni montre l'architecture attendue.

---

## Mission 1 — Prendre en main l'application (local)

Faites tourner l'application sur votre poste et vérifiez qu'elle fonctionne.

**Résultat attendu** : les pages Characters, Locations et Episodes s'affichent, `/debug/characters` renvoie `"ok": true`.

## Mission 2 — Préparer le réseau

Mettez en place un réseau dans lequel une tâche Fargate pourra :
- être joignable depuis Internet sur le port de l'application, **et uniquement sur celui-ci** ;
- télécharger son image et joindre l'API externe, **sans payer de passerelle NAT**.

## Mission 3 — Publier l'image

Publiez l'image de l'application dans un référentiel ECR, avec le tag **`1.0`**.

**Résultat attendu** : l'image `1.0` est visible dans la console ECR.

## Mission 4 — Décrire et lancer l'application sur ECS

Créez ce qu'il faut dans ECS pour qu'**une** instance de l'application tourne en permanence, avec :
- l'image `1.0` ;
- `APP_ENV` = `ecs` ;
- les journaux envoyés vers CloudWatch ;
- un health check du conteneur basé sur `/actuator/health`.

**Résultat attendu** : la tâche est **Running** et **Healthy**.

## Mission 5 — Accéder à l'application

Ouvrez l'application depuis votre navigateur, sans load balancer.

**Résultat attendu** : la page d'accueil affiche le badge **ECS**, toutes les pages fonctionnent,
et vous retrouvez la ligne de démarrage de Spring dans les journaux.

## Mission 6 — Éprouver l'architecture

Réalisez les trois expériences suivantes et notez ce que vous observez.

1. **Panne** : arrêtez la tâche en cours.
2. **Montée en charge** : faites tourner 2 instances de l'application, puis revenez à 1.
3. **Nouvelle configuration** : déployez l'application avec `APP_ENV` = `production`.

## Mission 7 — Piloter en ligne de commande

Refaites les opérations suivantes **uniquement avec l'AWS CLI** :
- afficher l'état du service (instances voulues / en cours, révision utilisée) ;
- retrouver l'adresse publique de la tâche en cours ;
- afficher les journaux des 10 dernières minutes ;
- passer à 2 instances puis revenir à 1 ;
- arrêter la tâche en cours et retrouver la nouvelle adresse.

## Mission 8 — Nettoyer

Supprimez **toutes** les ressources créées pendant le TP. Vérifiez qu'aucune ressource `rm-` ne
continue à tourner ou à être facturée.

---

## Livrables

- Deux captures de l'application en ligne : badge **ECS**, puis badge **PRODUCTION**.
- Les commandes AWS CLI de la mission 7.

## Pour aller plus loin

- Ajouter un Application Load Balancer pour obtenir une adresse stable.
