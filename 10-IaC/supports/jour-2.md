---
marp: true
title: Admin Cloud — CL-IAC — Jour 2
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Variables, boucles et modules

<img style="width:190px" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTAgNjAuMTUiPgogIDxwYXRoIGNsYXNzPSJ0ZXh0IiBmaWxsPSIjMDAwIiBkPSJNNzcuMzUgNy44NlY0LjYzaC0zdjMuMjNoLTEuNDZWLjExaDEuNTF2My4yNWgzVi4xMWgxLjUxdjcuNzV6bTcgMGgtMS4ybC0uMTEtLjM4YTMuMjggMy4yOCAwIDAgMS0xLjcuNTJjLTEuMDYgMC0xLjUyLS43LTEuNTItMS42NiAwLTEuMTQuNTEtMS41NyAxLjctMS41N2gxLjR2LS42MmMwLS42Mi0uMTgtLjg0LTEuMTEtLjg0YTguNDYgOC40NiAwIDAgMC0xLjYxLjE3TDgwIDIuNDJhNy44OSA3Ljg5IDAgMCAxIDItLjI2YzEuODMgMCAyLjM3LjYyIDIuMzcgMnptLTEuNDMtMi4xMWgtMS4wOGMtLjQ4IDAtLjYxLjEzLS42MS41NXMuMTMuNTYuNTkuNTZhMi4zNyAyLjM3IDAgMCAwIDEuMS0uMjl6TTg3LjQzIDhhNy4xMiA3LjEyIDAgMCAxLTItLjMybC4yLTEuMDdhNi43NyA2Ljc3IDAgMCAwIDEuNzMuMjRjLjY1IDAgLjc0LS4xNC43NC0uNTZzLS4wNy0uNTItMS0uNzNjLTEuNDItLjMzLTEuNTktLjY4LTEuNTktMS43NnMuNDktMS42NSAyLjE2LTEuNjVhOCA4IDAgMCAxIDEuNzUuMmwtLjE0IDEuMTFhMTAuNjYgMTAuNjYgMCAwIDAtMS42LS4xNmMtLjYzIDAtLjc0LjE0LS43NC40OHMwIC40OC44Mi42OGMxLjYzLjQxIDEuNzguNjIgMS43OCAxLjc3Uzg5LjE5IDggODcuNDMgOHptNi42OC0uMTFWNGMwLS4zLS4xMy0uNDUtLjQ3LS40NWE0LjE0IDQuMTQgMCAwIDAtMS41Mi40NXYzLjg2aC0xLjQ2VjBsMS40Ni4yMnYyLjQ3YTUuMzEgNS4zMSAwIDAgMSAyLjEzLS41NGMxIDAgMS4zMi42NSAxLjMyIDEuNjV2NC4wNnptMi42OC02LjM4Vi4xMWgxLjQ2djEuMzd6bTAgNi4zOFYyLjI3aDEuNDZ2NS41OXptMi42Mi01LjU0YzAtMS40Ljg1LTIuMjIgMi44My0yLjIyYTkuMzcgOS4zNyAwIDAgMSAyLjE2LjI1bC0uMTcgMS4yNWExMi4yMSAxMi4yMSAwIDAgMC0xLjk1LS4yYy0xIDAtMS4zNy4zNC0xLjM3IDEuMTZWNS41YzAgLjgxLjMzIDEuMTYgMS4zNyAxLjE2YTEyLjIxIDEyLjIxIDAgMCAwIDEuOTUtLjJsLjE3IDEuMjVhOS4zNyA5LjM3IDAgMCAxLTIuMTYuMjVjLTIgMC0yLjgzLS44MS0yLjgzLTIuMjJ6TTEwNy42MyA4Yy0yIDAtMi41My0xLjA2LTIuNTMtMi4yVjQuMzZjMC0xLjE1LjU0LTIuMiAyLjUzLTIuMnMyLjUzIDEuMDYgMi41MyAyLjJ2MS40MWMuMDEgMS4xNS0uNTMgMi4yMy0yLjUzIDIuMjN6bTAtNC42M2MtLjc4IDAtMS4wOC4zMy0xLjA4IDF2MS41YzAgLjYzLjMgMSAxLjA4IDFzMS4wOC0uMzMgMS4wOC0xVjQuMzFjMC0uNjMtLjMtLjk2LTEuMDgtLjk2em02LjY0LjA5YTExLjU3IDExLjU3IDAgMCAwLTEuNTQuODF2My42aC0xLjQ2di01LjZoMS4yM2wuMS42MmE2LjYzIDYuNjMgMCAwIDEgMS41My0uNzN6TTEyMC4xIDZhMS43MyAxLjczIDAgMCAxLTEuOTIgMiA4LjM2IDguMzYgMCAwIDEtMS41NS0uMTZ2Mi4yNmwtMS40Ni4yMnYtOGgxLjE2bC4xNC40N2EzLjE1IDMuMTUgMCAwIDEgMS44NC0uNTljMS4xNyAwIDEuNzkuNjcgMS43OSAxLjk0em0tMy40OC42M2E2LjcyIDYuNzIgMCAwIDAgMS4yOS4xNWMuNTMgMCAuNzMtLjI0LjczLS43NXYtMmMwLS40Ni0uMTgtLjcxLS43Mi0uNzFhMi4xMSAyLjExIDAgMCAwLTEuMy41MXpNODEuNzggMTkuNTRoLTguODl2LTUuMzFIOTYuN3Y1LjMxaC04Ljl2MjYuNTNoLTZ6Ii8+CiAgPHBhdGggY2xhc3M9InRleHQiIGZpbGw9IiMwMDAiIGQ9Ik0xMDIuMTkgNDEuNzdhMjQuMzkgMjQuMzkgMCAwIDAgNy4xMi0xLjFsLjkxIDQuNGEyNSAyNSAwIDAgMS04LjU2IDEuNDhjLTcuMzEgMC05Ljg1LTMuMzktOS44NS05VjMxLjRjMC00LjkyIDIuMi05LjA4IDkuNjYtOS4wOHM5LjEzIDQuMzUgOS4xMyA5LjM3djVoLTEzdjEuMmMuMDUgMi43OCAxLjA1IDMuODggNC41OSAzLjg4ek05Ny42NSAzMmg3LjQxdi0xLjE4YzAtMi4yLS42Ny0zLjczLTMuNTQtMy43M3MtMy44NyAxLjUzLTMuODcgMy43M3ptMjguNTQtNC4zM2E0NS42NSA0NS42NSAwIDAgMC02LjE5IDMuMzl2MTVoLTUuODNWMjIuNzloNC45MmwuMzggMi41OGEyNi4wOSAyNi4wOSAwIDAgMSA2LjEyLTMuMDZ6bTE0LjI0IDBhNDUuNjUgNDUuNjUgMCAwIDAtNi4xNyAzLjM5djE1aC01LjgzVjIyLjc5aDQuOTJsLjM4IDIuNThhMjYuMDkgMjYuMDkgMCAwIDEgNi4xMi0zLjA2em0xOS41MSAxOC40aC00Ljc4bC0uNDMtMS41OGExMi43MyAxMi43MyAwIDAgMS02LjkzIDIuMDZjLTQuMjUgMC02LjA3LTIuOTItNi4wNy02LjkzIDAtNC43MyAyLjA2LTYuNTUgNi43OS02LjU1aDUuNTl2LTIuNDRjMC0yLjU4LS43Mi0zLjQ5LTQuNDUtMy40OWEzMi41MyAzMi41MyAwIDAgMC02LjQ1LjcybC0uNzItNC40NWEzMC4zOCAzMC4zOCAwIDAgMSA4LTEuMWM3LjMxIDAgOS40NyAyLjU4IDkuNDcgOC40MXptLTUuODMtOC44aC00LjNjLTEuOTEgMC0yLjQ0LjUzLTIuNDQgMi4yOXMuNTMgMi4zNCAyLjM0IDIuMzRhOS4xOCA5LjE4IDAgMCAwIDQuNC0xLjJ6bTIzLjc1LTE5Ljc5YTE3LjExIDE3LjExIDAgMCAwLTMuMzUtLjM4Yy0yLjI5IDAtMi42MyAxLTIuNjMgMi43N3YyLjkyaDUuOTNsLS4zMyA0LjY0aC01LjU5djE4LjY0aC01LjgzVjI3LjQzaC0zLjczdi00LjY0aDMuNzN2LTMuMjVjMC00LjgzIDIuMjUtNy4yMiA3LjQxLTcuMjJhMTguNDcgMTguNDcgMCAwIDEgNSAuNjd6bTExLjM4IDI5LjA3Yy04IDAtMTAuMTMtNC40LTEwLjEzLTkuMTh2LTUuODhjMC00Ljc4IDIuMTUtOS4xOCAxMC4xMy05LjE4czEwLjEzIDQuNCAxMC4xMyA5LjE4djUuODhjLjAxIDQuNzgtMi4xNSA5LjE4LTEwLjEzIDkuMTh6bTAtMTkuMjdjLTMuMTEgMC00LjMgMS4zOS00LjMgNHY2LjI2YzAgMi42MyAxLjIgNCA0LjMgNHM0LjMtMS4zOSA0LjMtNFYzMS4zYzAtMi42My0xLjE5LTQuMDItNC4zLTQuMDJ6bTI1LjE0LjM5YTQ1LjY1IDQ1LjY1IDAgMCAwLTYuMTcgMy4zOXYxNWgtNS44M1YyMi43OWg0LjkybC4zOCAyLjU4YTI2LjA4IDI2LjA4IDAgMCAxIDYuMTItMy4wNnptMTYuMDIgMTguNFYyOS44MmMwLTEuMjQtLjUzLTEuODYtMS44Ni0xLjg2YTE2LjA4IDE2LjA4IDAgMCAwLTYuMDcgMnYxNi4xMWgtNS44M1YyMi43OWg0LjQ1bC41NyAyYTIzLjMyIDIzLjMyIDAgMCAxIDkuMzQtMi40OCA0LjQyIDQuNDIgMCAwIDEgNC40IDIuNDkgMjIuODMgMjIuODMgMCAwIDEgOS4zNy0yLjQ5YzMuODcgMCA1LjI2IDIuNzIgNS4yNiA2Ljg4djE2Ljg4aC01LjgzVjI5LjgyYzAtMS4yNC0uNTMtMS44Ni0xLjg2LTEuODZhMTUuNDMgMTUuNDMgMCAwIDAtNi4wNyAydjE2LjExeiIvPgogIDxwYXRoIGNsYXNzPSJyZWN0LWRhcmsiIGZpbGw9IiM0MDQwQjIiIGQ9Ik0zNi40IDIwLjJ2MTguOTNsMTYuNC05LjQ2VjEwLjcyTDM2LjQgMjAuMnoiLz4KICA8cGF0aCBjbGFzcz0icmVjdC1saWdodCIgZmlsbD0iIzVDNEVFNSIgZD0iTTE4LjIgMTAuNzJsMTYuNCA5LjQ4djE4LjkzbC0xNi40LTkuNDdWMTAuNzJ6Ii8+CiAgPHBhdGggY2xhc3M9InJlY3QtbGlnaHQiIGZpbGw9IiM1QzRFRTUiIGQ9Ik0wIC4xNXYxOC45NGwxNi40IDkuNDdWOS42MkwwIC4xNXptMTguMiA1MC41M2wxNi40IDkuNDdWNDEuMjFsLTE2LjQtOS40N3YxOC45NHoiLz4KPC9zdmc+Cg==" alt="logo"/>

## Du projet jetable au code d'infrastructure réutilisable

Bloc 11 — CL-IAC — Jour 2 (jour 43 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Déclarer des **variables** typées, documentées, validées — et savoir **où** mettre leurs valeurs.
- Distinguer **variable / local / output**, et employer chacun à bon escient.
- Lire l'existant avec les **data sources** : dernière AMI, zones de disponibilité, identité du compte.
- Créer N ressources avec **`count`** et **`for_each`** — et expliquer pourquoi `for_each` gagne presque toujours.
- Écrire un **module** : contrat d'entrée (variables), corps, contrat de sortie (outputs).
- **Lire un module du registry** (le module VPC officiel) sans le subir.
- Organiser un projet : fichiers standards, environnements multiples.

Livrable du jour : votre module `bucket-securise`, appelé deux fois avec deux configurations.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **Variables** — types, défauts, validation, `sensitive`, où mettre les valeurs.
2. **Outputs et locals** — sortir des valeurs, calculer des valeurs.
3. **Data sources** — lire sans créer : AMI, AZ, identité du compte.
4. **count et for_each** — créer N fois, sans copier-coller.
5. **Modules** — écrire le vôtre, lire ceux du registry.
6. **Organisation** — fichiers standards, gérer plusieurs environnements.
7. Récap + quiz.

Tout le code du jour : `code/11-cl-iac/terraform/exemples/variables-foreach/` et le module `reseau` du fil rouge.

</div>

---

<!-- _class: lead -->

# 1. Variables

## Un projet sans variables ne sert qu'une fois

---

<style scoped>
div{ font-size:15px }
</style>

## Le problème d'hier

<div>

Hier, votre `premier-bucket/main.tf` contenait :

```hcl
resource "aws_s3_bucket" "premier" {
  bucket = "abc-iac-premier-bucket"   # trigramme EN DUR
}
```

Conséquences : chaque apprenant **modifie le code** pour y mettre son trigramme ; impossible de partager le projet, de le rejouer en recette, de changer de région sans éditer les `.tf`.

La règle : **le code décrit la structure, les variables portent ce qui change** — entre personnes, entre environnements, entre régions.

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## Déclarer une variable

<div>

```hcl
variable "prefix" {
  description = "Trigramme de l'apprenant, préfixe de toutes les ressources nommées."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.prefix))
    error_message = "Le préfixe doit contenir 2 à 4 lettres minuscules (ex. : abc)."
  }
}

variable "region" {
  description = "Région AWS de déploiement."
  type        = string
  default     = "eu-west-3"
}
```

Usage : `var.prefix`, `var.region`. Sans `default`, la variable est **obligatoire**. Les quatre champs (`description`, `type`, `default`, `validation`) ne sont pas du zèle : c'est le **contrat** que lit votre collègue — ou vous, dans six mois.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le catalogue des types

<div>

| Type | Exemple de valeur | Usage typique |
|------|-------------------|---------------|
| `string` | `"eu-west-3"` | noms, régions, CIDR |
| `number` | `2` | tailles, capacités, ports |
| `bool` | `true` | activer/désactiver (multi_az…) |
| `list(string)` | `["subnet-a", "subnet-b"]` | IDs ordonnés |
| `map(string)` | `{ Projet = "stockline" }` | tags, paires clé/valeur |
| `object({...})` | voir ci-dessous | configuration structurée |

```hcl
variable "environnements" {
  type = map(object({
    criticite  = string
    versioning = bool
  }))
}
```

Une `map(object)` = **un catalogue configurable** — c'est elle qui alimentera `for_each` tout à l'heure.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Où mettre les valeurs ? (ordre de précédence)

<div>

Du plus faible au plus fort (le dernier gagne) :

1. `default` de la déclaration ;
2. variables d'environnement `TF_VAR_prefix=abc` ;
3. **`terraform.tfvars`** (chargé automatiquement) — notre standard ;
4. `*.auto.tfvars` (chargés automatiquement, ordre alphabétique) ;
5. `-var-file=recette.tfvars` puis `-var="prefix=abc"` en ligne de commande.

```hcl
# terraform.tfvars — les VALEURS de l'environnement dev
prefix        = "abc"
region        = "eu-west-3"
environnement = "dev"
```

Notre `terraform.tfvars` ne contient **aucun secret** → il est commité. Un tfvars avec secrets ne l'est jamais (motif `secret*.tfvars` du `.gitignore`).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `sensitive` — masquer, pas protéger

<div>

```hcl
variable "mot_de_passe_db" {
  description = "À NE PAS UTILISER : exemple pédagogique. Voir SSM au J3/J4."
  type        = string
  sensitive   = true
}
```

Ce que `sensitive = true` **fait** : masque la valeur dans les sorties de `plan`/`apply` (`(sensitive value)`), et Terraform refuse de l'afficher dans un output non marqué.

Ce que `sensitive` **ne fait PAS** : la valeur reste **en clair dans le state**. `sensitive` protège vos écrans (démos, journaux de CI), pas vos secrets.

La vraie stratégie secrets (fil rouge) : **générer** (`random_password`), **stocker** (SSM SecureString), **lire au démarrage** via un rôle IAM — le mot de passe ne transite jamais par un humain. Démonstration complète demain au J3.

</div>

---

<!-- _class: lead -->

# 2. Outputs et locals

## Sortir des valeurs, calculer des valeurs

---

<style scoped>
div{ font-size:16px }
</style>

## Outputs — ce que le projet expose

<div>

```hcl
output "url_api" {
  description = "URL publique de l'API StockLine (via l'ALB)."
  value       = "http://${module.app.dns_alb}"
}
```

```text
$ terraform output
url_api  = "http://abc-iac-alb-1234567890.eu-west-3.elb.amazonaws.com"
$ terraform output -raw url_api      # pour les scripts (curl, CI…)
```

- Affichés en fin d'apply, relisibles à tout moment (`terraform output`) — stockés… **dans le state**, comme tout le reste.
- Trois usages : information pour l'humain, entrée pour un script, et surtout **contrat de sortie d'un module** (section 5).
- Remarquez l'**interpolation** : `"http://${...}"` insère une expression dans une chaîne.

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## Locals — les valeurs calculées

<div>

```hcl
locals {
  # "eu-west-3a" -> "a" : pour des tags Name courts et lisibles.
  suffixe_az = { for az in local.azs : az => substr(az, length(az) - 1, 1) }

  # cidrsubnet(10.42.0.0/16, 8, N) -> 10.42.N.0/24
  subnets_publics = { for i, az in local.azs : az => cidrsubnet(var.cidr_vpc, 8, i) }
}
```

(extrait réel de `modules/reseau/main.tf` — votre plan d'adressage du TP2, calculé au lieu d'être tapé)

- Un `local` = une valeur **interne**, calculée une fois, réutilisée partout : `local.subnets_publics`.
- Usage : éviter la répétition, nommer un calcul, dériver (CIDR → sous-réseaux).
- Au passage : les **fonctions** Terraform (`cidrsubnet`, `substr`, `merge`, `file`, `jsonencode`…) — catalogue dans la doc, test interactif avec `terraform console`.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## variable vs local vs output — le tableau à mémoriser

<div>

| | `variable` | `locals` | `output` |
|---|-----------|----------|----------|
| Rôle | **entrée** paramétrable | valeur **interne** calculée | **sortie** exposée |
| Qui fixe la valeur ? | l'appelant (tfvars, CLI…) | le code lui-même | le code lui-même |
| Référence | `var.nom` | `local.nom` | `module.X.nom` (depuis l'appelant) |
| Analogie fonction | paramètre | variable locale | valeur de retour |

Anti-motifs classiques :

- une `variable` avec `default` jamais surchargée et non destinée à l'être → c'était un `local` ;
- un calcul copié-collé trois fois → c'était un `local` ;
- un collègue qui vous demande un ID « affiché dans la console » → c'était un `output`.

</div>

---

<!-- _class: lead -->

# 3. Data sources

## Lire l'existant sans le gérer

---

<style scoped>
div{ font-size:15px }
</style>

## `data` — la lecture seule

<div>

Un bloc `data` **interroge** l'API et expose le résultat. Il ne crée rien, ne modifie rien, ne détruit rien — il **lit**, à chaque plan.

```hcl
data "aws_caller_identity" "actuel" {}

resource "aws_s3_bucket" "front" {
  # Le nom d'un bucket est MONDIALEMENT unique : on suffixe par l'ID de compte.
  bucket = "${var.prefix}-iac-front-${data.aws_caller_identity.actuel.account_id}"
}
```

Référence : `data.<type>.<nom>.<attribut>` — notez le préfixe `data.`.

Cas d'usage : tout ce qui existe **hors de votre projet** — le compte, les AZ de la région, une AMI, un VPC créé par une autre équipe, un paramètre SSM.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## L'AMI : le cas d'école — jamais d'ID en dur

<div>

Un `ami-064736ff8301af3ee` en dur : invalide dans une autre région, obsolète à la prochaine rotation d'images. Deux solutions propres :

```hcl
# 1. Recherche par filtres (utilisée dans modules/app/main.tf) :
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
}

# 2. Paramètre SSM public maintenu par AWS (équivalent) :
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
```

Usage : `data.aws_ami.al2023.id`. Piège à connaître : `most_recent = true` signifie qu'une **nouvelle AMI publiée** fera apparaître un `-/+` sur les ressources qui l'utilisent au prochain plan — le plan vous le **dira**, encore faut-il le lire.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les AZ : rester portable

<div>

```hcl
# modules/reseau/main.tf — extrait réel
data "aws_availability_zones" "disponibles" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.disponibles.names, 0, var.nb_az)
}
```

- On ne code **jamais** `"eu-west-3a"` en dur : le module fonctionne dans n'importe quelle région, avec 2 ou 3 AZ (`var.nb_az`).
- `slice(liste, 0, 2)` : les 2 premières AZ disponibles.
- Combiné aux `locals` de tout à l'heure : **le plan d'adressage complet du TP2 tient en 5 lignes calculées**.

Les trois data sources du fil rouge : `aws_caller_identity`, `aws_availability_zones`, `aws_ami`. Vous venez de lire du vrai code de production.

</div>

---

<!-- _class: lead -->

# 4. count et for_each

## Créer N fois sans copier-coller

---

<style scoped>
div{ font-size:16px }
</style>

## `count` — N copies numérotées

<div>

```hcl
resource "aws_s3_bucket" "journaux" {
  count = var.nb_buckets_journaux          # 3

  bucket = "${var.prefix}-iac-journaux-${count.index}"   # 0, 1, 2
}
```

Adresses créées : `aws_s3_bucket.journaux[0]`, `[1]`, `[2]`.

Second usage, très courant — la **ressource conditionnelle** (0 ou 1 copie) :

```hcl
# main.tf du fil rouge : le front n'est déployé que si un index.html est fourni.
resource "aws_s3_object" "front_index" {
  count = var.chemin_front_index == "" ? 0 : 1
  ...
}
```

`condition ? valeur_si_vrai : valeur_si_faux` — l'expression conditionnelle de HCL.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le piège de `count` — pourquoi il détruit vos ressources

<div>

Trois buckets par `count`, puis vous supprimez le **premier** de la liste :

```text
  # aws_s3_bucket.journaux[0] will be updated in-place    <- [1] devient [0] !
  ~ resource "aws_s3_bucket" "journaux" {
      ~ bucket = "abc-iac-journaux-0" -> "abc-iac-journaux-1" # forces replacement
    }
  # aws_s3_bucket.journaux[2] will be destroyed
  - resource "aws_s3_bucket" "journaux" { ... }

Plan: 1 to add, 0 to change, 2 to destroy.
```

Les éléments sont identifiés par leur **position**. Supprimer l'élément 0 **décale tous les suivants** → Terraform remplace/détruit des ressources **que vous n'avez pas touchées**. Sur des buckets de données, c'est un incident.

**Règle du bloc : `for_each` par défaut ; `count` réservé à la ressource conditionnelle (0/1) et aux copies réellement interchangeables.**

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## `for_each` — une copie par clé, adresses stables

<div>

```hcl
resource "aws_s3_bucket" "environnements" {
  for_each = var.environnements     # map : dev, recette, prod

  bucket = "${var.prefix}-iac-${each.key}-donnees"

  tags = {
    Environnement = each.key                  # "dev"
    Criticite     = each.value.criticite      # champ de l'objet
  }
}
```

Adresses créées : `aws_s3_bucket.environnements["dev"]`, `["recette"]`, `["prod"]`.

Supprimez `recette` de la map : le plan détruit **uniquement** `["recette"]`. `dev` et `prod` ne bougent pas — leurs clés n'ont pas changé. C'est **toute** la différence avec `count`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `for` + filtre : la composition qui fait tout

<div>

Besoin réel : activer le versioning **seulement** sur les environnements qui le demandent.

```hcl
resource "aws_s3_bucket_versioning" "environnements" {
  for_each = { for nom, env in var.environnements : nom => env if env.versioning }

  bucket = aws_s3_bucket.environnements[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}
```

- L'expression `{ for k, v in map : k => v if condition }` **filtre** la map.
- `aws_s3_bucket.environnements[each.key]` : on référence la copie **de la même clé** — la dépendance implicite suit chaque paire bucket/versioning.
- Le module `reseau` du fil rouge utilise exactement ce motif pour ses sous-réseaux : `for_each` sur une map `az => cidr`.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## Sortie de plan réelle — for_each sur 3 environnements

<div>

```text
$ terraform plan

  # aws_s3_bucket.environnements["dev"] will be created
  + resource "aws_s3_bucket" "environnements" {
      + bucket = "abc-iac-dev-donnees"
      + tags   = {
          + "Criticite"     = "basse"
          + "Environnement" = "dev"
        }
    }

  # aws_s3_bucket.environnements["prod"] will be created
  + resource "aws_s3_bucket" "environnements" {
      + bucket = "abc-iac-prod-donnees"
    }

  # aws_s3_bucket.environnements["recette"] will be created
  + resource "aws_s3_bucket" "environnements" {
      + bucket = "abc-iac-recette-donnees"
    }

  # aws_s3_bucket_versioning.environnements["prod"] will be created
  + resource "aws_s3_bucket_versioning" "environnements" { ... }

  # aws_s3_bucket_versioning.environnements["recette"] will be created
  + resource "aws_s3_bucket_versioning" "environnements" { ... }

Plan: 5 to add, 0 to change, 0 to destroy.
```

À lire dans le plan : **5** ressources (3 buckets + **2** versioning — `dev` est filtré par le `if`), et des adresses par **clé**, pas par index.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2-2 — for_each et environnements

<div>

**`exercices/11-cl-iac/exercice-2-2-foreach-environnements.md`** — 45 min.

Sur `code/11-cl-iac/terraform/exemples/variables-foreach/` :

1. **Prédire** le plan avant de le lancer (combien de `+` ? quelles adresses ?) — puis vérifier.
2. Ajouter un environnement `preprod` **sans toucher à main.tf** (indice : c'est le but des variables).
3. Supprimer `dev`… et comparer avec ce qu'aurait fait `count` dans la même situation.
4. Convertir les buckets `journaux` de `count` vers `for_each`.

À chaque étape : le **plan d'abord**, la prédiction avant le plan, l'apply seulement si le plan correspond à la prédiction.

</div>

---

<!-- _class: lead -->

# 5. Modules

## La fonction réutilisable de l'infrastructure

<figure>
<svg viewBox="0 0 560 190" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <defs><marker id="mi" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="30" y="70" width="150" height="56" rx="8" fill="#6165ab"/>
  <text x="105" y="94" fill="#fff" text-anchor="middle" font-weight="bold">module</text>
  <text x="105" y="114" fill="#fff" text-anchor="middle" font-size="12">bucket-securise</text>
  <rect x="380" y="15"  width="160" height="46" rx="8" fill="#438ecc"/><text x="460" y="43"  fill="#fff" text-anchor="middle">sauvegardes</text>
  <rect x="380" y="72"  width="160" height="46" rx="8" fill="#438ecc"/><text x="460" y="100" fill="#fff" text-anchor="middle">journaux</text>
  <rect x="380" y="129" width="160" height="46" rx="8" fill="#438ecc"/><text x="460" y="157" fill="#fff" text-anchor="middle">archives</text>
  <line x1="180" y1="90" x2="376" y2="38"  stroke="#6165ab" stroke-width="2" marker-end="url(#mi)"/>
  <line x1="180" y1="98" x2="376" y2="95"  stroke="#6165ab" stroke-width="2" marker-end="url(#mi)"/>
  <line x1="180" y1="106" x2="376" y2="152" stroke="#6165ab" stroke-width="2" marker-end="url(#mi)"/>
  <text x="105" y="150" text-anchor="middle" fill="#33404a" font-size="12">écrit une fois</text>
</svg>
<figcaption>Un module réutilisable, appelé plusieurs fois avec des configurations différentes</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## Qu'est-ce qu'un module ?

<div>

Un **module** = un dossier de fichiers `.tf` **appelable** avec des paramètres. La fonction du monde Terraform :

<figure>
<svg viewBox="0 0 620 170" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <defs><marker id="m1" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="20"  y="55" width="150" height="60" rx="8" fill="#438ecc"/>
  <text x="95" y="80" fill="#fff" text-anchor="middle" font-weight="bold">variables.tf</text>
  <text x="95" y="100" fill="#fff" text-anchor="middle" font-size="12">contrat d'ENTRÉE</text>
  <rect x="235" y="35" width="150" height="100" rx="8" fill="#6165ab"/>
  <text x="310" y="80" fill="#fff" text-anchor="middle" font-weight="bold">main.tf</text>
  <text x="310" y="100" fill="#fff" text-anchor="middle" font-size="12">le corps</text>
  <rect x="450" y="55" width="150" height="60" rx="8" fill="#4caf82"/>
  <text x="525" y="80" fill="#fff" text-anchor="middle" font-weight="bold">outputs.tf</text>
  <text x="525" y="100" fill="#fff" text-anchor="middle" font-size="12">contrat de SORTIE</text>
  <line x1="170" y1="85" x2="231" y2="85" stroke="#6165ab" stroke-width="2" marker-end="url(#m1)"/>
  <line x1="385" y1="85" x2="446" y2="85" stroke="#6165ab" stroke-width="2" marker-end="url(#m1)"/>
  <text x="310" y="25" text-anchor="middle" fill="#33404a" font-weight="bold">module = une fonction d'infrastructure</text>
  <text x="310" y="158" text-anchor="middle" fill="#33404a" font-size="12">les paramètres → les ressources → les valeurs de retour</text>
</svg>
<figcaption>Un module : entrée (variables) + corps (main) + sortie (outputs)</figcaption>
</figure>

- Votre projet racine est déjà un module (le « root module »). Un module enfant vit dans `modules/<nom>/`.
- **Encapsulation** : depuis l'extérieur, seules les sorties (`outputs`) sont visibles. L'appelant ne connaît ni les ressources internes ni leurs noms.
- Pourquoi ? Réutiliser (un module `reseau` pour tous les projets), standardiser (impossible de créer un bucket public avec le module `bucket-securise`), diviser pour raisonner (3 modules de 80 lignes > 1 fichier de 500).

</div>

---

<style scoped>
div{ font-size:16px }
</style>

## Appeler un module

<div>

```hcl
# main.tf du fil rouge StockLine — extrait réel
module "reseau" {
  source = "./modules/reseau"    # chemin local

  prefix   = var.prefix          # on remplit le contrat d'entrée
  cidr_vpc = var.cidr_vpc
}

module "donnees" {
  source = "./modules/donnees"

  prefix        = var.prefix
  subnet_ids_db = module.reseau.subnet_ids_db   # sortie d'un module
  sg_db_id      = module.reseau.sg_db_id        #   -> entrée d'un autre
  classe_db     = var.classe_db
}
```

`module.reseau.subnet_ids_db` : la sortie `subnet_ids_db` du module `reseau`. Cette référence crée une **dépendance implicite entre modules** : réseau d'abord, données ensuite. Après un ajout/changement de module : relancer `terraform init`.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Écrire un module : le contrat d'abord

<div>

Extraits réels de `modules/reseau/` (fil rouge) :

```hcl
# variables.tf — contrat d'entrée
variable "cidr_vpc" {
  description = "Plage IPv4 du VPC. Les /24 des sous-réseaux en sont dérivés (cidrsubnet)."
  type        = string
}

variable "nb_az" {
  description = "Nombre de zones de disponibilité à utiliser."
  type        = number
  default     = 2

  validation {
    condition     = var.nb_az >= 2 && var.nb_az <= 3
    error_message = "nb_az doit valoir 2 ou 3 (haute disponibilité sans explosion de coûts)."
  }
}
```

```hcl
# outputs.tf — contrat de sortie
output "vpc_id" {
  description = "Identifiant du VPC."
  value       = aws_vpc.principal.id
}

output "subnet_ids_db" {
  description = "Identifiants des sous-réseaux base de données privés."
  value       = [for s in aws_subnet.db : s.id]
}
```

Méthode : écrire **d'abord** variables.tf et outputs.tf (le contrat), **ensuite** main.tf (l'implémentation). Comme une signature de fonction.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 2-1 — Le module réseau, de l'intérieur

<div>

**`demos/11-cl-iac/demo-2-1-module-reseau.md`**

Visite guidée de `modules/reseau/` — le `01-create-network.sh` du TP2 (183 lignes de bash) devenu module déclaratif :

1. Le contrat : `variables.tf` (3 entrées) et `outputs.tf` (8 sorties).
2. Le plan d'adressage **calculé** : `data` AZ + `cidrsubnet` dans des `locals`.
3. Les sous-réseaux en `for_each` sur des maps `az => cidr`.
4. Le `depends_on` NAT GW → IGW (revu hier, en situation réelle).
5. Appel depuis un projet vierge → `terraform plan` : **22 ressources** en 6 lignes d'appel.

À suivre avec le code ouvert : `code/11-cl-iac/terraform/modules/reseau/main.tf`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Lire un module du registry — le module VPC officiel

<div>

Vous écrirez des modules ; vous en **consommerez** davantage. Le plus utilisé au monde :

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"                      # OBLIGATOIRE pour un module registry

  name            = "abc-iac-vpc"
  cidr            = "10.42.0.0/16"
  azs             = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnets = ["10.42.10.0/24", "10.42.11.0/24"]

  enable_nat_gateway = true    # 💰 il sait aussi créer ce qui coûte…
  single_nat_gateway = true
}
```

Méthode de lecture d'un module registry : la page du module → onglet **Inputs** (que puis-je régler ? quels défauts ?) → onglet **Outputs** (que puis-je récupérer ?). On lit le contrat, pas les 3000 lignes du corps — mais on **lit le plan** qu'il génère avant d'appliquer, comme toujours.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Notre module réseau ou celui du registry ?

<div>

| | `./modules/reseau` (le nôtre) | `terraform-aws-modules/vpc/aws` |
|---|---|---|
| Lignes à comprendre | ~230, toutes lues en démo | ~3000, on lit le contrat |
| Couverture | notre besoin, exactement | ~150 options, tous les cas |
| Maintenance | nous | la communauté (mises à jour !) |
| Pédagogie | ✅ on apprend | ❌ boîte noire |

En entreprise : privilégier les modules éprouvés du registry pour le standard (VPC, EKS, RDS), écrire les vôtres pour ce qui est **métier**. En formation : on écrit le nôtre pour comprendre ce que le registry nous cache.

Dans le fil rouge StockLine : modules maison — vous devez pouvoir expliquer **chaque ressource** de votre infra au J3.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2-1 — Votre module `bucket-securise`

<div>

**`exercices/11-cl-iac/exercice-2-1-module-bucket-securise.md`** — 1 h 15.

Écrire un module qui encapsule les 4 réflexes S3 vus au bloc AWS1 :

1. accès public **totalement bloqué** (non désactivable par l'appelant — c'est le but) ;
2. chiffrement au repos (SSE-S3) ;
3. versioning activable (`bool`, actif par défaut) ;
4. tags systématiques + expiration optionnelle (`number`, 0 = désactivée).

Puis l'appeler **deux fois** : un bucket `sauvegardes` (versionné, expiration 30 j) et un bucket `journaux` (non versionné, expiration 7 j).

C'est le motif le plus demandé en entreprise : le module « opinionated » qui rend la mauvaise configuration **impossible**.

</div>

---

<!-- _class: lead -->

# 6. Organisation du projet

## Des fichiers standards et des environnements

---

<style scoped>
div{ font-size:14px }
</style>

## Les fichiers standards d'un projet

<div>

La convention (celle du fil rouge, celle de l'écosystème) :

```text
terraform/
├── versions.tf        # bloc terraform : required_version, required_providers
├── providers.tf       # provider "aws" : région, default_tags
├── backend.tf         # où vit le state (local J1-J3, S3 au J4)
├── variables.tf       # contrat d'entrée du projet
├── terraform.tfvars   # valeurs de l'environnement courant (si aucun secret)
├── main.tf            # les ressources / l'assemblage des modules
├── outputs.tf         # contrat de sortie
├── .gitignore         # state, .terraform/, tfvars sensibles
├── .terraform.lock.hcl  # versions exactes des providers — COMMITÉ
└── modules/
    ├── reseau/        #   chaque module : variables.tf + main.tf + outputs.tf
    ├── donnees/
    └── app/
```

Terraform s'en moque (il fusionne tout) — **les humains, non**. Un collègue doit savoir où regarder sans ouvrir un seul fichier.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Plusieurs environnements : trois stratégies

<div>

**1. Un tfvars par environnement** (notre choix pour le bloc) :

```bash
terraform plan -var-file=dev.tfvars
terraform plan -var-file=recette.tfvars
```

Simple, mais ⚠️ un seul state pour tous : appliquer `recette.tfvars` par-dessus dev **transforme** dev en recette. Discipline requise.

**2. Un dossier par environnement** (le standard en entreprise) : `environnements/dev/` et `environnements/recette/`, chacun avec son tfvars **et son state**, tous deux appelant les **mêmes modules**. Isolation complète.

**3. Workspaces** (`terraform workspace`) : plusieurs states pour un même code. À connaître de nom ; pièges nombreux (quel workspace suis-je en train de détruire ?), on ne les utilise pas dans ce bloc.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le fil rouge est prêt pour demain

<div>

Ouvrez `code/11-cl-iac/terraform/` : tout ce qui a été vu aujourd'hui y est en situation réelle.

- `variables.tf` : 10 variables typées, validées, documentées.
- `terraform.tfvars` : vos valeurs dev — **aucun secret dedans**, donc commité.
- `main.tf` : 3 appels de modules + le front S3, dépendances implicites entre modules.
- `modules/reseau` : data AZ, locals `cidrsubnet`, `for_each`, `depends_on`.
- `modules/donnees` et `modules/app` : au programme de demain.

Demain : on **applique tout**, étape par étape, plan par plan — et l'architecture du TP2 renaît en 15 minutes.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Récap de la journée

<div>

- **Variables** : `type` + `description` + `validation` = le contrat. Valeurs dans `terraform.tfvars` (commité **si** aucun secret). `sensitive` masque l'affichage, **pas** le state.
- **variable / local / output** = paramètre / variable interne / valeur de retour.
- **Data sources** : lire sans créer — `aws_ami` (jamais d'ID en dur), `aws_availability_zones` (jamais d'AZ en dur), `aws_caller_identity`.
- **`for_each` par défaut** : adresses par clé, stables. `count` : ressource conditionnelle (0/1) et copies interchangeables. Le décalage d'index de `count` détruit des ressources.
- **Module** = variables.tf (entrée) + main.tf + outputs.tf (sortie). L'appelant ne voit que les sorties : `module.reseau.vpc_id`. Modules registry : lire Inputs/Outputs, épingler `version`.
- Fichiers standards + un state **par environnement** dès que c'est sérieux.

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

**Question 1.** Complétez l'analogie avec une fonction : `variable` = paramètre, `output` = ..., `locals` = ... Quelle syntaxe pour référencer chacun des trois ?

**Question 2.** Citez, dans l'ordre de chargement automatique, deux endroits où Terraform va chercher la valeur d'une variable sans aucune option de ligne de commande. Que se passe-t-il si une variable sans `default` ne reçoit aucune valeur ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3.** Qu'est-ce qu'un bloc `data` ? Crée-t-il quelque chose chez AWS ? Donnez deux exemples utilisés dans le projet StockLine.

**Question 4.** Pourquoi ne faut-il jamais écrire un ID d'AMI en dur dans le code ? Quel est le petit inconvénient de `most_recent = true`, et comment le plan vous en protège-t-il ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5.** Vous avez 3 buckets créés par `count`. Vous supprimez le premier élément de la liste. Que montre le plan, et pourquoi ? Qu'aurait montré le même scénario avec `for_each` ?

**Question 6.** Avec `for_each` sur la map `{ dev = ..., prod = ... }`, quelle est l'adresse complète de la copie « prod » ? À quoi correspondent `each.key` et `each.value` ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7.** Quels sont les trois fichiers conventionnels d'un module, et quel « contrat » chacun porte-t-il ?

**Question 8.** Depuis le projet racine, comment accéder à la sortie `vpc_id` du module `reseau` ? Pourquoi cette référence suffit-elle à garantir l'ordre de création entre deux modules ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9.** Que fait `sensitive = true` sur une variable — et que ne fait-il **pas** ? Où la valeur reste-t-elle lisible en clair ?

**Question 10.** Quel fichier faut-il commiter pour que toute l'équipe utilise exactement les mêmes versions de providers ? Qui l'écrit, et quand ?

</div>

---

<!-- _class: lead -->

# À demain

## Jour 3 — le grand atelier : le TP2 renaît en Terraform

Demain, pas de nouvelle théorie ou presque : on **construit**. Les trois modules du fil rouge (`reseau`, `donnees`, `app`) + le front S3, appliqués étape par étape, chaque plan lu à voix haute. Puis on ira **saboter** notre propre infra dans la console… pour regarder `terraform plan` nous dénoncer. 

**Ce soir : `terraform destroy` sur les exercices du jour (buckets !), vérification console.** 💰

