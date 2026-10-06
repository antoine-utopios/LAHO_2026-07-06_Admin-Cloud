# =====================================================
# Stage 1 — Build avec Maven + JDK 21
# =====================================================
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace

# Cache des dépendances : on copie d'abord pom.xml seul
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Puis le code source
COPY src ./src
RUN mvn -B clean package -DskipTests

# =====================================================
# Stage 2 — Runtime léger avec JRE 21 Alpine
# =====================================================
FROM eclipse-temurin:21-jre-alpine

# Utilisateur non-root (sécurité)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar

# App Runner injecte la variable PORT (par défaut 8080)
ENV PORT=8080
EXPOSE 8080

# Options JVM adaptées au runtime managé
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
