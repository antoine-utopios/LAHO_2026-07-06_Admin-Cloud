---
marp: true
title: Admin Cloud — CL-IAC — Jour 1
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# L'infrastructure as code avec Terraform

<img style="width:190px" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTAgNjAuMTUiPgogIDxwYXRoIGNsYXNzPSJ0ZXh0IiBmaWxsPSIjMDAwIiBkPSJNNzcuMzUgNy44NlY0LjYzaC0zdjMuMjNoLTEuNDZWLjExaDEuNTF2My4yNWgzVi4xMWgxLjUxdjcuNzV6bTcgMGgtMS4ybC0uMTEtLjM4YTMuMjggMy4yOCAwIDAgMS0xLjcuNTJjLTEuMDYgMC0xLjUyLS43LTEuNTItMS42NiAwLTEuMTQuNTEtMS41NyAxLjctMS41N2gxLjR2LS42MmMwLS42Mi0uMTgtLjg0LTEuMTEtLjg0YTguNDYgOC40NiAwIDAgMC0xLjYxLjE3TDgwIDIuNDJhNy44OSA3Ljg5IDAgMCAxIDItLjI2YzEuODMgMCAyLjM3LjYyIDIuMzcgMnptLTEuNDMtMi4xMWgtMS4wOGMtLjQ4IDAtLjYxLjEzLS42MS41NXMuMTMuNTYuNTkuNTZhMi4zNyAyLjM3IDAgMCAwIDEuMS0uMjl6TTg3LjQzIDhhNy4xMiA3LjEyIDAgMCAxLTItLjMybC4yLTEuMDdhNi43NyA2Ljc3IDAgMCAwIDEuNzMuMjRjLjY1IDAgLjc0LS4xNC43NC0uNTZzLS4wNy0uNTItMS0uNzNjLTEuNDItLjMzLTEuNTktLjY4LTEuNTktMS43NnMuNDktMS42NSAyLjE2LTEuNjVhOCA4IDAgMCAxIDEuNzUuMmwtLjE0IDEuMTFhMTAuNjYgMTAuNjYgMCAwIDAtMS42LS4xNmMtLjYzIDAtLjc0LjE0LS43NC40OHMwIC40OC44Mi42OGMxLjYzLjQxIDEuNzguNjIgMS43OCAxLjc3Uzg5LjE5IDggODcuNDMgOHptNi42OC0uMTFWNGMwLS4zLS4xMy0uNDUtLjQ3LS40NWE0LjE0IDQuMTQgMCAwIDAtMS41Mi40NXYzLjg2aC0xLjQ2VjBsMS40Ni4yMnYyLjQ3YTUuMzEgNS4zMSAwIDAgMSAyLjEzLS41NGMxIDAgMS4zMi42NSAxLjMyIDEuNjV2NC4wNnptMi42OC02LjM4Vi4xMWgxLjQ2djEuMzd6bTAgNi4zOFYyLjI3aDEuNDZ2NS41OXptMi42Mi01LjU0YzAtMS40Ljg1LTIuMjIgMi44My0yLjIyYTkuMzcgOS4zNyAwIDAgMSAyLjE2LjI1bC0uMTcgMS4yNWExMi4yMSAxMi4yMSAwIDAgMC0xLjk1LS4yYy0xIDAtMS4zNy4zNC0xLjM3IDEuMTZWNS41YzAgLjgxLjMzIDEuMTYgMS4zNyAxLjE2YTEyLjIxIDEyLjIxIDAgMCAwIDEuOTUtLjJsLjE3IDEuMjVhOS4zNyA5LjM3IDAgMCAxLTIuMTYuMjVjLTIgMC0yLjgzLS44MS0yLjgzLTIuMjJ6TTEwNy42MyA4Yy0yIDAtMi41My0xLjA2LTIuNTMtMi4yVjQuMzZjMC0xLjE1LjU0LTIuMiAyLjUzLTIuMnMyLjUzIDEuMDYgMi41MyAyLjJ2MS40MWMuMDEgMS4xNS0uNTMgMi4yMy0yLjUzIDIuMjN6bTAtNC42M2MtLjc4IDAtMS4wOC4zMy0xLjA4IDF2MS41YzAgLjYzLjMgMSAxLjA4IDFzMS4wOC0uMzMgMS4wOC0xVjQuMzFjMC0uNjMtLjMtLjk2LTEuMDgtLjk2em02LjY0LjA5YTExLjU3IDExLjU3IDAgMCAwLTEuNTQuODF2My42aC0xLjQ2di01LjZoMS4yM2wuMS42MmE2LjYzIDYuNjMgMCAwIDEgMS41My0uNzN6TTEyMC4xIDZhMS43MyAxLjczIDAgMCAxLTEuOTIgMiA4LjM2IDguMzYgMCAwIDEtMS41NS0uMTZ2Mi4yNmwtMS40Ni4yMnYtOGgxLjE2bC4xNC40N2EzLjE1IDMuMTUgMCAwIDEgMS44NC0uNTljMS4xNyAwIDEuNzkuNjcgMS43OSAxLjk0em0tMy40OC42M2E2LjcyIDYuNzIgMCAwIDAgMS4yOS4xNWMuNTMgMCAuNzMtLjI0LjczLS43NXYtMmMwLS40Ni0uMTgtLjcxLS43Mi0uNzFhMi4xMSAyLjExIDAgMCAwLTEuMy41MXpNODEuNzggMTkuNTRoLTguODl2LTUuMzFIOTYuN3Y1LjMxaC04Ljl2MjYuNTNoLTZ6Ii8+CiAgPHBhdGggY2xhc3M9InRleHQiIGZpbGw9IiMwMDAiIGQ9Ik0xMDIuMTkgNDEuNzdhMjQuMzkgMjQuMzkgMCAwIDAgNy4xMi0xLjFsLjkxIDQuNGEyNSAyNSAwIDAgMS04LjU2IDEuNDhjLTcuMzEgMC05Ljg1LTMuMzktOS44NS05VjMxLjRjMC00LjkyIDIuMi05LjA4IDkuNjYtOS4wOHM5LjEzIDQuMzUgOS4xMyA5LjM3djVoLTEzdjEuMmMuMDUgMi43OCAxLjA1IDMuODggNC41OSAzLjg4ek05Ny42NSAzMmg3LjQxdi0xLjE4YzAtMi4yLS42Ny0zLjczLTMuNTQtMy43M3MtMy44NyAxLjUzLTMuODcgMy43M3ptMjguNTQtNC4zM2E0NS42NSA0NS42NSAwIDAgMC02LjE5IDMuMzl2MTVoLTUuODNWMjIuNzloNC45MmwuMzggMi41OGEyNi4wOSAyNi4wOSAwIDAgMSA2LjEyLTMuMDZ6bTE0LjI0IDBhNDUuNjUgNDUuNjUgMCAwIDAtNi4xNyAzLjM5djE1aC01LjgzVjIyLjc5aDQuOTJsLjM4IDIuNThhMjYuMDkgMjYuMDkgMCAwIDEgNi4xMi0zLjA2em0xOS41MSAxOC40aC00Ljc4bC0uNDMtMS41OGExMi43MyAxMi43MyAwIDAgMS02LjkzIDIuMDZjLTQuMjUgMC02LjA3LTIuOTItNi4wNy02LjkzIDAtNC43MyAyLjA2LTYuNTUgNi43OS02LjU1aDUuNTl2LTIuNDRjMC0yLjU4LS43Mi0zLjQ5LTQuNDUtMy40OWEzMi41MyAzMi41MyAwIDAgMC02LjQ1LjcybC0uNzItNC40NWEzMC4zOCAzMC4zOCAwIDAgMSA4LTEuMWM3LjMxIDAgOS40NyAyLjU4IDkuNDcgOC40MXptLTUuODMtOC44aC00LjNjLTEuOTEgMC0yLjQ0LjUzLTIuNDQgMi4yOXMuNTMgMi4zNCAyLjM0IDIuMzRhOS4xOCA5LjE4IDAgMCAwIDQuNC0xLjJ6bTIzLjc1LTE5Ljc5YTE3LjExIDE3LjExIDAgMCAwLTMuMzUtLjM4Yy0yLjI5IDAtMi42MyAxLTIuNjMgMi43N3YyLjkyaDUuOTNsLS4zMyA0LjY0aC01LjU5djE4LjY0aC01LjgzVjI3LjQzaC0zLjczdi00LjY0aDMuNzN2LTMuMjVjMC00LjgzIDIuMjUtNy4yMiA3LjQxLTcuMjJhMTguNDcgMTguNDcgMCAwIDEgNSAuNjd6bTExLjM4IDI5LjA3Yy04IDAtMTAuMTMtNC40LTEwLjEzLTkuMTh2LTUuODhjMC00Ljc4IDIuMTUtOS4xOCAxMC4xMy05LjE4czEwLjEzIDQuNCAxMC4xMyA5LjE4djUuODhjLjAxIDQuNzgtMi4xNSA5LjE4LTEwLjEzIDkuMTh6bTAtMTkuMjdjLTMuMTEgMC00LjMgMS4zOS00LjMgNHY2LjI2YzAgMi42MyAxLjIgNCA0LjMgNHM0LjMtMS4zOSA0LjMtNFYzMS4zYzAtMi42My0xLjE5LTQuMDItNC4zLTQuMDJ6bTI1LjE0LjM5YTQ1LjY1IDQ1LjY1IDAgMCAwLTYuMTcgMy4zOXYxNWgtNS44M1YyMi43OWg0LjkybC4zOCAyLjU4YTI2LjA4IDI2LjA4IDAgMCAxIDYuMTItMy4wNnptMTYuMDIgMTguNFYyOS44MmMwLTEuMjQtLjUzLTEuODYtMS44Ni0xLjg2YTE2LjA4IDE2LjA4IDAgMCAwLTYuMDcgMnYxNi4xMWgtNS44M1YyMi43OWg0LjQ1bC41NyAyYTIzLjMyIDIzLjMyIDAgMCAxIDkuMzQtMi40OCA0LjQyIDQuNDIgMCAwIDEgNC40IDIuNDkgMjIuODMgMjIuODMgMCAwIDEgOS4zNy0yLjQ5YzMuODcgMCA1LjI2IDIuNzIgNS4yNiA2Ljg4djE2Ljg4aC01LjgzVjI5LjgyYzAtMS4yNC0uNTMtMS44Ni0xLjg2LTEuODZhMTUuNDMgMTUuNDMgMCAwIDAtNi4wNyAydjE2LjExeiIvPgogIDxwYXRoIGNsYXNzPSJyZWN0LWRhcmsiIGZpbGw9IiM0MDQwQjIiIGQ9Ik0zNi40IDIwLjJ2MTguOTNsMTYuNC05LjQ2VjEwLjcyTDM2LjQgMjAuMnoiLz4KICA8cGF0aCBjbGFzcz0icmVjdC1saWdodCIgZmlsbD0iIzVDNEVFNSIgZD0iTTE4LjIgMTAuNzJsMTYuNCA5LjQ4djE4LjkzbC0xNi40LTkuNDdWMTAuNzJ6Ii8+CiAgPHBhdGggY2xhc3M9InJlY3QtbGlnaHQiIGZpbGw9IiM1QzRFRTUiIGQ9Ik0wIC4xNXYxOC45NGwxNi40IDkuNDdWOS42MkwwIC4xNXptMTguMiA1MC41M2wxNi40IDkuNDdWNDEuMjFsLTE2LjQtOS40N3YxOC45NHoiLz4KPC9zdmc+Cg==" alt="logo"/>

## Vous avez construit le TP2 à la main pendant 4 jours. Plus jamais.

Bloc 11 — CL-IAC — Jour 1 (jour 42 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Expliquer **pourquoi l'IaC** : ce que le clic et le script bash ne savent pas faire.
- Distinguer **déclaratif** et **impératif**, et situer Terraform dans le paysage (CloudFormation, Ansible, Pulumi).
- Lire et écrire du **HCL** : blocs, arguments, attributs, références.
- Configurer un **provider** AWS proprement (versions épinglées, **jamais de clés en dur**).
- Dérouler le cycle complet : `init` → `fmt` → `validate` → `plan` → `apply` → `destroy`.
- **Lire un plan ligne par ligne** — le réflexe n°1 du métier.
- Expliquer ce qu'est le **state**, pourquoi il est **sacré** et pourquoi il ne va **jamais dans git**.
- Reconnaître une **dépendance implicite** et savoir quand `depends_on` est nécessaire.

Livrable du jour : votre premier projet Terraform (`exemples/premier-bucket/`) créé, modifié, **détruit**.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **La douleur** — retour sur le TP2 : 4 jours de CLI, et ce qu'il en reste.
2. **L'infrastructure as code** — définition, déclaratif vs impératif, panorama des outils.
3. **HCL** — anatomie d'un bloc, types de blocs, références.
4. **Providers** — le registry, les versions, l'authentification sans clés.
5. **Le cycle de vie** — init, plan (lecture ligne par ligne), apply, destroy, fmt, validate.
6. **Le state** — la mémoire de Terraform, sacrée, jamais dans git.
7. **Les dépendances** — implicites par référence, explicites par `depends_on`.
8. Récap + quiz.

</div>

---

<!-- _class: lead -->

# 1. La douleur

## Souvenez-vous du TP2

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que le TP2 vous a coûté

<div>

Au bloc CL-TP2, vous avez construit l'architecture 3-tiers de StockLine **à la main, en CLI** :

- `01-create-network.sh` : VPC, 6 sous-réseaux, IGW, NAT GW, tables de routage, 3 security groups — **183 lignes de bash**.
- `02-create-rds.sh` : subnet group, instance PostgreSQL, mot de passe à gérer.
- `03-create-app.sh` : rôle IAM, launch template, ALB, target group, ASG — **244 lignes**.
- `04-create-front.sh` : bucket S3, site statique, politique publique, `sed` sur l'index.html.

Question à la salle : combien de temps pour tout reconstruire demain matin dans une autre région ? Et pour tout **détruire proprement** ce soir ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que le script bash ne sait pas faire

<div>

Vos scripts du TP2 fonctionnaient. Mais ils avaient quatre défauts **structurels** :

- **Pas rejouables** : relancer `01-create-network.sh` crée un **deuxième** VPC. Le script ne sait pas ce qui existe déjà.
- **Pas de marche arrière** : le teardown est un **deuxième script** à écrire et maintenir, dans l'ordre inverse, avec les attentes (`aws ec2 wait ...`).
- **Aveugles à la dérive** : si quelqu'un modifie un security group dans la console, le script n'en saura jamais rien.
- **Impératifs** : ils décrivent **comment** faire, pas **ce que** l'on veut. Toute évolution = relire 400 lignes pour trouver où insérer quoi.

Le clic console est encore pire : rien n'est tracé, rien n'est rejouable, rien n'est relisible.

</div>

---

<style scoped>
div{ font-size:22px }
</style>

## La promesse du jour

<div>

```text
   TP2 (blocs 06-07)                       CL-IAC J3 (après-demain)
   ------------------                      -------------------------
   4 jours de CLI et de scripts            ~300 lignes de HCL lisible
   2 scripts de création + 2 de            terraform apply   (~15 min)
   destruction à maintenir                 terraform destroy (~10 min)
   dérive invisible                        dérive DÉTECTÉE par plan
   "ça marche chez moi"                    le code EST la documentation
```

La même architecture. Le même résultat. Un seul outil : **Terraform**.

</div>

---

<!-- _class: lead -->

# 2. L'infrastructure as code

## Décrire, ne plus construire

---

<style scoped>
div{ font-size:15px }
</style>

## Définition

<div>

**Infrastructure as Code (IaC)** : décrire son infrastructure dans des **fichiers texte versionnés**, et laisser un outil faire converger la réalité vers cette description.

Conséquences immédiates :

- **Versionnable** : l'infra vit dans git — historique, revue de code, retour arrière.
- **Rejouable** : le même code produit la même infra, en dev comme en prod, aujourd'hui comme dans six mois.
- **Auditable** : « qui a ouvert ce port ? » → `git log`, pas une enquête.
- **Détruisible** : ce qui se crée en une commande se détruit en une commande — argument massue en formation 💰.

L'IaC n'est pas un confort : c'est le prérequis de « automatiser, superviser, sécuriser ».

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Déclaratif vs impératif

<div>

**Impératif** (vos scripts bash) : une suite d'ordres. *« Crée un VPC. Puis crée un subnet. Puis attache l'IGW. »* Vous gérez l'ordre, les erreurs, l'existant, la destruction.

**Déclaratif** (Terraform) : un état cible. *« Il doit exister un VPC 10.42.0.0/16 avec 6 sous-réseaux. »* L'outil compare l'état cible à l'état réel et calcule **lui-même** les actions : créer, modifier, détruire.

```text
  impératif : code  = la RECETTE  (comment faire)
  déclaratif: code  = la PHOTO    (ce qui doit exister)
              outil = calcule la différence photo/réalité
```

Vous connaissez déjà un outil déclaratif : **CloudFormation** (bloc 08). Terraform joue dans la même cour — avec des différences importantes.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Panorama des outils

<div>

| Outil | Type | Périmètre | Vous et lui |
|-------|------|-----------|-------------|
| **CloudFormation** | déclaratif | AWS uniquement | lu/écrit au bloc 08 |
| **Terraform** | déclaratif | **multi-fournisseurs** (AWS, Azure, GCP, et ~4000 providers) | ce bloc, J1-J4 |
| **OpenTofu** | déclaratif | fork open source de Terraform (compatible) | à connaître de nom |
| **Pulumi** | déclaratif | multi-fournisseurs, en Python/TS plutôt qu'en HCL | à connaître de nom |
| **Ansible** | plutôt impératif, idempotent | **configuration** des machines | ce bloc, J5-J7 |

Terraform **provisionne** (crée les ressources cloud). Ansible **configure** (l'intérieur des machines). Les deux se complètent — c'est le J7.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi Terraform plutôt que CloudFormation ?

<div>

Vous savez lire du CloudFormation. Pourquoi apprendre Terraform ?

- **Multi-fournisseurs** : le même outil pour AWS **et** Azure (bloc 09) **et** Kubernetes (bloc 13). Une compétence, tous les nuages.
- **HCL** : plus lisible que 800 lignes de YAML/JSON — variables, fonctions, boucles natives.
- **Le plan** : `terraform plan` montre **exactement** ce qui va se passer avant de le faire. Les change sets CloudFormation existent, mais le plan est au cœur du flux de travail Terraform.
- **Le marché** : Terraform est l'outil IaC le plus demandé dans les offres d'emploi admin cloud / DevOps.

À savoir : depuis 2023, Terraform est sous licence BSL (gratuit pour l'utiliser, y compris en entreprise) ; **OpenTofu** en est le fork 100 % open source, quasi identique. Tout ce que vous apprenez ici vaut pour les deux.

</div>

---

<!-- _class: lead -->

# 3. HCL

## Le langage de Terraform

---

<style scoped>
div{ font-size:20px }
</style>

## Anatomie d'un bloc

<div>

```hcl
resource "aws_s3_bucket" "premier" {
  bucket = "abc-iac-premier-bucket"

  tags = {
    Projet = "formation-iac"
  }
}
```

```text
resource        = TYPE DE BLOC   (resource, provider, variable…)
"aws_s3_bucket" = TYPE DE RESSOURCE (préfixé par le provider : aws_)
"premier"       = NOM LOCAL — une étiquette pour VOTRE code,
                  jamais envoyée à AWS
bucket = "..."  = ARGUMENT (clé = valeur)
```

Adresse complète de la ressource : `aws_s3_bucket.premier` — c'est ainsi qu'on la référence partout (code, plan, state).

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Les types de blocs que vous croiserez cette semaine

<div>

| Bloc | Rôle | Exemple |
|------|------|---------|
| `terraform {}` | réglages du projet : versions, backend | `required_version = ">= 1.8.0"` |
| `provider "aws" {}` | configuration du fournisseur | région, `default_tags` |
| `resource "..." "..." {}` | **crée** quelque chose | bucket, VPC, instance |
| `data "..." "..." {}` | **lit** quelque chose d'existant (J2) | dernière AMI AL2023 |
| `variable "..." {}` | entrée paramétrable (J2) | `prefix`, `cidr_vpc` |
| `output "..." {}` | sortie affichée après apply (J2) | URL de l'ALB |
| `locals {}` | valeurs calculées internes (J2) | plan d'adressage |
| `module "..." {}` | appelle un sous-projet réutilisable (J2) | `module "reseau"` |

J1 : les quatre premiers. Le reste arrive demain — chaque chose en son temps.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Arguments et attributs

<div>

- **Argument** : ce que **vous écrivez** dans le bloc (`bucket = "..."`, `instance_type = "t3.micro"`).
- **Attribut** : ce que la ressource **expose** une fois créée. Certains reprennent vos arguments, d'autres ne sont **connus qu'après l'apply** : `arn`, `id`, adresses IP…

```hcl
resource "aws_s3_bucket_versioning" "premier" {
  bucket = aws_s3_bucket.premier.id   # <- référence à un ATTRIBUT
  versioning_configuration {
    status = "Enabled"
  }
}
```

`aws_s3_bucket.premier.id` se lit : « l'attribut `id` de la ressource `premier` de type `aws_s3_bucket` ». Cette référence crée une **dépendance** — on y revient en fin de journée.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Règles de vie des fichiers `.tf`

<div>

- Un projet Terraform = **un dossier**. Terraform charge **tous** les fichiers `.tf` du dossier et les fusionne : le découpage en fichiers est purement humain.
- **L'ordre des blocs n'a aucune importance** : Terraform construit un graphe de dépendances, pas un script. Vous pouvez déclarer le versioning avant le bucket.
- Deux ressources ne peuvent pas porter la même adresse (`aws_s3_bucket.premier` deux fois = erreur).
- Commentaires : `#` (recommandé), `//`, `/* */`.
- Convention de nommage des noms locaux : minuscules et `_` — et un nom qui dit le **rôle** (`aws_s3_bucket.front`), pas le type (`aws_s3_bucket.bucket1`).

Un seul fichier `main.tf` suffit pour commencer — c'est exactement `exemples/premier-bucket/`.

</div>

---

<!-- _class: lead -->

# 4. Providers

## Le pont entre HCL et les API cloud

---

<style scoped>
div{ font-size:15px }
</style>

## Qu'est-ce qu'un provider ?

<div>

Terraform seul ne sait **rien faire**. Un **provider** est un greffon qui traduit vos blocs HCL en appels d'API : le provider `aws` appelle les mêmes API que votre CLI du TP2.

- Distribution : le **Terraform Registry** (`registry.terraform.io`) — ~4000 providers (aws, azurerm, google, kubernetes, random, local…).
- Téléchargé par `terraform init` dans `.terraform/` (plusieurs centaines de Mo : jamais dans git).
- La **documentation du provider** est votre nouvelle référence quotidienne : chaque ressource y liste ses arguments et attributs. Réflexe : chercher « terraform aws_s3_bucket » → premier lien registry.

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## Déclarer et épingler les versions

<div>

```hcl
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}
```

`~> 5.0` = opérateur **pessimiste** : accepte `>= 5.0` et `< 6.0`. Un projet sans contrainte de version finit toujours par casser un matin — nouvelle version majeure du provider, comportements changés, sans que personne n'ait touché au code.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Authentification : JAMAIS de clés dans le code

<div>

Le provider `aws` s'authentifie **exactement comme votre CLI** (même chaîne) :

1. Variables d'environnement `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`.
2. **Profil** : `~/.aws/credentials` via `AWS_PROFILE` (notre méthode en salle).
3. Rôle IAM porté par la machine (instance EC2, exécuteur CI) — la cible en production.

```bash
export AWS_PROFILE=formation
aws sts get-caller-identity     # qui suis-je ? — à vérifier AVANT tout plan
```

```hcl
provider "aws" {
  region     = "eu-west-3"
  access_key = "AKIA..."   # ❌ INTERDIT. Fuite git assurée.
  secret_key = "..."       # ❌ INTERDIT. On en reparle au J4…
}
```

Du code avec des clés en dur part dans git, et git n'oublie **jamais**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 1-1 — Premier projet, cycle complet

<div>

**`demos/11-cl-iac/demo-1-1-premier-projet.md`**

Ce que vous allez voir, sur le projet `code/11-cl-iac/terraform/exemples/premier-bucket/` :

1. Un `main.tf` de 60 lignes : bloc `terraform`, provider, un bucket, son versioning.
2. `terraform init` — ce qui est téléchargé, ce qui apparaît sur le disque.
3. `terraform plan` — **lecture ligne par ligne, à voix haute**.
4. `terraform apply` — et la preuve dans la console AWS.
5. Modification d'un tag → `plan` → un `~` apparaît.
6. `terraform destroy` — et la preuve que tout a disparu.

Pendant la démo : notez chaque symbole (`+`, `~`, `-`) que vous voyez passer.

</div>

---

<!-- _class: lead -->

# 5. Le cycle de vie

## init → plan → apply → destroy

<figure>
<svg viewBox="0 0 660 150" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <defs><marker id="c1" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="10"  y="50" width="90" height="46" rx="8" fill="#438ecc"/><text x="55"  y="78" fill="#fff" text-anchor="middle">write</text>
  <rect x="130" y="50" width="90" height="46" rx="8" fill="#438ecc"/><text x="175" y="78" fill="#fff" text-anchor="middle">init</text>
  <rect x="250" y="50" width="90" height="46" rx="8" fill="#6165ab"/><text x="295" y="78" fill="#fff" text-anchor="middle">plan</text>
  <rect x="370" y="50" width="90" height="46" rx="8" fill="#4caf82"/><text x="415" y="78" fill="#fff" text-anchor="middle">apply</text>
  <rect x="490" y="50" width="120" height="46" rx="8" fill="#d1495b"/><text x="550" y="78" fill="#fff" text-anchor="middle">destroy</text>
  <line x1="100" y1="73" x2="126" y2="73" stroke="#6165ab" stroke-width="2" marker-end="url(#c1)"/>
  <line x1="220" y1="73" x2="246" y2="73" stroke="#6165ab" stroke-width="2" marker-end="url(#c1)"/>
  <line x1="340" y1="73" x2="366" y2="73" stroke="#6165ab" stroke-width="2" marker-end="url(#c1)"/>
  <line x1="460" y1="73" x2="486" y2="73" stroke="#6165ab" stroke-width="2" marker-end="url(#c1)"/>
  <path d="M415 96 L415 128 L55 128 L55 100" fill="none" stroke="#b8c4cf" stroke-width="2" stroke-dasharray="5 4" marker-end="url(#c1)"/>
  <text x="235" y="122" text-anchor="middle" fill="#33404a" font-size="12">on modifie le code, puis on replanifie — en boucle</text>
</svg>
<figcaption>Le cycle de vie Terraform : le code évolue, plan/apply se rejouent</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## `terraform init` — préparer le terrain

<div>

À lancer **une fois par projet** (et après tout changement de providers ou de backend) :

- télécharge les providers requis dans `.terraform/` ;
- écrit `.terraform.lock.hcl` : les **versions exactes** résolues (à **commiter** — reproductibilité pour toute l'équipe) ;
- prépare le backend, c'est-à-dire l'endroit où vivra le state (local par défaut — J4 : S3).

```text
$ terraform init

Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.98.0...
- Installed hashicorp/aws v5.98.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `terraform plan` — LE moment important

<div>

`plan` compare trois choses : votre **code**, le **state** (ce que Terraform croit gérer) et la **réalité** (interrogée via l'API). Il en déduit les actions nécessaires — et **ne fait rien d'autre**.

| Symbole | Action | Gravité |
|---------|--------|---------|
| `+` | **create** — nouvelle ressource | bénin |
| `~` | **update in-place** — modification sans recréation | à lire |
| `-` | **destroy** — suppression | ⚠️ à justifier |
| `-/+` | **replace** — destruction PUIS recréation | 🚨 interruption de service, perte de données possible |

**Règle du bloc, non négociable : on lit le plan ligne par ligne avant tout apply.** Un plan non lu, c'est un `rm -rf` les yeux fermés.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## Lire un plan — sortie réelle (création)

<div>

```text
$ terraform plan

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.premier will be created
  + resource "aws_s3_bucket" "premier" {
      + arn           = (known after apply)
      + bucket        = "abc-iac-premier-bucket"
      + force_destroy = false
      + id            = (known after apply)
      + region        = (known after apply)
      + tags          = {
          + "Name"         = "abc-iac-premier-bucket"
          + "Projet"       = "formation-iac"
          + "Proprietaire" = "abc"
        }
    }

  # aws_s3_bucket_versioning.premier will be created
  + resource "aws_s3_bucket_versioning" "premier" {
      + bucket = (known after apply)
      + id     = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

Trois choses à repérer **systématiquement** : la dernière ligne (`2 to add, 0 to change, 0 to destroy`), chaque symbole, et les `(known after apply)` — valeurs que seul AWS connaîtra.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Lire un plan — sortie réelle (modification et remplacement)

<div>

Modification d'un tag → **update in-place**, inoffensif :

```text
  # aws_s3_bucket.premier will be updated in-place
  ~ resource "aws_s3_bucket" "premier" {
        id     = "abc-iac-premier-bucket"
      ~ tags   = {
          ~ "Projet" = "formation-iac" -> "formation-terraform"
            # (2 unchanged elements hidden)
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Changement du **nom** du bucket → **replace**, destructeur :

```text
  # aws_s3_bucket.premier must be replaced
-/+ resource "aws_s3_bucket" "premier" {
      ~ bucket = "abc-iac-premier-bucket" -> "abc-iac-nouveau-nom" # forces replacement
      ~ arn    = "arn:aws:s3:::abc-iac-premier-bucket" -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

`# forces replacement` : l'argument ne peut pas être modifié à chaud. Sur un bucket **plein**, ce plan détruit les données. C'est écrit noir sur blanc — encore faut-il l'avoir **lu**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `terraform apply` — exécuter le plan

<div>

```text
$ terraform apply

  [... le même plan s'affiche ...]

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.premier: Creating...
aws_s3_bucket.premier: Creation complete after 2s [id=abc-iac-premier-bucket]
aws_s3_bucket_versioning.premier: Creating...
aws_s3_bucket_versioning.premier: Creation complete after 1s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

nom_bucket = "abc-iac-premier-bucket"
arn_bucket = "arn:aws:s3:::abc-iac-premier-bucket"
```

`apply` réaffiche le plan et demande `yes`. **On relit quand même.** (Il existe `-auto-approve` : pas en salle, et en CI uniquement sur un plan déjà approuvé — J4.)

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `terraform destroy` 💰 — le geste du soir

<div>

```text
$ terraform destroy

  # aws_s3_bucket.premier will be destroyed
  - resource "aws_s3_bucket" "premier" { ... }
  # aws_s3_bucket_versioning.premier will be destroyed
  - resource "aws_s3_bucket_versioning" "premier" { ... }

Plan: 0 to add, 0 to change, 2 to destroy.

  Enter a value: yes

Destroy complete! Resources: 2 destroyed.
```

- `destroy` détruit **tout ce que le state connaît** — ni plus, ni moins. Ce qui a été créé à la main dans la console n'est pas concerné.
- Ordre de destruction : **l'inverse** du graphe de création, calculé automatiquement. Vos scripts de teardown du TP2 viennent d'être remplacés.
- **Rituel du bloc : `terraform destroy` chaque soir**, puis vérification console. Une NAT GW oubliée = ~1,20 $ par jour, pour rien.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `fmt` et `validate` — l'hygiène avant le plan

<div>

```bash
terraform fmt -recursive   # met en forme : indentation, alignement des =
terraform validate         # vérifie syntaxe, types, références internes
```

```text
$ terraform validate
Success! The configuration is valid.

$ terraform validate     # avec une référence cassée :
╷
│ Error: Reference to undeclared resource
│
│   on main.tf line 47, in resource "aws_s3_bucket_versioning" "premier":
│   47:   bucket = aws_s3_bucket.premierr.id
│
│ A managed resource "aws_s3_bucket" "premierr" has not been declared.
╵
```

- `fmt` ne change jamais le sens, seulement la forme. Lancez-le avant chaque commit (ou branchez-le dans l'éditeur).
- `validate` ne contacte **pas** AWS : il attrape les fautes de frappe, pas les erreurs de droits ou de quota.
- Enchaînement réflexe : `fmt` → `validate` → `plan` → lecture → `apply`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 1-1 — Lire un plan

<div>

**`exercices/11-cl-iac/exercice-1-1-lire-un-plan.md`** — 30 min, sans machine AWS.

Trois sorties de `terraform plan` vous sont fournies, telles quelles. Pour chacune :

- dire ce qui sera créé, modifié, détruit, **remplacé** ;
- repérer les `(known after apply)` et les `# forces replacement` ;
- répondre à LA question : **« Signeriez-vous cet apply ? »** — et justifier.

L'une des trois sorties contient un piège qui a déjà coûté des données réelles à de vraies équipes. Trouvez-le.

</div>

---

<!-- _class: lead -->

# 6. Le state

## La mémoire de Terraform — sacrée

---

<style scoped>
div{ font-size:15px }
</style>

## Qu'est-ce que le state ?

<div>

Après le premier `apply`, un fichier apparaît : **`terraform.tfstate`**.

C'est la **mémoire** de Terraform : la correspondance entre chaque bloc de votre code et la ressource réelle chez AWS (IDs, ARN, attributs, dépendances).

<figure>
<svg viewBox="0 0 620 220" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="14">
  <rect x="20"  y="20" width="160" height="64" rx="8" fill="#438ecc"/>
  <text x="100" y="46" fill="#fff" text-anchor="middle" font-weight="bold">CODE (.tf)</text>
  <text x="100" y="66" fill="#fff" text-anchor="middle" font-size="12">ce que je veux</text>
  <rect x="230" y="20" width="160" height="64" rx="8" fill="#6165ab"/>
  <text x="310" y="46" fill="#fff" text-anchor="middle" font-weight="bold">STATE (.tfstate)</text>
  <text x="310" y="66" fill="#fff" text-anchor="middle" font-size="12">ce que je gère</text>
  <rect x="440" y="20" width="160" height="64" rx="8" fill="#4caf82"/>
  <text x="520" y="46" fill="#fff" text-anchor="middle" font-weight="bold">RÉALITÉ (AWS)</text>
  <text x="520" y="66" fill="#fff" text-anchor="middle" font-size="12">ce qui existe</text>
  <line x1="100" y1="84" x2="290" y2="150" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="310" y1="84" x2="310" y2="150" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="520" y1="84" x2="330" y2="150" stroke="#b8c4cf" stroke-width="2"/>
  <rect x="200" y="150" width="220" height="44" rx="8" fill="#33404a"/>
  <text x="310" y="178" fill="#fff" text-anchor="middle" font-weight="bold">terraform plan</text>
  <text x="310" y="212" text-anchor="middle" fill="#33404a">compare les trois et calcule la différence</text>
</svg>
<figcaption>Le state relie le code désiré à la réalité AWS</figcaption>
</figure>

Sans state, Terraform ne peut pas savoir que `aws_s3_bucket.premier` **est** le bucket `abc-iac-premier-bucket` : il ne saurait ni le modifier, ni le détruire — seulement en créer un deuxième. Exactement le défaut de vos scripts bash.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le state est sacré — règle n°1

<div>

Ouvrez un `terraform.tfstate` (JSON) : vous y trouverez **tous les attributs de toutes les ressources**, y compris les **secrets en clair** — mot de passe RDS, URLs de connexion, clés générées.

Les trois interdits :

1. **Jamais dans git.** Secrets en clair + git n'est pas un mécanisme de verrouillage : deux membres qui poussent un state chacun = state corrompu, infra ingérable.
2. **Jamais édité à la main.** Un state modifié au bloc-notes = incohérences silencieuses. Il existe des commandes dédiées (`terraform state ...`, J4).
3. **Jamais supprimé « pour repartir propre ».** State perdu = Terraform devient amnésique : les ressources existent, sont facturées 💰, mais plus rien ne les gère.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le `.gitignore` — À écrire AVANT le premier commit

<div>

```gitignore
# Le state et ses sauvegardes : JAMAIS dans git (secrets en clair).
*.tfstate
*.tfstate.*

# Providers téléchargés par init (~500 Mo).
.terraform/

# Plans sauvegardés (contiennent des valeurs sensibles).
*.tfplan

# Fichiers de variables sensibles.
*.auto.tfvars
secret*.tfvars
```

À **versionner** en revanche : les `.tf`, `.terraform.lock.hcl`, et `terraform.tfvars` **s'il ne contient aucun secret** (notre cas, voir J2).

Le `.gitignore` complet et commenté est dans `code/11-cl-iac/terraform/.gitignore` — copiez-le, c'est fait pour.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Et si on perd le state ?

<div>

Scénario (vécu partout) : le laptop meurt, le dossier est supprimé, le state est écrasé.

- Les ressources **existent toujours** chez AWS — et sont **toujours facturées** 💰.
- `terraform plan` propose de **tout recréer** : pour lui, rien n'existe.
- `terraform destroy` ne détruit **rien** : il ne connaît plus rien.
- Il faut soit nettoyer à la main (retour au TP2…), soit **réimporter** ressource par ressource (J4 : blocs `import`).

D'où les deux protections vues au J4 :

1. State **distant** dans S3 (durable, versionné, chiffré, verrouillé).
2. Blocs `import` pour raccrocher un existant au code.

En attendant : le state local reste dans le dossier du projet, point.

</div>

---

<!-- _class: lead -->

# 7. Les dépendances

## Terraform ordonne, vous référencez

---

<style scoped>
div{ font-size:15px }
</style>

## Dépendances implicites — le mécanisme central

<div>

Dans le TP2, **vous** gériez l'ordre : le VPC avant les subnets, l'IGW avant la route… et l'inverse à la destruction.

Avec Terraform, l'ordre découle des **références** :

```hcl
resource "aws_s3_bucket_versioning" "premier" {
  bucket = aws_s3_bucket.premier.id   # <- je référence le bucket
  ...
}
```

Terraform en déduit : *versioning dépend du bucket* → bucket créé **d'abord**, versioning ensuite — et l'inverse au destroy. Aucune ligne de plus à écrire.

L'ensemble des références forme un **graphe** ; les ressources indépendantes sont créées **en parallèle** (d'où la vitesse par rapport à vos scripts séquentiels).

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## `depends_on` — l'exception explicite

<div>

Parfois deux ressources dépendent l'une de l'autre **sans qu'aucune référence ne les lie**. Exemple réel du projet StockLine (module réseau) :

```hcl
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publics[local.azs[0]].id

  # La NAT GW a besoin que l'IGW soit attaché pour router vers
  # Internet, mais AUCUNE référence ne les lie : il faut le dire.
  depends_on = [aws_internet_gateway.igw]
}
```

Règle : **la référence d'abord, `depends_on` en dernier recours** — et toujours avec un commentaire qui explique pourquoi. Un `depends_on` sans justification est un signal de code mal compris (vous en verrez un bel exemple à l'exercice 4-2).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 1-2 — HCL cassé

<div>

**`exercices/11-cl-iac/exercice-1-2-hcl-casse.md`** — 45 min, sur votre sandbox.

Un `main.tf` volontairement cassé vous est fourni : **six erreurs** — syntaxe, références, doublons, types.

Votre mission :

1. `terraform fmt`, `terraform validate`, `terraform plan` — dans cet ordre ;
2. corriger les erreurs **une par une**, en relançant `validate` à chaque fois ;
3. terminer par un `apply` propre… puis un `destroy` vérifié.

Objectif caché : apprendre à **lire les messages d'erreur** de Terraform — ils donnent le fichier, la ligne et souvent la solution. C'est votre futur quotidien.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Récap de la journée

<div>

- L'IaC : décrire l'infra dans du code versionné ; l'outil fait converger la réalité. **Déclaratif** (la photo) vs impératif (la recette).
- HCL : `resource "type" "nom_local" { arguments }` ; les **attributs** (`.id`, `.arn`) sont parfois `(known after apply)`.
- Provider AWS : versions épinglées (`~> 5.0`), authentification par **profil** — **jamais de clés dans le code**.
- Cycle : `init` → `fmt` → `validate` → `plan` → **lecture ligne par ligne** → `apply` → `destroy` 💰 le soir.
- Symboles du plan : `+` créer, `~` modifier, `-` détruire, `-/+` **remplacer** (danger, chercher `# forces replacement`).
- Le **state est sacré** : secrets en clair, jamais dans git, jamais édité, jamais perdu.
- Dépendances : **implicites par référence** ; `depends_on` seulement quand aucune référence n'existe, avec commentaire.

</div>

---

<!-- _class: lead -->

# Quiz de fin de journée

## 10 questions — réponses demain matin

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 1 et 2

<div>

**Question 1.** Quelle commande télécharge les providers et initialise le répertoire de travail d'un projet Terraform ? Que crée-t-elle sur le disque ?

**Question 2.** Dans `resource "aws_s3_bucket" "premier"`, que désigne exactement `"premier"` ? Cette valeur est-elle transmise à AWS ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3.** Dans une sortie de `terraform plan`, que signifie le symbole `-/+` devant une ressource ? Quel commentaire en fin de ligne permet d'identifier l'argument responsable ?

**Question 4.** Donnez deux raisons indépendantes pour lesquelles `terraform.tfstate` ne doit jamais être commité dans git.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5.** Comment Terraform détermine-t-il l'ordre de création de deux ressources, sans que vous écriviez quoi que ce soit ? Comment s'appelle ce mécanisme ?

**Question 6.** Quelle est la différence entre un **argument** et un **attribut** d'une ressource ? Donnez un exemple d'attribut qui affiche `(known after apply)` dans un plan.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7.** Que vérifie `terraform validate` que `terraform fmt` ne vérifie pas ? `validate` a-t-il besoin d'un accès à AWS ?

**Question 8.** La contrainte `version = "~> 5.0"` sur le provider aws autorise quelles versions, exactement ? Pourquoi épingler les versions ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9.** Vous supprimez le bloc `resource "aws_s3_bucket" "premier"` de votre code, puis vous lancez `terraform apply`. Que se passe-t-il, et pourquoi ?

**Question 10.** Citez deux façons **correctes** de fournir des identifiants AWS à Terraform — et la façon strictement interdite.

</div>

---

<!-- _class: lead -->

# À demain

## Jour 2 — variables, data sources, boucles… et votre premier module

Demain, votre projet apprend à se **paramétrer** : variables typées et validées, `for_each` pour ne plus jamais copier-coller trois fois le même bucket, et vous écrirez votre premier **module** — la brique qui nous permettra, après-demain, de recoder **tout le TP2** en une commande.

**Ce soir : `terraform destroy` sur tout ce qui a été appliqué aujourd'hui, puis vérification console.** 💰

