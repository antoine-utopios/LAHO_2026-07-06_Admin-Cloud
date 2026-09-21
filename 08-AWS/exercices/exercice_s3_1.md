# Exercice 1 — Créer un espace de livraison de projet

## Scénario

Une équipe doit stocker les livrables d'un projet appelé :

```text
projet-phoenix
```

Elle souhaite l'organisation suivante :

```text
projet-phoenix/
|
+-- documentation/
+-- releases/
+-- logs/
```

## Travail demandé

Avec AWS CLI :

1. créer un nouveau bucket dans la région utilisée pendant la formation ;
2. conserver le bucket privé ;
3. créer localement trois fichiers :

   * `README.txt`
   * `version.txt`
   * `application.log`
4. déposer :

   * `README.txt` dans `documentation/` ;
   * `version.txt` dans `releases/v1/` ;
   * `application.log` dans `logs/` ;
5. lister récursivement les objets ;
6. télécharger uniquement `version.txt` ;
7. supprimer uniquement le fichier de log ;
8. vérifier le résultat.

Résultat attendu :

```text
bucket
|
+-- documentation/
|   +-- README.txt
|
+-- releases/
    +-- v1/
        +-- version.txt
```

### Questions

1. Les trois répertoires existent-ils réellement dans S3 ?
2. Quelle est la clé de `version.txt` ?
3. Pourquoi l'URL du fichier ne permet-elle pas nécessairement de le télécharger depuis un navigateur ?
4. Quelle permission IAM est associée conceptuellement à l'envoi d'un objet ?



# Corrections

## Correction exercice 1

Exemple de création :

```bash
aws s3 mb s3://projet-phoenix-839254 --region eu-west-3 --profile formation
```

Envoi de la documentation :

```bash
aws s3 cp README.txt s3://projet-phoenix-839254/documentation/README.txt --profile formation
```

Envoi de la version :

```bash
aws s3 cp version.txt s3://projet-phoenix-839254/releases/v1/version.txt --profile formation
```

Envoi du log :

```bash
aws s3 cp application.log s3://projet-phoenix-839254/logs/application.log --profile formation
```

Liste :

```bash
aws s3 ls s3://projet-phoenix-839254 --recursive --profile formation
```

Téléchargement :

```bash
aws s3 cp s3://projet-phoenix-839254/releases/v1/version.txt version-recuperee.txt --profile formation
```

Suppression :

```bash
aws s3 rm s3://projet-phoenix-839254/logs/application.log --profile formation
```

La clé du fichier est :

```text
releases/v1/version.txt
```

Les « dossiers » correspondent à des préfixes.

Une URL ne donne aucune permission particulière.

L'envoi d'un objet nécessite notamment :

```text
s3:PutObject
```