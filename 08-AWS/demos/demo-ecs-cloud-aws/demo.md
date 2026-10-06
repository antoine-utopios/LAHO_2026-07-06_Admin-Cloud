# Pas à pas — Déployer une application Spring Boot / Thymeleaf + PostgreSQL sur Amazon ECS

> Région : **us-east-1 (N. Virginia)** — à vérifier en haut à droite de la console, à chaque écran.

**L'application** (`app/`) : gestion de produits (liste, ajout, modification, suppression)
- Spring Boot 4.1 / Java 21 / Thymeleaf / Spring Data JPA / Bean Validation / Actuator
- Base **PostgreSQL** → sur AWS : **Amazon RDS**
- Le pied de page affiche **le conteneur qui a répondu** et **la version** → idéal pour montrer
  la répartition de charge et les mises à jour progressives.

```
                Internet
                   │ HTTP :80
                   ▼
        ┌─────────────────────┐   SG produits-alb-sg (80 depuis partout)
        │ Application LB      │
        └──────────┬──────────┘
                   │ :8080  (target group « IP », health check /actuator/health/liveness)
     ┌─────────────┴─────────────┐
     ▼                           ▼        SG produits-app-sg (8080 depuis l'ALB uniquement)
┌──────────┐               ┌──────────┐
│ Tâche    │   Fargate     │ Tâche    │   Image Docker ← Amazon ECR
│ Spring   │   (ECS)       │ Spring   │   Logs → CloudWatch Logs
└────┬─────┘               └────┬─────┘   Identifiants BDD ← Secrets Manager
     └────────────┬─────────────┘
                  │ :5432                 SG produits-db-sg (5432 depuis les tâches uniquement)
                  ▼
          ┌───────────────┐
          │ RDS PostgreSQL│  sous-réseaux privés, non accessible depuis Internet
          └───────────────┘
   VPC 10.2.0.0/16 : 2 sous-réseaux publics (ALB + tâches) — 2 sous-réseaux privés (RDS)
```

| Étape | Où | Durée |
|---|---|---|
| 0. Tester l'application en local | Docker | 5 min |
| 1. Réseau : VPC | Console VPC | 5 min |
| 2. Groupes de sécurité (3 niveaux) | Console EC2 | 5 min |
| 3. Base RDS PostgreSQL | Console RDS | 5 min (+10 min d'attente) |
| 4. Dépôt d'images ECR | Console ECR | 2 min |
| 5. Construire et pousser l'image | Terminal (Docker + AWS CLI) | 5 min |
| 6. Rôle IAM d'exécution + accès au secret | Console IAM | 5 min |
| 7. Groupe de logs | Console CloudWatch | 1 min |
| 8. Target group + Load Balancer | Console EC2 | 7 min |
| 9. Cluster ECS | Console ECS | 2 min |
| 10. Définition de tâche | Console ECS | 7 min |
| 11. Service ECS | Console ECS | 5 min (+3 min d'attente) |
| 12. Tester et observer | Navigateur + Console | 10 min |
| **13-20. Exploitation** | **AWS CLI** | 40 min |
| 21. Nettoyage | CLI + Console | 15 min |

**Coût indicatif** : ≈ 0,12 $/h (RDS db.t4g.micro — éligible offre gratuite —, ALB, 2 tâches Fargate
0,5 vCPU/1 Go, IPv4 publiques) + Secrets Manager 0,40 $/mois. ➡️ **Faire l'étape 21 à la fin.**

### Prérequis sur le poste

- **Docker Desktop** démarré
- **AWS CLI v2** configurée (`aws sts get-caller-identity` doit répondre) — région `us-east-1`
- Un terminal **bash/zsh** (macOS, Linux, ou **WSL / Git Bash** sous Windows)

---

# PARTIE 1 — Déploiement dans la Console AWS

## Étape 0 — Tester l'application en local

```bash
cd app
docker compose up --build
```

Ouvrir http://localhost:8080 → 3 produits de démonstration. Ajouter / modifier / supprimer un produit.
Le pied de page affiche `Conteneur`, `Base de données : db`, `Version : 1.0-local`.

```bash
docker compose down -v
```

> Ce qui va changer sur AWS : la base `db` du docker-compose devient **RDS**, le mot de passe
> `postgres` en clair devient un **secret Secrets Manager**, le port 8080 est servi par un **ALB**.
> Le code, lui, ne change pas : tout passe par des **variables d'environnement**
> (`DB_HOST`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`, `APP_VERSION` — voir `application.properties`).

---

## Étape 1 — Réseau : VPC (Console VPC)

**VPC → Créer un VPC → VPC et plus**

| Champ | Valeur |
|---|---|
| Génération automatique des noms | ✅ `produits` |
| Bloc CIDR IPv4 | `10.2.0.0/16` |
| Nombre de zones de disponibilité | **2** |
| Sous-réseaux publics | **2** (ALB + tâches ECS) |
| Sous-réseaux privés | **2** (RDS) |
| Passerelles NAT | **Aucune** |
| Points de terminaison d'un VPC | **Aucun** |
| Noms d'hôte DNS / Résolution DNS | ✅ / ✅ |

→ **Créer un VPC**.

> Choix de démo : les tâches ECS sont dans les sous-réseaux **publics** avec une IP publique pour pouvoir
> télécharger l'image depuis ECR sans NAT Gateway (≈ 32 $/mois économisés). Elles restent inaccessibles
> directement : leur groupe de sécurité n'accepte que l'ALB. En production : sous-réseaux privés + NAT
> ou VPC endpoints ECR/S3/Logs/Secrets Manager.

---

## Étape 2 — Groupes de sécurité : la sécurité en 3 niveaux (Console EC2)

**EC2 → Groupes de sécurité → Créer un groupe de sécurité** — VPC : `produits-vpc` pour les 3.

| Nom | Règle entrante | Source |
|---|---|---|
| `produits-alb-sg` | HTTP **80** | `0.0.0.0/0` (Partout-IPv4) |
| `produits-app-sg` | TCP personnalisé **8080** | groupe **`produits-alb-sg`** |
| `produits-db-sg` | PostgreSQL **5432** | groupe **`produits-app-sg`** |

(laisser les règles sortantes par défaut)

> On ne référence **pas d'adresses IP** mais **des groupes de sécurité** : seules les ressources
> portant `produits-app-sg` (= nos tâches) peuvent parler à la base, quelle que soit leur IP.

---

## Étape 3 — Base de données RDS PostgreSQL (Console RDS)

À lancer tôt : la création prend ~10 minutes.

### 3.1 Groupe de sous-réseaux (la base ira dans les sous-réseaux privés)

**RDS → Groupes de sous-réseaux → Créer un groupe de sous-réseaux de base de données**

| Champ | Valeur |
|---|---|
| Nom / Description | `produits-db-subnets` / `Sous-reseaux prives RDS` |
| VPC | `produits-vpc` |
| Zones de disponibilité | les 2 zones (ex. us-east-1a, us-east-1b) |
| Sous-réseaux | les 2 sous-réseaux **privés** (`10.2.128.0/20` et `10.2.144.0/20`) |

→ **Créer**.

### 3.2 La base

**RDS → Bases de données → Créer une base de données**

| Section | Champ | Valeur |
|---|---|---|
| Méthode de création | | **Création standard** |
| Options du moteur | Type | **PostgreSQL** — version 17 (la plus récente proposée) |
| Modèles | | **Offre gratuite** (ou *Dev/Test*) |
| Disponibilité | | Instance de base de données mono-AZ |
| Paramètres | Identifiant d'instance | `produits-db` |
| | Nom d'utilisateur principal | `postgres` |
| | **Gestion des informations d'identification** | **Gérées dans AWS Secrets Manager** |
| Configuration de l'instance | Classe | Classes à capacité extensible → **db.t4g.micro** |
| Stockage | Type / Taille | gp3 / **20 Gio** — décocher *Activer la mise à l'échelle automatique du stockage* |
| Connectivité | Ressource de calcul | Ne pas se connecter à une ressource de calcul EC2 |
| | VPC | `produits-vpc` |
| | Groupe de sous-réseaux | `produits-db-subnets` |
| | **Accès public** | **Non** |
| | Groupe de sécurité VPC | **Choisir existant** → `produits-db-sg` (**retirer `default`**) |
| Authentification | | Authentification par mot de passe |
| Surveillance | | Laisser *Database Insights – Standard*, décocher la surveillance améliorée |
| **Configuration supplémentaire** | **Nom de base de données initial** | **`produits`** ⚠️ sinon aucune base n'est créée |
| | Sauvegarde | rétention **1 jour** |
| | Protection contre la suppression | décochée |

→ **Créer une base de données**. Statut : *Création* → **Disponible** (~10 min).

### 3.3 Noter deux informations (une fois la base *Disponible*)

`produits-db` → onglet **Connectivité et sécurité** :
- **Point de terminaison** : `produits-db.xxxxxxxx.us-east-1.rds.amazonaws.com` → ce sera `DB_HOST`

`produits-db` → onglet **Configuration** → **ARN des informations d'identification principales** :
- cliquer dessus → Secrets Manager s'ouvre sur le secret `rds!db-…`
- **Récupérer la valeur du secret** : il contient `username` et `password` (générés par AWS, personne ne les a tapés)
- Noter l'**ARN du secret** : `arn:aws:secretsmanager:us-east-1:<compte>:secret:rds!db-xxxx-AbCdEf`

---

## Étape 4 — Dépôt d'images ECR (Console ECR)

**Elastic Container Registry → Référentiels privés → Créer un référentiel**

| Champ | Valeur |
|---|---|
| Nom du référentiel | `produits` |
| Mutabilité des balises | Mutable |

→ **Créer**. Noter l'**URI** : `<compte>.dkr.ecr.us-east-1.amazonaws.com/produits`.

---

## Étape 5 — Construire et pousser l'image (Terminal : Docker + AWS CLI)

Seule étape hors console de la partie 1 : construire une image Docker se fait forcément sur une machine.
Dans la console, le bouton **Afficher les commandes push** du référentiel donne les mêmes commandes.

```bash
export AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
REPO_URI=$REGISTRY/produits
```

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY
```

```bash
cd app
docker buildx build --platform linux/amd64 -t $REPO_URI:1.0 --push .
```

> `--platform linux/amd64` : l'image doit correspondre à l'architecture choisie pour Fargate (X86_64).
> Le `Dockerfile` compile avec Maven sur l'architecture du poste (rapide, même sur Mac M1/M2/M3),
> puis produit une image d'exécution pour la plateforme demandée.

👉 Console **ECR → produits** : l'image `1.0` apparaît (≈ 100 Mo compressée).

---

## Étape 6 — Rôle IAM d'exécution de tâche (Console IAM)

Ce rôle est utilisé par **ECS lui-même** (pas par le code Java) pour : télécharger l'image depuis ECR,
écrire les logs dans CloudWatch, **lire le secret RDS** et l'injecter dans le conteneur.

### 6.1 Le rôle

> Il existe souvent déjà : **IAM → Rôles** → chercher `ecsTaskExecutionRole`. S'il existe, passer à 6.2.

**IAM → Rôles → Créer un rôle** → *Service AWS* → cas d'utilisation **Elastic Container Service**
→ **Elastic Container Service Task** → **Suivant** → cocher **AmazonECSTaskExecutionRolePolicy**
→ **Suivant** → nom `ecsTaskExecutionRole` → **Créer le rôle**.

### 6.2 Autoriser la lecture du secret RDS (et seulement lui)

`ecsTaskExecutionRole` → **Ajouter des autorisations → Créer une politique en ligne** → onglet **JSON** :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "ARN_DU_SECRET_RDS_NOTE_A_L_ETAPE_3.3"
    }
  ]
}
```

→ **Suivant** → nom `produits-lire-secret-rds` → **Créer une politique**.

> **Moindre privilège** : le rôle ne peut lire **que** ce secret.
> Sans cette politique, la tâche échoue au démarrage avec `ResourceInitializationError ... secretsmanager`.

---

## Étape 7 — Groupe de logs (Console CloudWatch)

**CloudWatch → Journaux → Groupes de journaux → Créer un groupe de journaux**
- Nom : `/ecs/produits` — Rétention : **1 semaine** → **Créer**.

---

## Étape 8 — Target group + Application Load Balancer (Console EC2)

### 8.1 Groupe cible

**EC2 → Groupes cibles → Créer un groupe cible**

| Champ | Valeur |
|---|---|
| Type de cible | **Adresses IP** (obligatoire avec Fargate) |
| Nom | `produits-tg` |
| Protocole : Port | HTTP : **8080** |
| VPC | `produits-vpc` |
| Chemin de vérification de l'état | **`/actuator/health/liveness`** |
| Paramètres avancés | Seuil sain **2**, intervalle **15 s**, codes de succès `200` |

→ **Suivant** → n'enregistrer **aucune** cible (ECS le fera) → **Créer un groupe cible**.

> **Pourquoi `/liveness` et pas `/actuator/health` ?** `/actuator/health` inclut l'état de la base.
> Si RDS redémarre, toutes les tâches deviendraient « unhealthy » → ECS les tuerait et les relancerait
> en boucle alors que l'application, elle, va bien. La sonde *liveness* répond « le processus Java est vivant ».
> (Scénario démontré à l'étape 19.)

### 8.2 Load Balancer

**EC2 → Équilibreurs de charge → Créer → Application Load Balancer**

| Champ | Valeur |
|---|---|
| Nom | `produits-alb` |
| Schéma | Accessible sur Internet |
| Type d'adresse IP | IPv4 |
| VPC | `produits-vpc` — cocher les 2 zones → leur sous-réseau **public** |
| Groupes de sécurité | retirer `default`, choisir **`produits-alb-sg`** |
| Écouteur | HTTP : 80 → Transférer vers **`produits-tg`** |

→ **Créer un équilibreur de charge**. Noter le **Nom DNS** : `produits-alb-xxxx.us-east-1.elb.amazonaws.com`.

---

## Étape 9 — Cluster ECS (Console ECS)

**Elastic Container Service → Clusters → Créer un cluster**

| Champ | Valeur |
|---|---|
| Nom du cluster | `produits-cluster` |
| Infrastructure | **AWS Fargate (sans serveur)** uniquement |
| Surveillance | **Container Insights avec observabilité améliorée** |

→ **Créer**. Aucun serveur n'est créé : avec Fargate, AWS fournit la capacité tâche par tâche.

---

## Étape 10 — Définition de tâche (Console ECS)

La définition de tâche = la « recette » du conteneur (≈ un manifest de Pod Kubernetes).

**ECS → Définitions de tâches → Créer une définition de tâche** (formulaire)

### Configuration de la définition de tâche

| Champ | Valeur |
|---|---|
| Famille | `produits` |
| Type de lancement | **AWS Fargate** |
| Système d'exploitation/Architecture | **Linux/X86_64** |
| Taille de la tâche | **0,5 vCPU / 1 Go** |
| Rôle de tâche | *(aucun pour l'instant — voir étape 18)* |
| Rôle d'exécution de tâche | **`ecsTaskExecutionRole`** |

### Conteneur 1

| Champ | Valeur |
|---|---|
| Nom | `produits` |
| URI de l'image | `<compte>.dkr.ecr.us-east-1.amazonaws.com/produits:1.0` |
| Conteneur essentiel | Oui |
| Mappages de ports | Port **8080**, TCP, nom `produits-8080`, protocole d'application **HTTP** |
| Limites d'allocation des ressources | laisser vide (le conteneur utilise toute la tâche) |

**Variables d'environnement** → *Ajouter une variable d'environnement* (5 lignes) :

| Clé | Type de valeur | Valeur |
|---|---|---|
| `DB_HOST` | Valeur | point de terminaison RDS (étape 3.3) |
| `DB_NAME` | Valeur | `produits` |
| `APP_VERSION` | Valeur | `1.0` |
| `DB_USERNAME` | **ValueFrom** | `ARN_DU_SECRET:username::` |
| `DB_PASSWORD` | **ValueFrom** | `ARN_DU_SECRET:password::` |

> ⚠️ **Piège n°1 de la démo** : `DB_USERNAME` **et** `DB_PASSWORD` doivent être en **ValueFrom**.
> En type « Valeur », le conteneur reçoit littéralement la chaîne `arn:aws:secretsmanager:…` comme mot de passe
> → `password authentication failed for user "postgres"` dans les logs, tâches relancées en boucle, ALB en **503**.
> Vérification : onglet **JSON** de la révision → `DB_USERNAME` et `DB_PASSWORD` doivent apparaître sous **`secrets`**, pas sous `environment`.
>
> `ValueFrom` + `ARN:clé::` : au démarrage de la tâche, ECS lit la clé `username` / `password`
> du secret JSON et l'injecte comme variable d'environnement. Le mot de passe n'apparaît **jamais**
> dans la définition de tâche (vérifiable dans l'onglet JSON).

**Collecte de journaux** : ✅ Amazon CloudWatch
- `awslogs-group` = **`/ecs/produits`**, `awslogs-region` = `us-east-1`, `awslogs-stream-prefix` = `ecs`
- **supprimer** la ligne `awslogs-create-group` (le groupe existe déjà, et le rôle n'a pas le droit de le créer)

→ **Créer**. Onglet **JSON** de la révision `produits:1` : observer `secrets`, `environment`, `logConfiguration`.

---

## Étape 11 — Service ECS (Console ECS)

Le service maintient **N tâches** en vie, les inscrit dans l'ALB et gère les mises à jour.

**Clusters → `produits-cluster` → onglet Services → Créer**

| Section | Champ | Valeur |
|---|---|---|
| Environnement | Options de calcul | **Type de lancement** → FARGATE, version LATEST |
| Configuration du déploiement | Type d'application | Service |
| | Famille / Révision | `produits` / dernière |
| | Nom du service | `produits-svc` |
| | Tâches souhaitées | **2** |
| Options de déploiement | Type | Mise à jour propagée (*rolling update*), min **100 %**, max **200 %** |
| Détection d'échec de déploiement | | ✅ **Disjoncteur de déploiement** + ✅ **Restauration en cas d'échec** |
| Mise en réseau | VPC | `produits-vpc` |
| | Sous-réseaux | les **2 publics** uniquement |
| | Groupe de sécurité | **existant** → `produits-app-sg` (retirer `default`) |
| | IP publique | **Activée** |
| Équilibrage de charge | Type | **Application Load Balancer** → **existant** `produits-alb` |
| | Conteneur | `produits 8080:8080` |
| | Écouteur | **existant** `80:HTTP` |
| | Groupe cible | **existant** `produits-tg` |
| | Délai de grâce de la vérification de l'état | **120** secondes |

→ **Créer**. Onglet **Déploiements** puis **Tâches** : 2 tâches *Provisioning* → *Pending* → **Running** (~2 min).

---

## Étape 12 — Tester et observer

### 12.1 L'application

Ouvrir **http://`<Nom DNS de l'ALB>`** — en tapant explicitement **`http://`** :
Chrome tente sinon `https://`, que l'ALB n'écoute pas (pas de certificat) → `ERR_TIMED_OUT`.
- les 3 produits de démonstration (insérés au 1er démarrage dans **RDS**) ;
- **rafraîchir plusieurs fois** : le `Conteneur` du pied de page alterne entre **2 IP** → l'ALB répartit ;
- ajouter un produit → il est visible quelle que soit la tâche qui répond → **état dans la base, pas dans le conteneur**.

> 💡 Le message vert « Produit enregistré » s'affiche parfois, parfois non : il est stocké dans la
> **session HTTP** de la tâche A, et la page suivante est servie par la tâche B.
> Correctif : **EC2 → Groupes cibles → produits-tg → Attributs → Modifier → Rétention de session (stickiness)**
> → *Cookie généré par l'équilibreur de charge*, 1 heure. Bon sujet sur les applications **stateless** !

### 12.2 Dans la console

| Où | Ce qu'on montre |
|---|---|
| **ECS → produits-svc → Tâches** → une tâche | IP privée/publique, définition `produits:1`, conteneur `produits` |
| … → onglet **Journaux** | démarrage Spring Boot : `Started ProduitsApplication`, connexion HikariPool à RDS |
| **ECS → produits-svc → Santé et métriques** | CPU / mémoire du service, requêtes ALB |
| **ECS → produits-svc → Événements** | `registered 2 targets in target-group`, `reached a steady state` |
| **EC2 → Groupes cibles → produits-tg → Cibles** | 2 IP **healthy** = les 2 tâches |
| **CloudWatch → Insights → Container Insights** → ECS | performance du cluster / service / tâche |
| **CloudWatch → Journaux → /ecs/produits** | un flux de logs par tâche |
| **RDS → produits-db → Surveillance** | connexions actives (≈ 20 : 2 pools Hikari de 10), CPU |
| **Secrets Manager → rds!db-…** | rotation automatique gérée par RDS |

> ⚠️ RDS fait **tourner le mot de passe** automatiquement (tous les 7 jours par défaut). Les tâches lisent
> le secret **au démarrage** : après une rotation, faire un *Forcer le nouveau déploiement* du service.

---

## Annexe — Le projet

```
app/
├── Dockerfile                    build multi-étapes (Maven → JRE 21 Alpine)
├── docker-compose.yml            test local avec PostgreSQL
├── pom.xml                       Spring Boot 4.1, Java 21
└── src/main/
    ├── java/com/formation/produits/
    │   ├── ProduitsApplication.java
    │   ├── produit/Produit.java              entité JPA + validation
    │   ├── produit/ProduitRepository.java    Spring Data JPA
    │   ├── produit/DonneesInitiales.java     3 produits insérés si la table est vide
    │   ├── web/ProduitController.java        CRUD /produits
    │   ├── web/AccueilController.java        / → /produits
    │   └── web/InfosConteneur.java           conteneur, version, base → pied de page
    └── resources/
        ├── application.properties            tout est piloté par variables d'environnement
        ├── templates/fragments.html          en-tête / pied de page Thymeleaf
        ├── templates/produits/liste.html
        ├── templates/produits/formulaire.html
        └── static/css/style.css
cli/                                         fichiers JSON utilisés par la partie 2
```

| Variable d'environnement | Rôle | Défaut (local) |
|---|---|---|
| `DB_HOST` / `DB_PORT` / `DB_NAME` | connexion PostgreSQL | `localhost` / `5432` / `produits` |
| `DB_USERNAME` / `DB_PASSWORD` | identifiants (sur AWS : **Secrets Manager**) | `postgres` / `postgres` |
| `APP_VERSION` | badge de version | `dev` |
| `APP_COULEUR` | couleur de l'en-tête | `#2563eb` (bleu) |
