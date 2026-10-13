# TP AWS – Déploiement d'une application conteneurisée avec GitLab CI/CD, ECR et ECS

## 1. Contexte et objectifs

Vous intégrez l'équipe plateforme d'une entreprise qui souhaite industrialiser le déploiement de son application web sur AWS. Vous devez mettre en place, de bout en bout, une chaîne de livraison continue : de la compilation du code jusqu'à son exécution sur une infrastructure capable d'absorber la charge.

À l'issue de ce TP, vous serez capable de :

- provisionner une instance **Amazon EC2** sécurisée (groupe de sécurité, paire de clés SSH) et y installer Docker ;
- concevoir un pipeline **GitLab CI/CD** complet : compilation, tests unitaires, analyse de vulnérabilités, archivage et packaging ;
- publier des rapports sur **Amazon S3** et des images de conteneur sur **Amazon ECR** ;
- exploiter l'**AWS CLI** dans un pipeline avec des identifiants fournis par variables d'environnement ;
- déployer l'image sur **Amazon ECS** avec une définition de tâche et trois tâches en parallèle.

## 2. Prérequis, ressources et démarche

**Prérequis**

- un compte AWS avec les droits de créer des ressources EC2, S3, ECR, ECS et IAM ;
- un compte GitLab (gitlab.com ou instance de la formation) et un client Git ;
- des notions de Docker, de ligne de commande Linux et de syntaxe YAML.

**Ressources fournies**

- le dossier `app` : application web React (Vite) avec son `Dockerfile` multi-étapes, ses tests unitaires (Vitest) et ses scripts npm `build` et `test` ;
- le script `script-install-docker.sh` : installation de Docker sur l'instance EC2.

**Démarche**

Le TP se déroule en trois parties successives. Chaque partie s'appuie sur la précédente.

1. **Partie 1** : une première instance EC2 prête à héberger des conteneurs.
2. **Partie 2** : un pipeline GitLab CI/CD qui construit, teste, analyse et publie l'application.
3. **Partie 3** : un déploiement résilient sur un cluster ECS, avec trois tâches.

> **Bonnes pratiques attendues sur l'ensemble du TP** : ne jamais committer de secret dans le dépôt, masquer (*masked*) les variables sensibles dans GitLab, et utiliser un utilisateur IAM dédié dont les droits sont limités au strict nécessaire (principe du moindre privilège).

## 3. Partie 1 – Provisionner l'infrastructure de déploiement (EC2)

**Objectif** : disposer d'une instance EC2 accessible en SSH, sur laquelle Docker est installé et opérationnel.

1. **Créer un groupe de sécurité** dédié à l'instance. Il doit autoriser le trafic entrant SSH (port 22) et HTTP (port 80), et rien d'autre. Restreignez si possible la source du port 22 à votre adresse IP.
2. **Lancer une instance EC2** avec sa propre paire de clés SSH et le groupe de sécurité créé à l'étape précédente. Conservez précieusement la clé privée (`.pem`) : elle ne peut pas être téléchargée une seconde fois.
3. **Se connecter en SSH** à l'instance, puis exécuter le script `script-install-docker.sh` pour installer Docker.

**Critères de validation**

- [ ] Le groupe de sécurité n'expose que les ports 22 et 80.
- [ ] La connexion SSH fonctionne avec la clé privée.
- [ ] La commande suivante s'exécute sans erreur sur l'instance :

```bash
# Check that Docker is installed and that the daemon is running
docker run --rm hello-world
```

## 4. Partie 2 – Construire le pipeline GitLab CI/CD

**Objectif** : automatiser, à chaque push, la vérification, l'archivage et le packaging de l'application.

### 4.1 Préparation

Créez un dépôt sur GitLab et versionnez-y le contenu du dossier `app`. Le pipeline se décrit dans un fichier `.gitlab-ci.yml` à la racine du dépôt.

### 4.2 Jobs à implémenter

| Job | Image Docker | Mission | Résultat attendu |
| --- | --- | --- | --- |
| `build` | image Node.js | Installer les dépendances et compiler l'application (`npm run build`) | Compilation validée ; dossier `build/` conservé en artefact |
| `test` | image Node.js | Exécuter les tests unitaires (`npm test`) | Rapports de tests publiés en artefacts, consultables par le relecteur dans la *merge request* |
| `vulnerabilities` | `aquasec/trivy` | Analyser les dépendances de l'application avec Trivy | Rapport de vulnérabilités en artefact |
| `archive` | `amazon/aws-cli` | Récupérer les artefacts des jobs précédents, les regrouper dans une archive (`.tar` ou `.zip`) et la publier dans un bucket S3 | Archive horodatée présente dans S3 |
| `package` | `amazon/aws-cli` | Construire l'image de conteneur et la pousser dans un dépôt ECR | Image taguée disponible dans ECR |

**Points d'attention**

- Les images `aquasec/trivy` et `amazon/aws-cli` définissent un point d'entrée (`entrypoint`) qui empêche GitLab d'exécuter vos scripts : surchargez-le (`entrypoint: [""]`).
- Les tests produisent des rapports dans le dossier `reports/` (JUnit XML et HTML). Déclarez-les dans la section `artifacts` du job, le rapport JUnit via `artifacts:reports:junit`.
- L'image `amazon/aws-cli` ne contient pas Docker. Pour le job `package`, prévoyez un service `docker:dind` et l'installation du client Docker dans le job.
- Créez au préalable le bucket S3 et le dépôt ECR dans la console AWS. Si vous activez l'immutabilité des tags sur ECR, chaque image doit porter un tag unique (voir l'annexe).

### 4.3 Authentification auprès d'AWS

L'AWS CLI lit ses identifiants dans des variables d'environnement standard (voir la documentation officielle de l'AWS CLI). Créez un utilisateur IAM dédié au pipeline avec une clé d'accès, puis renseignez les variables ci-dessous dans **Paramètres > CI/CD > Variables** du dépôt GitLab.

| Variable | Rôle | Options GitLab |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | Identifiant de la clé d'accès | Masquer |
| `AWS_SECRET_ACCESS_KEY` | Secret de la clé d'accès | Masquer |
| `AWS_DEFAULT_REGION` | Région AWS cible (par exemple `eu-west-3`) | – |
| `AWS_ECR_IMAGE_NAME` | Nom du dépôt ECR créé en amont | – |
| `AWS_S3_BUCKET` | Nom du bucket S3 de destination des rapports | – |

### 4.4 Critères de validation

- [ ] Le pipeline s'exécute automatiquement à chaque push et tous les jobs passent au vert.
- [ ] Les rapports de tests sont téléchargeables depuis GitLab et visibles dans une *merge request*.
- [ ] Le rapport Trivy est disponible en artefact.
- [ ] L'archive est présente dans le bucket S3.
- [ ] L'image de l'application est visible dans ECR, avec un tag identifiant le commit.
- [ ] Aucun secret n'apparaît dans le code ni dans les journaux du pipeline.

## 5. Partie 3 – Déployer sur Amazon ECS

**Objectif** : exécuter l'image publiée dans ECR sur un cluster ECS, avec trois instances de l'application en parallèle pour absorber la charge et tolérer la perte d'une tâche.

1. **Créer un cluster ECS.** Le mode de capacité Fargate est recommandé : il évite de gérer des serveurs.
2. **Créer une définition de tâche** référençant l'image ECR de l'application (URI complète avec son tag), exposant le port 80 du conteneur et dotée d'un rôle d'exécution autorisant ECS à télécharger l'image depuis ECR.
3. **Créer un service ECS** basé sur cette définition, avec un nombre de tâches souhaité de **3**.
4. **Contrôler le résultat** : trois tâches à l'état *Running*, et application accessible via l'adresse d'une tâche. Le groupe de sécurité associé doit donc autoriser le port 80 en entrée.

**Critères de validation**

- [ ] Le service affiche 3 tâches souhaitées et 3 tâches en cours d'exécution.
- [ ] L'application répond en HTTP sur chacune des tâches.
- [ ] En arrêtant manuellement une tâche, ECS en relance une nouvelle automatiquement.

## 6. Bonus – Automatiser le déploiement dans le pipeline

**Pour aller plus loin** : ajoutez un job `deploy` en fin de pipeline qui met à jour automatiquement le service ECS avec la nouvelle image publiée dans ECR. Ce job utilise de nouveau l'image `amazon/aws-cli` et ne passe que par l'AWS CLI : enregistrement d'une nouvelle révision de la définition de tâche, puis mise à jour du service pour qu'il l'utilise.

- [ ] Le job `deploy` s'exécute après `package`, uniquement si les jobs précédents ont réussi.
- [ ] Un nouveau commit sur la branche principale déclenche un redéploiement sans intervention manuelle.
- [ ] Le service ECS conserve ses 3 tâches pendant et après la mise à jour.

## 7. Livrables

| Livrable | Contenu |
| --- | --- |
| Dépôt GitLab | Code de l'application et fichier `.gitlab-ci.yml` |
| Pipeline | Exécution réussie, avec tous les jobs au vert |
| Preuves AWS | Captures ou liens : instance EC2, archive S3, image ECR, service ECS avec 3 tâches |

## Annexe – Rappel des commandes ECR

Ces commandes servent de base au job `package`. Elles reposent sur les variables définies en section 4.3 (`AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ECR_IMAGE_NAME`).

```bash
# Retrieve the AWS account ID from the current credentials
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGISTRY=$ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

# Authenticate the Docker client against the private ECR registry
aws ecr get-login-password --region $AWS_DEFAULT_REGION \
  | docker login --username AWS --password-stdin $AWS_REGISTRY
```

**Option A – tags mutables** : le tag `latest` peut être réécrit à chaque publication.

```bash
docker build -t $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:latest .
docker push $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:latest
```

**Option B – tags immuables** (recommandée en production) : chaque publication porte un tag unique, ici le hash court du commit.

```bash
docker build -t $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:$CI_COMMIT_SHORT_SHA .
docker push $AWS_REGISTRY/$AWS_ECR_IMAGE_NAME:$CI_COMMIT_SHORT_SHA
```