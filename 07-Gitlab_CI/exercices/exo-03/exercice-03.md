# Exercice Gitlab_CI #1 - Pipeline dans un runner local

## Objectifs

Réaliser un pipeline CI pour un projet Java Spring 

## Sujet

Réaliser un pipeline avec Gitlab CI permettant:

* La compilation d'une application Java sous la forme d'un .jar
* La génération d'un dossier de rapports de tests au format HTML exporté
* La génération d'un rapport de test au format JUnit visualisable dans l'interface du pipeline

Pour cela, il vous faudra utiliser les images docker suivante: 
* `maven:3.9.8-eclipse-temurin-21` pour les commandes Java / Maven
* `alpine` s'il s'agit de tester simplement la présence d'un fichier / dossier dans le répertoire local

Au niveau des commandes Maven à utiliser:
* `mvn B -Dmaven.repo.local=.m2/repository -Dmaven.test.failure.ignore=false clean install -DskipTests` pour générer le package au format désiré après compilation de l'applicatif
* `mvn B -Dmaven.repo.local=.m2/repository -Dmaven.test.failure.ignore=false verify` pour faire les tests et publier le rapport. Les rapports seront dans les dossiers:
  * `target/site/jacoco/` pour les rapports de couverture du code
  * `target/surefire-reports/` pour les rapports de tests. Ces derniers seront indépendant, fichier Java par fichier Java et seront tous nommés `target/surefire-reports/TEST-NOM_CLASSE.xml` avec `NOM_CLASSE` étant le nom du fichier de classe Java testé.