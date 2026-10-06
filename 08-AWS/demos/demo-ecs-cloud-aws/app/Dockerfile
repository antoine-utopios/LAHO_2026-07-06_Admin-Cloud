# ---- Étape 1 : compilation (sur l'architecture de la machine qui construit → rapide) ----
FROM --platform=$BUILDPLATFORM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B package -DskipTests

# ---- Étape 2 : image d'exécution (architecture cible : --platform linux/amd64 ou linux/arm64) ----
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=build /src/target/*.jar app.jar
USER spring
EXPOSE 8080
# MaxRAMPercentage : la JVM s'adapte à la mémoire allouée à la tâche Fargate
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
