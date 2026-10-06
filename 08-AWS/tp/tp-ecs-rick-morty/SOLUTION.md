# Corrigé formateur — TP Rick & Morty sur ECS Fargate — **version Console AWS**


## Mission 1 — Prendre en main l'application (local)

🖥️ Sur le poste (pas de console AWS ici) :

```bash
git clone https://github.com/mohamedutopios/rick-morty-thymeleaf.git
cd rick-morty-thymeleaf
docker compose up --build
```

→ http://localhost:8080 : badge **LOCAL**, pages Characters / Locations / Episodes.
→ http://localhost:8080/debug/characters : `"ok": true`, `"count": 826`.

---

## Mission 2 — Préparer le réseau (Console VPC + EC2)

### 2.1 Le VPC

**VPC → Créer un VPC → VPC et plus**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Génération automatique des noms | ✅ `rm` | toutes les ressources s'appellent `rm-…` : faciles à retrouver et à supprimer |
| Bloc CIDR IPv4 | `10.0.0.0/16` | plage d'adresses privées du réseau |
| Nombre de zones de disponibilité | **2** | si une zone tombe, ECS relance la tâche dans l'autre |
| Sous-réseaux publics | **2** | la tâche doit être **joignable depuis Internet** (pas de load balancer) |
| Sous-réseaux privés | **0** | inutiles : aucune ressource ne doit être cachée (pas de base de données) |
| Passerelles NAT | **Aucune** | une NAT ne sert qu'aux sous-réseaux privés ; elle coûte ≈ 0,05 $/h même sans trafic |
| Points de terminaison d'un VPC | **Aucun** | la tâche sortira directement par l'Internet Gateway |
| Noms d'hôte DNS / Résolution DNS | ✅ / ✅ | la tâche doit résoudre les noms (ECR, CloudWatch, rickandmortyapi.com) |

→ **Créer un VPC** → **Afficher le VPC**.

✅ Le schéma de l'écran de résultat montre : `rm-vpc`, 2 sous-réseaux `rm-subnet-public1/2`, une table de
routage avec une route `0.0.0.0/0` vers l'Internet Gateway `rm-igw`.

> 💡 Un sous-réseau est « public » parce que sa table de routage envoie `0.0.0.0/0` vers une **Internet Gateway**.

### 2.2 Le groupe de sécurité

**EC2 → Groupes de sécurité → Créer un groupe de sécurité**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Nom | `rm-sg` | |
| Description | `TP Rick and Morty - port 8080` | obligatoire, sans accents de préférence |
| VPC | **`rm-vpc`** ⚠️ | par défaut la console propose un autre VPC : un groupe de sécurité ne peut servir que dans **son** VPC |
| Règle entrante | Type **TCP personnalisé**, port **8080**, source **Mon IP** | seul le port de l'application est ouvert, et seulement pour votre poste (en salle : `0.0.0.0/0` pour que tout le monde teste) |
| Règles sortantes | laisser **Tout le trafic** | la tâche doit **sortir** vers ECR (image), CloudWatch (logs) et rickandmortyapi.com (données) |

→ **Créer un groupe de sécurité**.

> 💡 Pourquoi 8080 et pas 80 : l'application écoute sur 8080 et, sans load balancer, rien ne traduit 80 → 8080.

---

## Mission 3 — Publier l'image (Console ECR + 🖥️ terminal)

### 3.1 Le référentiel (console)

**Elastic Container Registry → Référentiels privés → Créer un référentiel**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Nom du référentiel | `rm-rickandmorty` | l'URI complète sera `<compte>.dkr.ecr.eu-west-3.amazonaws.com/rm-rickandmorty` |
| Mutabilité des balises | Mutable | on peut repousser une image sur le même tag pendant le TP |
| Chiffrement | AES-256 (par défaut) | chiffrement au repos gratuit |

→ **Créer**. Copier l'**URI** du référentiel (bouton de copie à côté du nom).

### 3.2 Pousser l'image (🖥️ terminal, commandes données par la console)

Ouvrir le référentiel → bouton **Afficher les commandes push** : la console donne 4 commandes prêtes à copier.
On les utilise en **adaptant la construction** pour forcer l'architecture des tâches :

```bash
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin <compte>.dkr.ecr.eu-west-3.amazonaws.com
```

```bash
cd rick-morty-thymeleaf
docker buildx build --platform linux/amd64 -t <URI du référentiel>:1.0 --push .
```

> 💡 `--platform linux/amd64` : les tâches seront en **Linux/X86_64** ; sur un Mac Apple Silicon, une image
> construite sans cette option serait **arm64** et la tâche échouerait avec `exec format error`.
> Compter 3 à 5 minutes sur Mac (Maven tourne en émulation).

### 3.3 Vérifier (console)

**ECR → `rm-rickandmorty`** : une image avec la balise **`1.0`**, taille ≈ 100 Mo.

---

## Mission 4 — Décrire et lancer l'application sur ECS

### 4.1 Le rôle d'exécution (Console IAM)

**IAM → Rôles** → rechercher `ecsTaskExecutionRole`.

- **S'il existe** : l'ouvrir et vérifier qu'il a la politique **AmazonECSTaskExecutionRolePolicy**. Rien d'autre à faire.
- **Sinon** : **Créer un rôle** → *Service AWS* → cas d'utilisation **Elastic Container Service** → cocher
  **Elastic Container Service Task** → **Suivant** → cocher **AmazonECSTaskExecutionRolePolicy** → **Suivant**
  → nom `ecsTaskExecutionRole` → **Créer le rôle**.

> 💡 Ce rôle est utilisé par **ECS lui-même** (pas par l'application) pour **télécharger l'image** depuis ECR
> et **envoyer les journaux** à CloudWatch. L'application, elle, n'appelle aucune API AWS : pas besoin de
> *rôle de tâche*.

### 4.2 Le groupe de journaux (Console CloudWatch)

**CloudWatch → Journaux → Groupes de journaux → Créer un groupe de journaux**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Nom | `/ecs/rm-rickandmorty` | convention `/ecs/<application>` |
| Paramètre de rétention | **1 jour** | les logs sont facturés au stockage ; inutile de les garder après le TP |

→ **Créer**.

> 💡 On le crée **avant** la tâche : `AmazonECSTaskExecutionRolePolicy` permet d'écrire dans un groupe
> existant mais **pas d'en créer un**.

### 4.3 Le cluster (Console ECS)

**Elastic Container Service → Clusters → Créer un cluster**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Nom du cluster | `rm-cluster` | |
| Infrastructure | **AWS Fargate (sans serveur)** uniquement | AWS fournit la capacité tâche par tâche : aucun serveur EC2 à gérer |
| Surveillance | laisser désactivé | Container Insights est utile mais payant ; les logs suffisent pour le TP |

→ **Créer**. Le cluster est **Actif** en quelques secondes ; il est vide (aucun serveur n'a été créé).

### 4.4 La définition de tâche (Console ECS)

**ECS → Définitions de tâches → Créer une définition de tâche** (formulaire, pas l'éditeur JSON)

**Configuration de la définition de tâche**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Famille de définition de tâche | `rm-rickandmorty` | nom de la « recette » ; chaque modification créera une **révision** (`:1`, `:2`…) |
| Type de lancement | **AWS Fargate** | |
| Système d'exploitation/Architecture | **Linux/X86_64** | doit correspondre à l'image construite en 3.2 (`linux/amd64`) |
| Mode réseau | `awsvpc` (imposé) | chaque tâche reçoit **sa propre interface réseau** et sa propre IP, comme une petite machine |
| Taille de la tâche | **0,5 vCPU / 1 Go** | imposé par l'énoncé ; suffisant pour une application Spring Boot |
| Rôle de tâche | **aucun** | l'application n'appelle aucune API AWS |
| Rôle d'exécution de tâche | **`ecsTaskExecutionRole`** | rôle de 4.1 : téléchargement de l'image et envoi des logs |

**Conteneur — 1**

| Champ | Valeur | Pourquoi |
|---|---|---|
| Nom | `rickandmorty` | |
| URI de l'image | `<URI du référentiel>:1.0` | l'image poussée en 3.2 (bouton **Parcourir les images ECR** possible) |
| Conteneur essentiel | **Oui** | si ce conteneur s'arrête, la tâche entière s'arrête (et ECS la remplace) |
| Mappages de port | port **8080**, protocole **TCP**, nom `http`, protocole d'application **HTTP** | le port sur lequel écoute Spring Boot |
| Variables d'environnement | **Ajouter** : clé `APP_ENV`, type **Valeur**, valeur `ecs` | affiché dans le badge de la page d'accueil : prouve que la configuration vient d'ECS |

**Collecte de journaux** : ✅ **Utiliser la collecte de journaux** → Amazon CloudWatch, puis dans les options :

| Clé | Valeur | Pourquoi |
|---|---|---|
| `awslogs-group` | `/ecs/rm-rickandmorty` | le groupe créé en 4.2 |
| `awslogs-region` | `eu-west-3` | |
| `awslogs-stream-prefix` | `ecs` | les flux s'appelleront `ecs/rickandmorty/<id de tâche>` |
| `awslogs-create-group` | **supprimer la ligne** | le rôle n'a pas le droit de créer un groupe : la tâche échouerait au démarrage |

**Vérification de l'état (HealthCheck)** — ouvrir la section :

| Champ | Valeur | Pourquoi |
|---|---|---|
| Commande | `CMD-SHELL, wget -q --spider http://localhost:8080/actuator/health \|\| exit 1` | ECS exécute cette commande **dans le conteneur** ; `wget` est présent dans l'image Alpine, pas `curl` |
| Intervalle | `15` | une vérification toutes les 15 s |
| Délai d'expiration | `5` | au-delà, la vérification compte comme un échec |
| Période de démarrage | **`60`** | laisse le temps à Spring Boot de démarrer (≈ 14 s mesurées) sans compter les échecs |
| Nouvelles tentatives | `3` | 3 échecs consécutifs → conteneur *unhealthy* → ECS remplace la tâche |

→ **Créer**. Ouvrir la révision `rm-rickandmorty:1` → onglet **JSON** : repérer `runtimePlatform`,
`portMappings`, `environment`, `healthCheck`, `logConfiguration`.

### 4.5 Le service (Console ECS)

**ECS → Clusters → `rm-cluster` → onglet Services → Créer**

| Section | Champ | Valeur | Pourquoi |
|---|---|---|---|
| Environnement | Options de calcul | **Type de lancement** → **FARGATE**, version **LATEST** | (la *stratégie de fournisseur de capacité* marche aussi, mais le type de lancement est plus explicite) |
| Configuration du déploiement | Type d'application | **Service** | un *service* maintient la tâche en vie en permanence ; une *tâche* simple s'exécute une fois |
| | Famille / Révision | `rm-rickandmorty` / **dernière** | |
| | Nom du service | `rm-service` | |
| | Tâches souhaitées | **1** | ECS garantit qu'**une** tâche tourne toujours |
| Mise en réseau | VPC | **`rm-vpc`** | |
| | Sous-réseaux | les **2 sous-réseaux publics** | la tâche peut démarrer dans l'une ou l'autre zone |
| | Groupe de sécurité | **Utiliser un groupe existant** → `rm-sg`, **retirer `default`** | seul le port 8080 doit être ouvert |
| | IP publique | **Activée** ⚠️ | sans IP publique : pas d'accès depuis le navigateur, et la tâche ne peut même pas télécharger son image (pas de NAT) |
| Équilibrage de charge | | **Aucun** | contrainte du TP |
| Service Connect / découverte de services | | désactivés | une seule application, rien à découvrir |

→ **Créer**.

✅ Onglet **Tâches** du service : la tâche passe de *Provisioning* → *Pending* → **Running** (≈ 1 min),
puis la colonne **Santé** passe de *Unknown* à **Healthy** (après la période de démarrage de 60 s).

> ⚠️ Si la tâche passe à **Stopped** : cliquer dessus → **Motif de l'arrêt** :
> - `CannotPullContainerError` → URI ou tag de l'image incorrect, ou IP publique désactivée ;
> - `ResourceInitializationError … CreateLogGroup` → la ligne `awslogs-create-group` n'a pas été supprimée ;
> - `Essential container exited` + `exec format error` dans les logs → image arm64 sur une tâche X86_64.

---

## Mission 5 — Accéder à l'application

1. **ECS → `rm-cluster` → `rm-service` → onglet Tâches** → cliquer sur l'identifiant de la tâche.
2. Section **Configuration** (ou **Mise en réseau**) : relever l'**IP publique** (ex. `52.47.113.54`).
3. Ouvrir **`http://<IP publique>:8080`** en tapant **`http://`** (Chrome tente `https://` sinon → délai dépassé).

✅ Le badge affiche **ECS** ; Characters (avec filtres), Locations, Episodes fonctionnent ;
`http://<IP>:8080/debug/characters` renvoie `"ok": true` et `"count": 826`.

4. Dans la tâche, onglet **Journaux** : ligne `Started RickAndMortyApplication in 13.992 seconds`.

> 💡 L'IP publique est portée par l'**interface réseau** (ENI) de la tâche : le lien de l'ENI dans la page de
> la tâche ouvre EC2 → Interfaces réseau, où l'on voit la même IP et le groupe de sécurité `rm-sg`.

---

## Mission 6 — Éprouver l'architecture

### 6.1 Panne : arrêter la tâche

1. `rm-service` → onglet **Tâches** → cocher la tâche → **Arrêter** → **Arrêter la sélection**.
2. Onglet **Événements** du service : `has started 1 tasks` quelques secondes plus tard.
3. Onglet **Tâches** : une **nouvelle** tâche → relever sa **nouvelle IP publique** (au test : `52.47.113.54` → `52.47.114.69`).

> 💡 C'est le **planificateur du service** qui maintient 1 tâche. L'adresse change : c'est la
> limite principale de l'architecture sans load balancer.

### 6.2 Montée en charge : 2 tâches

1. `rm-service` → **Mettre à jour le service** → **Tâches souhaitées : 2** → **Mettre à jour**.
2. Onglet **Tâches** : 2 tâches *Running*, avec **2 IP publiques différentes** ; ouvrir les deux.
3. Revenir à **1** de la même façon (ECS arrête l'une des deux).

> 💡 Aucune adresse unique à donner aux utilisateurs : c'est le rôle d'un **Application Load Balancer**.

### 6.3 Nouvelle configuration : `APP_ENV=production`

1. **ECS → Définitions de tâches → `rm-rickandmorty`** → cocher la révision **1** → **Créer une révision**.
2. Conteneur `rickandmorty` → Variables d'environnement : `APP_ENV` = **`production`** → **Créer** → révision **`:2`**.
3. **Clusters → `rm-cluster` → `rm-service` → Mettre à jour le service** → Révision : **2 (dernière)** → **Mettre à jour**.
4. Onglet **Déploiements** : le nouveau déploiement passe à *En cours* puis *Terminé* ; onglet **Tâches** :
   pendant un court moment, **2 tâches** tournent (l'ancienne `:1` et la nouvelle `:2`).
5. Relever l'IP de la **nouvelle** tâche → le badge affiche **PRODUCTION**.

> 💡 Une définition de tâche est **immuable** : on ne la modifie pas, on crée une **révision**. Revenir en
> arrière = remettre le service sur la révision 1.

---

## Mission 8 — Nettoyer (Console)

L'ordre compte : on supprime d'abord ce qui **utilise** le réseau, puis le réseau.

1. **ECS → `rm-cluster` → onglet Services** → cocher `rm-service` → **Supprimer le service** →
   cocher **Forcer la suppression** (le service est d'abord ramené à 0 tâche) → taper `delete` → **Supprimer**.
   Attendre que la liste des services soit vide.
2. **ECS → Clusters → `rm-cluster` → Supprimer le cluster** → taper `delete rm-cluster` → **Supprimer**.
3. **ECS → Définitions de tâches → `rm-rickandmorty`** → cocher **toutes** les révisions →
   **Actions → Désinscrire** ; puis filtrer sur *Inactif*, les cocher → **Supprimer**.
   > 💡 « Désinscrire » rend une révision inutilisable ; seule une révision désinscrite peut être supprimée.
4. **ECR → `rm-rickandmorty`** → **Supprimer** → taper `delete` (les images sont supprimées avec).
5. **CloudWatch → Groupes de journaux → `/ecs/rm-rickandmorty`** → **Actions → Supprimer**.
6. **VPC → Vos VPC → `rm-vpc` → Actions → Supprimer le VPC** → la console liste ce qui sera supprimé avec
   (sous-réseaux, table de routage, Internet Gateway, **groupe de sécurité `rm-sg`**) → taper `delete` → **Supprimer**.
   > ⚠️ Si la console refuse (« dépendances ») : l'interface réseau de la dernière tâche n'est pas encore
   > libérée. Attendre 1 à 2 minutes et recommencer.
7. Ne pas supprimer `ecsTaskExecutionRole` : il est partagé par toutes les applications ECS du compte (et gratuit).

✅ Vérification : **ECS** (aucun cluster `rm-`), **ECR** (aucun référentiel `rm-`), **VPC** (plus de `rm-vpc`),
**EC2 → Interfaces réseau** (aucune interface dans `rm-vpc`).

