# Exercice Docker #8

Réaliser une API en Java (via Spring Boot) conteneurisée. 

Cette API devra permettre la réalisation d'un CRUD de base sur une entité de votre choix (pour l'exemple, cela sera des chiens).

Elle offrira plusieurs endpoints, de type: 
* `GET /api/v1/dogs`: Listing des chiens
* `GET /api/v1/dogs/{dogId}`: Récupération d'un chien et de ses détails
* `POST /api/v1/dogs`: Ajout d'un nouveau chien à notre base de données
* `PUT /api/v1/dogs/{dogId}`: Edition d'un chien via son ID
* `DELETE /api/v1/dogs/{dogId}`: Suppression d'un chien via son ID

Pour fonctionner, l'API utilisera Hibernate et sera connectée à une base de données de type MySQL / PostgresSQL.

La base de données sera également conteneurisée, de sorte à ne pas avoir à installer le moindre SGBD en local.

Pour réaliser cet exercice, il est conseillé de: 

* Commencer par créer une base de données via Docker (en la rendant disponible à l'extérieur via le port forwarding)
* Créer un projet de type Java / Spring Boot compatible avec notre système de données (attention au driver à choisir pour Hibernate / JPA)
* Développer une API en local
* Créer le Dockerfile de l'API
* Créer une image de notre API
* Relancer l'API via Docker de sorte à en tester son fonctionnement et sa capacité à communiquer avec la BdD

---

## Correction 

* Commencer par créer une base de données via Docker (en la rendant disponible à l'extérieur via le port forwarding)

```bash
docker run \
-d \
-p 3306:3306 \
-e MYSQL_ALLOW_EMPTY_PASSWORD=true \
-e MYSQL_DATABASE=kennelDB \
-e MYSQL_USER=admin \
-e MYSQL_PASSWORD=password \
-v exo-08-db-data:/var/lib/mysql \
--name mysql \
mysql:9
```

* Créer un projet de type Java / Spring Boot compatible avec notre système de données (attention au driver à choisir pour Hibernate / JPA)

* Développer une API en local


* Créer le Dockerfile de l'API

```dockerfile
FROM maven AS builder

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8090

ENV SPRING_PROFILES_ACTIVE=prod

ENTRYPOINT ["java", "-jar", "app.jar"]
```

* Créer une image de notre API

```bash
docker build -t exo-08 .
```

* Relancer l'API via Docker de sorte à en tester son fonctionnement et sa capacité à communiquer avec la BdD

```bash
docker network create exo-08

docker rm -f mysql

docker run \
-d \
-e MYSQL_ALLOW_EMPTY_PASSWORD=true \
-e MYSQL_DATABASE=kennelDB \
-e MYSQL_USER=admin \
-e MYSQL_PASSWORD=password \
-v exo-08-db-data:/var/lib/mysql \
--network exo-08 \
--name mysql \
mysql:9

docker run \
-d \
-p 8090:8090 \
--rm \
--network exo-08 \
--name exo-08-api \
exo-08
```

* Tester l'API

```bash
curl http://localhost:8090/api/v1/dogs
```