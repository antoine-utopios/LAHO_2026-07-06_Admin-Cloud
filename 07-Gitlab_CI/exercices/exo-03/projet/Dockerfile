# Étape 1 : Build avec Maven
FROM maven:3.9.8-eclipse-temurin-21 AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement le pom.xml et télécharger les dépendances pour profiter du cache Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copier le code source et compiler le projet
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : Image finale (runtime uniquement)
FROM eclipse-temurin:21-jre-alpine

# Définir un utilisateur non-root (bonne pratique sécurité)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement le jar généré depuis l’étape build
COPY --from=build /app/target/*.jar app.jar

# Exposer le port par défaut de Spring Boot
EXPOSE 8080

# Commande de lancement
ENTRYPOINT ["java","-jar","app.jar"]
