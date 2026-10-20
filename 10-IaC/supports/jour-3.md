---
marp: true
title: Admin Cloud — CL-IAC — Jour 3
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Le grand atelier : StockLine en Terraform

<img style="width:190px" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTAgNjAuMTUiPgogIDxwYXRoIGNsYXNzPSJ0ZXh0IiBmaWxsPSIjMDAwIiBkPSJNNzcuMzUgNy44NlY0LjYzaC0zdjMuMjNoLTEuNDZWLjExaDEuNTF2My4yNWgzVi4xMWgxLjUxdjcuNzV6bTcgMGgtMS4ybC0uMTEtLjM4YTMuMjggMy4yOCAwIDAgMS0xLjcuNTJjLTEuMDYgMC0xLjUyLS43LTEuNTItMS42NiAwLTEuMTQuNTEtMS41NyAxLjctMS41N2gxLjR2LS42MmMwLS42Mi0uMTgtLjg0LTEuMTEtLjg0YTguNDYgOC40NiAwIDAgMC0xLjYxLjE3TDgwIDIuNDJhNy44OSA3Ljg5IDAgMCAxIDItLjI2YzEuODMgMCAyLjM3LjYyIDIuMzcgMnptLTEuNDMtMi4xMWgtMS4wOGMtLjQ4IDAtLjYxLjEzLS42MS41NXMuMTMuNTYuNTkuNTZhMi4zNyAyLjM3IDAgMCAwIDEuMS0uMjl6TTg3LjQzIDhhNy4xMiA3LjEyIDAgMCAxLTItLjMybC4yLTEuMDdhNi43NyA2Ljc3IDAgMCAwIDEuNzMuMjRjLjY1IDAgLjc0LS4xNC43NC0uNTZzLS4wNy0uNTItMS0uNzNjLTEuNDItLjMzLTEuNTktLjY4LTEuNTktMS43NnMuNDktMS42NSAyLjE2LTEuNjVhOCA4IDAgMCAxIDEuNzUuMmwtLjE0IDEuMTFhMTAuNjYgMTAuNjYgMCAwIDAtMS42LS4xNmMtLjYzIDAtLjc0LjE0LS43NC40OHMwIC40OC44Mi42OGMxLjYzLjQxIDEuNzguNjIgMS43OCAxLjc3Uzg5LjE5IDggODcuNDMgOHptNi42OC0uMTFWNGMwLS4zLS4xMy0uNDUtLjQ3LS40NWE0LjE0IDQuMTQgMCAwIDAtMS41Mi40NXYzLjg2aC0xLjQ2VjBsMS40Ni4yMnYyLjQ3YTUuMzEgNS4zMSAwIDAgMSAyLjEzLS41NGMxIDAgMS4zMi42NSAxLjMyIDEuNjV2NC4wNnptMi42OC02LjM4Vi4xMWgxLjQ2djEuMzd6bTAgNi4zOFYyLjI3aDEuNDZ2NS41OXptMi42Mi01LjU0YzAtMS40Ljg1LTIuMjIgMi44My0yLjIyYTkuMzcgOS4zNyAwIDAgMSAyLjE2LjI1bC0uMTcgMS4yNWExMi4yMSAxMi4yMSAwIDAgMC0xLjk1LS4yYy0xIDAtMS4zNy4zNC0xLjM3IDEuMTZWNS41YzAgLjgxLjMzIDEuMTYgMS4zNyAxLjE2YTEyLjIxIDEyLjIxIDAgMCAwIDEuOTUtLjJsLjE3IDEuMjVhOS4zNyA5LjM3IDAgMCAxLTIuMTYuMjVjLTIgMC0yLjgzLS44MS0yLjgzLTIuMjJ6TTEwNy42MyA4Yy0yIDAtMi41My0xLjA2LTIuNTMtMi4yVjQuMzZjMC0xLjE1LjU0LTIuMiAyLjUzLTIuMnMyLjUzIDEuMDYgMi41MyAyLjJ2MS40MWMuMDEgMS4xNS0uNTMgMi4yMy0yLjUzIDIuMjN6bTAtNC42M2MtLjc4IDAtMS4wOC4zMy0xLjA4IDF2MS41YzAgLjYzLjMgMSAxLjA4IDFzMS4wOC0uMzMgMS4wOC0xVjQuMzFjMC0uNjMtLjMtLjk2LTEuMDgtLjk2em02LjY0LjA5YTExLjU3IDExLjU3IDAgMCAwLTEuNTQuODF2My42aC0xLjQ2di01LjZoMS4yM2wuMS42MmE2LjYzIDYuNjMgMCAwIDEgMS41My0uNzN6TTEyMC4xIDZhMS43MyAxLjczIDAgMCAxLTEuOTIgMiA4LjM2IDguMzYgMCAwIDEtMS41NS0uMTZ2Mi4yNmwtMS40Ni4yMnYtOGgxLjE2bC4xNC40N2EzLjE1IDMuMTUgMCAwIDEgMS44NC0uNTljMS4xNyAwIDEuNzkuNjcgMS43OSAxLjk0em0tMy40OC42M2E2LjcyIDYuNzIgMCAwIDAgMS4yOS4xNWMuNTMgMCAuNzMtLjI0LjczLS43NXYtMmMwLS40Ni0uMTgtLjcxLS43Mi0uNzFhMi4xMSAyLjExIDAgMCAwLTEuMy41MXpNODEuNzggMTkuNTRoLTguODl2LTUuMzFIOTYuN3Y1LjMxaC04Ljl2MjYuNTNoLTZ6Ii8+CiAgPHBhdGggY2xhc3M9InRleHQiIGZpbGw9IiMwMDAiIGQ9Ik0xMDIuMTkgNDEuNzdhMjQuMzkgMjQuMzkgMCAwIDAgNy4xMi0xLjFsLjkxIDQuNGEyNSAyNSAwIDAgMS04LjU2IDEuNDhjLTcuMzEgMC05Ljg1LTMuMzktOS44NS05VjMxLjRjMC00LjkyIDIuMi05LjA4IDkuNjYtOS4wOHM5LjEzIDQuMzUgOS4xMyA5LjM3djVoLTEzdjEuMmMuMDUgMi43OCAxLjA1IDMuODggNC41OSAzLjg4ek05Ny42NSAzMmg3LjQxdi0xLjE4YzAtMi4yLS42Ny0zLjczLTMuNTQtMy43M3MtMy44NyAxLjUzLTMuODcgMy43M3ptMjguNTQtNC4zM2E0NS42NSA0NS42NSAwIDAgMC02LjE5IDMuMzl2MTVoLTUuODNWMjIuNzloNC45MmwuMzggMi41OGEyNi4wOSAyNi4wOSAwIDAgMSA2LjEyLTMuMDZ6bTE0LjI0IDBhNDUuNjUgNDUuNjUgMCAwIDAtNi4xNyAzLjM5djE1aC01LjgzVjIyLjc5aDQuOTJsLjM4IDIuNThhMjYuMDkgMjYuMDkgMCAwIDEgNi4xMi0zLjA2em0xOS41MSAxOC40aC00Ljc4bC0uNDMtMS41OGExMi43MyAxMi43MyAwIDAgMS02LjkzIDIuMDZjLTQuMjUgMC02LjA3LTIuOTItNi4wNy02LjkzIDAtNC43MyAyLjA2LTYuNTUgNi43OS02LjU1aDUuNTl2LTIuNDRjMC0yLjU4LS43Mi0zLjQ5LTQuNDUtMy40OWEzMi41MyAzMi41MyAwIDAgMC02LjQ1LjcybC0uNzItNC40NWEzMC4zOCAzMC4zOCAwIDAgMSA4LTEuMWM3LjMxIDAgOS40NyAyLjU4IDkuNDcgOC40MXptLTUuODMtOC44aC00LjNjLTEuOTEgMC0yLjQ0LjUzLTIuNDQgMi4yOXMuNTMgMi4zNCAyLjM0IDIuMzRhOS4xOCA5LjE4IDAgMCAwIDQuNC0xLjJ6bTIzLjc1LTE5Ljc5YTE3LjExIDE3LjExIDAgMCAwLTMuMzUtLjM4Yy0yLjI5IDAtMi42MyAxLTIuNjMgMi43N3YyLjkyaDUuOTNsLS4zMyA0LjY0aC01LjU5djE4LjY0aC01LjgzVjI3LjQzaC0zLjczdi00LjY0aDMuNzN2LTMuMjVjMC00LjgzIDIuMjUtNy4yMiA3LjQxLTcuMjJhMTguNDcgMTguNDcgMCAwIDEgNSAuNjd6bTExLjM4IDI5LjA3Yy04IDAtMTAuMTMtNC40LTEwLjEzLTkuMTh2LTUuODhjMC00Ljc4IDIuMTUtOS4xOCAxMC4xMy05LjE4czEwLjEzIDQuNCAxMC4xMyA5LjE4djUuODhjLjAxIDQuNzgtMi4xNSA5LjE4LTEwLjEzIDkuMTh6bTAtMTkuMjdjLTMuMTEgMC00LjMgMS4zOS00LjMgNHY2LjI2YzAgMi42MyAxLjIgNCA0LjMgNHM0LjMtMS4zOSA0LjMtNFYzMS4zYzAtMi42My0xLjE5LTQuMDItNC4zLTQuMDJ6bTI1LjE0LjM5YTQ1LjY1IDQ1LjY1IDAgMCAwLTYuMTcgMy4zOXYxNWgtNS44M1YyMi43OWg0LjkybC4zOCAyLjU4YTI2LjA4IDI2LjA4IDAgMCAxIDYuMTItMy4wNnptMTYuMDIgMTguNFYyOS44MmMwLTEuMjQtLjUzLTEuODYtMS44Ni0xLjg2YTE2LjA4IDE2LjA4IDAgMCAwLTYuMDcgMnYxNi4xMWgtNS44M1YyMi43OWg0LjQ1bC41NyAyYTIzLjMyIDIzLjMyIDAgMCAxIDkuMzQtMi40OCA0LjQyIDQuNDIgMCAwIDEgNC40IDIuNDkgMjIuODMgMjIuODMgMCAwIDEgOS4zNy0yLjQ5YzMuODcgMCA1LjI2IDIuNzIgNS4yNiA2Ljg4djE2Ljg4aC01LjgzVjI5LjgyYzAtMS4yNC0uNTMtMS44Ni0xLjg2LTEuODZhMTUuNDMgMTUuNDMgMCAwIDAtNi4wNyAydjE2LjExeiIvPgogIDxwYXRoIGNsYXNzPSJyZWN0LWRhcmsiIGZpbGw9IiM0MDQwQjIiIGQ9Ik0zNi40IDIwLjJ2MTguOTNsMTYuNC05LjQ2VjEwLjcyTDM2LjQgMjAuMnoiLz4KICA8cGF0aCBjbGFzcz0icmVjdC1saWdodCIgZmlsbD0iIzVDNEVFNSIgZD0iTTE4LjIgMTAuNzJsMTYuNCA5LjQ4djE4LjkzbC0xNi40LTkuNDdWMTAuNzJ6Ii8+CiAgPHBhdGggY2xhc3M9InJlY3QtbGlnaHQiIGZpbGw9IiM1QzRFRTUiIGQ9Ik0wIC4xNXYxOC45NGwxNi40IDkuNDdWOS42MkwwIC4xNXptMTguMiA1MC41M2wxNi40IDkuNDdWNDEuMjFsLTE2LjQtOS40N3YxOC45NHoiLz4KPC9zdmc+Cg==" alt="logo"/>

## 4 jours de CLI au TP2. Aujourd'hui : une commande.

Bloc 11 — CL-IAC — Jour 3 (jour 44 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Déployer une **architecture 3-tiers complète** (VPC, RDS, ALB/ASG, front S3) avec Terraform, **par étapes**, en lisant chaque plan.
- Expliquer chaque ressource des trois modules du fil rouge : `reseau`, `donnees`, `app`.
- Gérer un **secret de bout en bout** sans jamais le voir : `random_password` → SSM SecureString → rôle IAM.
- Détecter une **dérive de configuration** (modification console) avec `terraform plan`, et choisir la bonne réponse : écraser ou adopter.
- Détruire proprement une infrastructure facturée à l'heure 💰.

Livrable du jour : l'API StockLine qui répond derrière son ALB, le front sur S3 — et **plus rien** dans le compte à 17 h 15.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **La cible** — rappel de l'architecture du TP2, arborescence du projet.
2. **La stratégie d'apply par étapes** — pourquoi et comment.
3. **Module `reseau`** — lecture guidée, plan, apply.
4. **Module `donnees`** — le secret invisible, plan, apply.
5. **Module `app` + front** — l'assemblage final, plan, apply, tests.
6. 🧪 **TP guidé** — vous refaites tout, seuls, points de contrôle par module.
7. **La dérive** — sabotage console, détection, remédiation.
8. **Les dépendances du projet** — le graphe qui a tout ordonné.
9. **Destroy** 💰 — le rituel, vérifié.
10. Récap + quiz.

</div>

---

<!-- _class: lead -->

# 1. La cible

## La même architecture qu'au TP2 — au caractère près

---

<style scoped>
div{ font-size:22px }
</style>

## L'architecture (vous la connaissez par cœur)

<div>

<figure>
<svg viewBox="0 0 640 320" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <defs><marker id="a3" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <text x="60" y="20" text-anchor="middle" fill="#33404a">Internet</text>
  <line x1="60" y1="24" x2="60" y2="58" stroke="#6165ab" stroke-width="2" marker-end="url(#a3)"/>
  <rect x="30" y="58" width="60" height="26" rx="4" fill="#e0912f"/><text x="60" y="75" fill="#fff" text-anchor="middle">IGW</text>
  <!-- module reseau: le VPC englobant -->
  <rect x="20" y="98" width="600" height="200" rx="10" fill="none" stroke="#438ecc" stroke-width="2"/>
  <text x="32" y="116" fill="#438ecc" font-weight="bold">module reseau — VPC 10.42.0.0/16</text>
  <rect x="36" y="128" width="150" height="46" rx="6" fill="#a9cbe8"/><text x="111" y="149" text-anchor="middle" fill="#33404a">subnets publics</text><text x="111" y="165" text-anchor="middle" fill="#33404a">+ NAT GW 💰</text>
  <rect x="36" y="184" width="150" height="42" rx="6" fill="#a9cbe8"/><text x="111" y="210" text-anchor="middle" fill="#33404a">subnets app (privés)</text>
  <rect x="36" y="236" width="150" height="42" rx="6" fill="#a9cbe8"/><text x="111" y="262" text-anchor="middle" fill="#33404a">subnets db (privés)</text>
  <!-- module app -->
  <rect x="230" y="122" width="180" height="120" rx="8" fill="none" stroke="#6165ab" stroke-width="2"/>
  <text x="240" y="140" fill="#6165ab" font-weight="bold">module app</text>
  <rect x="248" y="150" width="140" height="34" rx="6" fill="#6165ab"/><text x="318" y="172" fill="#fff" text-anchor="middle">ALB :80</text>
  <rect x="248" y="196" width="140" height="34" rx="6" fill="#6165ab"/><text x="318" y="218" fill="#fff" text-anchor="middle">ASG EC2 ×2 :8000</text>
  <!-- module donnees -->
  <rect x="440" y="182" width="170" height="60" rx="8" fill="none" stroke="#4caf82" stroke-width="2"/>
  <text x="450" y="200" fill="#4caf82" font-weight="bold">module donnees</text>
  <rect x="450" y="206" width="150" height="30" rx="6" fill="#4caf82"/><text x="525" y="226" fill="#fff" text-anchor="middle">RDS PostgreSQL :5432</text>
  <line x1="318" y1="184" x2="318" y2="196" stroke="#6165ab" stroke-width="2" marker-end="url(#a3)"/>
  <line x1="388" y1="213" x2="448" y2="221" stroke="#6165ab" stroke-width="2" marker-end="url(#a3)"/>
  <!-- front -->
  <rect x="230" y="258" width="380" height="32" rx="6" fill="#e0912f"/>
  <text x="420" y="278" fill="#fff" text-anchor="middle">main.tf (racine) : S3 « front » + S3 « code »</text>
</svg>
<figcaption>L'architecture StockLine découpée en trois modules imbriqués</figcaption>
</figure>

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le projet — trois modules et un assemblage

<div>

`code/11-cl-iac/terraform/` — **~700 lignes de HCL** remplacent vos 4 scripts (~600 lignes de bash) **plus** vos 2 scripts de teardown, **plus** la gestion des mots de passe :

| Module | Remplace (TP2) | Contenu |
|--------|----------------|---------|
| `modules/reseau` | `01-create-network.sh` | VPC, 6 subnets, IGW, NAT 💰, routes, 3 SG chaînés |
| `modules/donnees` | `02-create-rds.sh` | `random_password`, SSM, subnet group, RDS |
| `modules/app` | `03-create-app.sh` | bucket code, IAM, launch template, ALB, ASG |
| `main.tf` (racine) | `04-create-front.sh` | bucket front, site statique, policy publique |

Avant de commencer, chacun vérifie :

```bash
export AWS_PROFILE=formation
aws sts get-caller-identity        # le BON compte sandbox ?
grep prefix terraform.tfvars       # VOTRE trigramme ?
./build-stockline-zip.sh           # dist/stockline.zip présent ?
```

</div>

---

<!-- _class: lead -->

# 2. La stratégie

## Appliquer par étapes, lire chaque plan

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi ne pas tout appliquer d'un coup ?

<div>

`terraform apply` sur le projet complet fonctionnerait (c'est même le but). Mais aujourd'hui on apprend, donc on découpe :

- **Des plans courts se lisent** : 22 ressources réseau se relisent ; 47 ressources d'un coup se survolent — et survoler un plan est interdit ici.
- **Les erreurs se localisent** : un échec RDS au milieu de 47 créations est pénible à diagnostiquer ; après un réseau déjà vert, c'est évident.
- **Le coût se maîtrise** 💰 : la NAT GW démarre au module réseau, RDS au module données — on sait ce qu'on enclenche, quand.

L'outil du découpage : **`-target`**.

```bash
terraform apply -target=module.reseau
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `-target` : outil pédagogique, PAS outil quotidien

<div>

```text
$ terraform apply -target=module.reseau
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the
│ result of this plan may not represent all of the changes requested by
│ the current configuration.
╵
```

Terraform vous avertit lui-même : un apply ciblé laisse le reste du code **non appliqué** — state et code divergent temporairement.

- Aujourd'hui : trois `-target` successifs, puis un **apply complet final** qui doit afficher `0 to add, 0 to change, 0 to destroy` sur l'existant — la preuve que tout est convergé.
- Au quotidien : `-target` sert au **dépannage exceptionnel**, jamais au flux normal. Une équipe qui vit à coups de `-target` a un problème d'architecture.

</div>

---

<!-- _class: lead -->

# 3. Module `reseau`

## 183 lignes de bash → un module déclaratif

---

<style scoped>
div{ font-size:15px }
</style>

## Lecture guidée — ce qu'il faut y (re)voir

<div>

`modules/reseau/main.tf` — les cinq idées, dans l'ordre du fichier :

1. **`data aws_availability_zones`** + `slice` : les AZ découvertes, jamais codées en dur.
2. **`locals` + `cidrsubnet`** : le plan d'adressage du TP2, calculé — `cidrsubnet("10.42.0.0/16", 8, 10)` → `10.42.10.0/24`.
3. **`for_each` sur des maps `az => cidr`** : 6 subnets en 3 blocs, adresses stables (`aws_subnet.app["eu-west-3a"]`).
4. **NAT GW unique** 💰 avec son `depends_on = [aws_internet_gateway.igw]` — la dépendance invisible vue au J1.
5. **SG chaînés par référence** : Internet →`:80`→ `sg_alb` →`:8000`→ `sg_app` →`:5432`→ `sg_db`. Pas de SSH : SSM (comme au TP2).

Et `outputs.tf` : le **contrat** que consommeront `donnees` et `app` — IDs de subnets et de SG, rien d'autre ne sort.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## Le plan du module réseau — extraits à lire ensemble

<div>

```text
$ terraform plan -target=module.reseau

  # module.reseau.aws_vpc.principal will be created
  + resource "aws_vpc" "principal" {
      + cidr_block           = "10.42.0.0/16"
      + enable_dns_hostnames = true
      + id                   = (known after apply)
      + tags                 = { + "Name" = "abc-iac-vpc" }
    }

  # module.reseau.aws_subnet.app["eu-west-3a"] will be created
  + resource "aws_subnet" "app" {
      + availability_zone = "eu-west-3a"
      + cidr_block        = "10.42.10.0/24"
      + vpc_id            = (known after apply)
    }

  # module.reseau.aws_nat_gateway.nat will be created
  + resource "aws_nat_gateway" "nat" {
      + allocation_id = (known after apply)
      + subnet_id     = (known after apply)
    }

  # module.reseau.aws_security_group.db will be created
  + resource "aws_security_group" "db" {
      + ingress = [{
          + from_port       = 5432
          + security_groups = [ (known after apply) ]
        }]
    }

Plan: 22 to add, 0 to change, 0 to destroy.
```

À remarquer : les adresses préfixées `module.reseau.`, le `for_each` visible dans `["eu-west-3a"]`, les `(known after apply)` en cascade (le VPC n'existe pas encore), et le compte : **22 à créer, 0 à détruire** — normal pour un premier apply.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Apply réseau — et le chronomètre 💰

<div>

```text
$ terraform apply -target=module.reseau
  [plan identique, relu]
  Enter a value: yes

module.reseau.aws_vpc.principal: Creating...
module.reseau.aws_vpc.principal: Creation complete after 12s [id=vpc-0f3a9c2e8b1d4a7e6]
module.reseau.aws_eip.nat: Creation complete after 1s
module.reseau.aws_subnet.publics["eu-west-3a"]: Creation complete after 1s
...
module.reseau.aws_nat_gateway.nat: Creating...
module.reseau.aws_nat_gateway.nat: Still creating... [1m30s elapsed]
module.reseau.aws_nat_gateway.nat: Creation complete after 1m47s

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.
```

- Les ressources indépendantes partent **en parallèle** (comparez avec le script séquentiel du TP2).
- La NAT GW prend ~2 min… et **facture dès maintenant** (~0,05 $/h). Le compteur du destroy de 17 h a démarré.
- Vérification : `terraform state list | head` — 22 entrées `module.reseau.*`.

</div>

---

<!-- _class: lead -->

# 4. Module `donnees`

## Un secret que personne ne verra jamais

---

<style scoped>
div{ font-size:15px }
</style>

## Le circuit du mot de passe — la slide la plus importante du jour

<div>

Au TP2, le mot de passe RDS traînait dans une variable shell. Ici :

```text
random_password.db (32 car., généré par Terraform, jamais affiché)
      │
      ├──> aws_ssm_parameter "/abc/stockline/db_password"   (SecureString)
      │
      ├──> aws_db_instance.db  (password = ...)
      │
      └──> aws_ssm_parameter "/abc/stockline/database_url"  (SecureString)
                    ▲                    │
   [rôle IAM: ssm:GetParameter] ────────┘
                    │
           EC2 (user data au boot) ──> /etc/stockline/stockline.env (chmod 600)
```

Le mot de passe n'apparaît **ni** dans le code, **ni** dans les tfvars, **ni** dans les sorties, **ni** dans un terminal. Personne ne le connaît — et personne n'en a besoin.

⚠️ Il est en revanche **en clair dans le state** (comme le plan vous le montrera) : raison n°1 du state chiffré côté S3 demain.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le plan du module données — lire les valeurs sensibles

<div>

```text
$ terraform plan -target=module.donnees

  # module.donnees.random_password.db will be created
  + resource "random_password" "db" {
      + length  = 32
      + result  = (sensitive value)
      + special = false
    }

  # module.donnees.aws_ssm_parameter.db_password will be created
  + resource "aws_ssm_parameter" "db_password" {
      + name  = "/abc/stockline/db_password"
      + type  = "SecureString"
      + value = (sensitive value)
    }

  # module.donnees.aws_db_instance.db will be created
  + resource "aws_db_instance" "db" {
      + engine              = "postgres"
      + instance_class      = "db.t3.micro"
      + password            = (sensitive value)
      + publicly_accessible = false
      + skip_final_snapshot = true
      + storage_encrypted   = true
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```

Checklist de lecture sur un plan RDS, **toujours la même** : `publicly_accessible = false` ? `storage_encrypted = true` ? classe **db.t3.micro** (💰 pas un m5.large qui traîne) ? Les secrets bien en `(sensitive value)` ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Apply données — patience, RDS

<div>

```text
$ terraform apply -target=module.donnees
  Enter a value: yes

module.donnees.random_password.db: Creation complete after 0s
module.donnees.aws_db_subnet_group.db: Creation complete after 1s
module.donnees.aws_db_instance.db: Creating...
module.donnees.aws_db_instance.db: Still creating... [5m10s elapsed]
module.donnees.aws_db_instance.db: Creation complete after 6m32s
module.donnees.aws_ssm_parameter.database_url: Creation complete after 0s

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

- RDS : **5 à 8 minutes** — le moment idéal pour la pause, PAS pour un Ctrl-C (un apply interrompu = state verrouillé/partiel, on en reparle demain).
- `database_url` n'est créé **qu'après** RDS : il référence `aws_db_instance.db.endpoint` — dépendance implicite, encore.
- Au fait : pourquoi `-target=module.donnees` a-t-il fonctionné sans recréer le réseau ? Parce que le state **connaît déjà** les 22 ressources réseau : `0 to change`.

</div>

---

<!-- _class: lead -->

# 5. Module `app` et le front

## L'assemblage final

---

<style scoped>
div{ font-size:15px }
</style>

## Lecture guidée du module `app`

<div>

`modules/app/main.tf` — la chaîne complète, chaque maillon référençant le précédent :

1. **`data aws_ami`** : la dernière AL2023 — jamais d'ID en dur (J2, en vrai).
2. **Bucket `code` + `aws_s3_object`** : `stockline.zip`, avec `etag = filemd5(...)` — si le zip change, l'objet est re-poussé au prochain apply.
3. **IAM moindre privilège** : le rôle des instances lit `ssm:GetParameter` sur `/abc/stockline/*` et `s3:GetObject` sur **ce** bucket — rien d'autre. Pas de SSH : `AmazonSSMManagedInstanceCore`.
4. **Launch template** : `user_data = base64encode(templatefile(...))` — le `templatefile` remplace le `sed | base64` du TP2 ; IMDSv2 `required`.
5. **ALB + target group** (health check `GET /sante` — l'endpoint StockLine) + **listener :80**.
6. **ASG min 2 / max 4** + politique target tracking CPU 50 % — et des tags **propagés** (`default_tags` du provider ne descend pas dans les instances ASG : piège connu).

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le front S3 — et un `depends_on` légitime

<div>

Dans `main.tf` racine (équivalent du `04-create-front.sh`) :

```hcl
resource "aws_s3_bucket_policy" "front_lecture_publique" {
  bucket = aws_s3_bucket.front.id
  policy = jsonencode({ ... "s3:GetObject" ... })

  # Dépendance EXPLICITE : la policy publique serait rejetée si elle était
  # appliquée avant la levée du Block Public Access (aucune référence ne lie
  # ces deux ressources, il faut donc le dire à Terraform).
  depends_on = [aws_s3_bucket_public_access_block.front]
}
```

Et le remplacement du `sed` du TP2 par une fonction :

```hcl
content = replace(
  file(var.chemin_front_index),
  "http://127.0.0.1:8000",
  "http://${module.app.dns_alb}",
)
```

L'index.html est réécrit avec l'URL réelle de l'ALB **au moment de l'apply** — `(known after apply)` jusqu'au bout.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## L'apply final — complet, sans `-target`

<div>

```text
$ terraform apply

  # module.app.aws_lb.alb will be created
  + resource "aws_lb" "alb" { ... }
  # aws_s3_bucket.front will be created
  ...

Plan: 20 to add, 0 to change, 0 to destroy.

  Enter a value: yes

module.app.aws_lb.alb: Creation complete after 3m12s
module.app.aws_autoscaling_group.stockline: Creating...
module.app.aws_autoscaling_group.stockline: Creation complete after 47s

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

url_api    = "http://abc-iac-alb-1847362514.eu-west-3.elb.amazonaws.com"
url_front  = "http://abc-iac-front-123456789012.s3-website.eu-west-3.amazonaws.com"
adresse_db = "abc-iac-db.c9akciq32rze.eu-west-3.rds.amazonaws.com"
```

Le point clé : **`0 to change, 0 to destroy`** sur les 27 ressources déjà créées — les trois `-target` ont convergé, l'apply complet ne touche que le reste.

Test (patience : grace period ASG 300 s) :

```bash
curl "$(terraform output -raw url_api)/sante"     # {"statut":"ok"}
terraform output -raw url_front                   # → navigateur
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧪 TP guidé — à vous, module par module

<div>

**`tp/11-cl-iac/tp-stockline-terraform.md`** — le reste de la journée, TP **non noté**.

Vous refaites le déploiement complet, seuls, avec un **point de contrôle vérifié à chaque étape** :

| Étape | Point de contrôle |
|-------|-------------------|
| 0. Préparation | `aws sts get-caller-identity`, `prefix` à vous, zip construit |
| 1. `module.reseau` | 22 ressources, VPC visible, plan relancé = `0 to add` |
| 2. `module.donnees` | RDS `available`, paramètre SSM lisible avec `--with-decryption` |
| 3. `module.app` + front | `curl /sante` = ok, cibles `healthy`, front dans le navigateur |
| 4. Convergence | `terraform plan` complet = `No changes.` |

💰 À partir de l'étape 1, votre compte facture ~0,10 $/h. Le TP se termine par le **destroy vérifié** — c'est un point de contrôle comme les autres.

</div>

---

<!-- _class: lead -->

# 6. La dérive

## Quand la console ment à votre code

<figure>
<svg viewBox="0 0 560 180" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <circle cx="40" cy="90" r="6" fill="#33404a"/>
  <text x="40" y="72" text-anchor="middle" fill="#33404a" font-size="12">apply</text>
  <line x1="46" y1="90" x2="300" y2="90" stroke="#4caf82" stroke-width="3"/>
  <text x="175" y="80" text-anchor="middle" fill="#4caf82" font-size="12">code = réalité (convergé)</text>
  <line x1="300" y1="90" x2="520" y2="40" stroke="#438ecc" stroke-width="3"/>
  <line x1="300" y1="90" x2="520" y2="140" stroke="#d1495b" stroke-width="3" stroke-dasharray="6 4"/>
  <circle cx="300" cy="90" r="6" fill="#e0912f"/>
  <text x="300" y="112" text-anchor="middle" fill="#e0912f" font-size="12">clic console</text>
  <rect x="522" y="26" width="34" height="28" rx="4" fill="#438ecc"/><text x="539" y="45" fill="#fff" text-anchor="middle" font-size="12">code</text>
  <rect x="522" y="126" width="34" height="28" rx="4" fill="#d1495b"/><text x="539" y="145" fill="#fff" text-anchor="middle" font-size="12">réel</text>
  <text x="430" y="170" text-anchor="middle" fill="#33404a" font-size="12">l'écart = la dérive, détectée par terraform plan</text>
</svg>
<figcaption>Après un clic console, l'état désiré et l'état réel divergent</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## Qu'est-ce que la dérive de configuration ?

<div>

**Dérive (drift)** : l'écart entre ce que décrit votre code et ce qui existe réellement — créé par toute modification **hors** Terraform : un clic console « juste pour tester », une CLI « juste pour dépanner », un collègue pressé un vendredi.

Pourquoi c'est grave :

- l'infra réelle n'est **plus documentée** par le code — retour au TP2 ;
- le prochain apply peut **écraser** le correctif console de quelqu'un (qui avait peut-être une bonne raison) ;
- ou pire : la dérive est un trou de sécurité (un port ouvert « pour un test ») que personne ne voit.

La bonne nouvelle : contrairement à vos scripts bash, **Terraform la détecte** — c'est le troisième terme de la comparaison du plan (code / state / **réalité**).

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## 💻 Démo 3-1 (volet dérive) — le sabotage dénoncé

<div>

Sabotage en console : sur le SG de l'ALB, quelqu'un ajoute une règle SSH ouverte au monde, et change un tag.

```text
$ terraform plan

module.reseau.aws_security_group.alb: Refreshing state... [id=sg-0a1b2c3d4e5f60789]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply" which may have affected this plan:

  # module.reseau.aws_security_group.alb has changed
  ~ resource "aws_security_group" "alb" {
      ~ ingress = [
            # (1 unchanged element hidden)
          + {
              + cidr_blocks = ["0.0.0.0/0"]
              + from_port   = 22
              + to_port     = 22
              + protocol    = "tcp"
            },
        ]
    }

Terraform will perform the following actions:

  # module.reseau.aws_security_group.alb will be updated in-place
  ~ resource "aws_security_group" "alb" {
      ~ ingress = [
          - { ... port 22 ... },     # <- le plan propose de SUPPRIMER l'intrus
        ]
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Deux sections distinctes : « changed outside of Terraform » (le constat) puis les actions (la remédiation proposée : **revenir au code**).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Face à une dérive : deux réponses légitimes, une interdite

<div>

**1. Écraser** (cas le plus fréquent) : la modification console n'avait pas lieu d'être → `terraform apply` remet l'infra en conformité avec le code. Le code est la source de vérité.

**2. Adopter** : la modification était **bonne** (un correctif d'urgence justifié) → on la **reporte dans le code**, on relance `plan` jusqu'à `No changes.` La modification est désormais documentée et versionnée.

**3. Ignorer** ❌ : laisser la dérive vivre. Le prochain apply — le vôtre ou celui d'un collègue, dans trois semaines — l'écrasera **silencieusement**, sans que personne comprenne pourquoi « ça remarche plus ».

Outil d'audit sans risque : `terraform plan -refresh-only` — montre **uniquement** les dérives, ne propose aucune action. Parfait en revue du matin.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 3-1 — Dérive de configuration

<div>

**`exercices/11-cl-iac/exercice-3-1-derive-de-configuration.md`** — 45 min, sur VOTRE infra du TP.

1. Sabotez votre propre infra en console (trois modifications imposées : un tag, une règle de SG, la capacité désirée de l'ASG).
2. `terraform plan -refresh-only` puis `terraform plan` : lisez, identifiez chaque dérive, **prédisez** la remédiation proposée.
3. Pour chaque dérive : écraser ou adopter ? Justifiez, puis faites-le.
4. Point final obligatoire : `terraform plan` → `No changes.`

Cas particulier à découvrir dans l'exercice : la dérive ASG — pourquoi `desired_capacity` est un cas à part (l'autoscaling a le **droit** de la changer).

</div>

---

<!-- _class: lead -->

# 7. Les dépendances du projet

## Le graphe qui a tout ordonné

---

<style scoped>
div{ font-size:20px }
</style>

## Le graphe réel (simplifié) du fil rouge

<div>

```text
          module.reseau                     module.donnees
   vpc ─┬─> subnets db ──────────────> db_subnet_group ─┐
        ├─> subnets app ─────────┐    random_password ──┼─> rds
        ├─> subnets publics ─┐   │         │            │
        ├─> sg alb ─> sg app ┼───┼─> sg db ┘            │
        igw ─(depends_on)─> nat  │                      │
                                 │    ssm database_url <┘
          module.app             │         │
   bucket code ─> zip            │         │
   rôle IAM ─> policy ───────────┼─────────┘   (nom du paramètre)
      └─> instance profile ─┐    │
   data ami ────────────────┼─> launch template ─┐
   alb ──> listener         │                    ├─> asg
      └──> target group ────┴────────────────────┘
```

Personne n'a écrit cet ordre. **Les références l'ont écrit.** À la destruction, Terraform le parcourt à l'envers.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les `depends_on` du projet — exactement deux

<div>

Sur ~50 ressources, le fil rouge ne contient que **deux** `depends_on`, tous deux commentés :

1. `aws_nat_gateway.nat` → `aws_internet_gateway.igw` : la NAT a besoin de l'IGW attaché, aucune référence ne les lie.
2. `aws_s3_bucket_policy.front_lecture_publique` → `aws_s3_bucket_public_access_block.front` : la policy publique serait **rejetée** avant la levée du blocage.

C'est un bon indicateur de santé d'un projet : **beaucoup de références, très peu de `depends_on`, tous justifiés par un commentaire**. Demain, dans le projet à critiquer, vous verrez l'inverse.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 3-2 — Dépendances

<div>

**`exercices/11-cl-iac/exercice-3-2-dependances.md`** — 30 min, papier + `terraform graph`.

1. Sans machine : pour 5 paires de ressources du fil rouge, dites **qui est créé d'abord** et **quelle référence** l'impose.
2. Question piège : pourquoi `module.donnees` et le bucket `code` de `module.app` peuvent-ils être créés **en même temps** ?
3. Expérience : supprimez mentalement le `depends_on` de la bucket policy — que se passerait-il à l'apply ? (La solution montre l'erreur AWS réelle.)
4. Bonus : `terraform graph | dot -Tsvg > graphe.svg` — le graphe, en vrai.

</div>

---

<!-- _class: lead -->

# 8. Le destroy 💰

## Le geste qui clôt chaque journée du bloc

---

<style scoped>
div{ font-size:14px }
</style>

## Destroy — sortie réelle et vérifications

<div>

```text
$ terraform destroy

Plan: 0 to add, 0 to change, 47 to destroy.

  Enter a value: yes

module.app.aws_autoscaling_group.stockline: Destroying...
module.app.aws_autoscaling_group.stockline: Destruction complete after 2m18s
module.app.aws_lb.alb: Destroying...
module.donnees.aws_db_instance.db: Destroying...
module.donnees.aws_db_instance.db: Still destroying... [3m40s elapsed]
module.donnees.aws_db_instance.db: Destruction complete after 4m52s
module.reseau.aws_nat_gateway.nat: Destruction complete after 1m22s
module.reseau.aws_vpc.principal: Destruction complete after 1s

Destroy complete! Resources: 47 destroyed.
```

Ordre **inverse** du graphe : ASG avant ALB, tout avant le VPC. Comparez avec votre teardown du TP2 et ses `aws ec2 wait`…

Puis la **vérification console** (le state peut mentir si quelqu'un a créé des choses à la main) :

```bash
aws ec2 describe-nat-gateways --filter Name=state,Values=available   # []  💰
aws elbv2 describe-load-balancers --query 'LoadBalancers[].DNSName'  # []
aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier'  # []
aws ec2 describe-addresses --query 'Addresses[].PublicIp'            # []  💰 EIP !
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Récap de la journée

<div>

- L'architecture 3-tiers complète : **3 modules + front**, ~50 ressources, un apply — vs 4 jours au TP2. C'est ça, l'IaC.
- Stratégie d'atelier : `-target` par module pour des **plans courts et lus**, puis apply complet qui converge (`0 to change`). `-target` = exception, jamais le quotidien.
- Le secret RDS : **généré** (`random_password`) → **SSM SecureString** → lu au boot via **rôle IAM**. Personne ne le connaît. Mais il est en clair **dans le state** → J4.
- Checklist plan RDS : `publicly_accessible=false`, `storage_encrypted=true`, la bonne classe 💰, secrets en `(sensitive value)`.
- **Dérive** : détectée par `plan` (« changed outside of Terraform ») ; audit avec `-refresh-only` ; deux réponses : **écraser** ou **adopter** — jamais ignorer.
- Dépendances : le graphe vient des références ; 2 `depends_on` dans tout le projet, tous deux commentés.
- **Destroy chaque soir**, puis vérification console : NAT, ALB, RDS, **EIP**.

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

**Question 1.** Pourquoi `terraform apply -target=...` ne doit-il pas devenir une habitude de travail ? Quel message Terraform affiche-t-il pour vous le rappeler ?

**Question 2.** Après nos trois apply ciblés, l'apply complet final affichait `20 to add, 0 to change, 0 to destroy`. Qu'est-ce que le `0 to change` prouve exactement ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3.** Décrivez le circuit complet du mot de passe RDS dans le fil rouge, de sa génération à son arrivée dans `/etc/stockline/stockline.env`. À quels endroits est-il lisible en clair ?

**Question 4.** Dans le plan du module `donnees`, quelles sont les quatre vérifications systématiques à faire sur le bloc `aws_db_instance` avant de signer l'apply ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5.** Comment `terraform plan` signale-t-il qu'une ressource a été modifiée **hors** Terraform ? Quelle option de `plan` permet d'auditer les dérives sans qu'aucune action ne soit proposée ?

**Question 6.** Une dérive est détectée : quelles sont les deux réponses légitimes, et dans quel cas choisit-on chacune ? Pourquoi « ignorer » est-il la pire option ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7.** Le projet contient exactement deux `depends_on`. Lesquels, et pourquoi une simple référence ne suffisait-elle pas dans ces deux cas ?

**Question 8.** À quoi sert `templatefile()` dans le launch template du module `app` ? Que remplace-t-il par rapport au TP2 ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9.** Citez les trois ressources du projet qui facturent dès leur création, même sans aucun trafic 💰. Laquelle survit parfois au destroy si elle a été détachée à la main ?

**Question 10.** `force_destroy = true` est posé sur les buckets `front` et `code`. Que permet-il, pourquoi est-il acceptable ici — et sur quel type de bucket serait-il une faute ?

</div>

---

<!-- _class: lead -->

# À demain

## Jour 4 — le state quitte votre laptop

Votre state contient un mot de passe de production en clair et vit… sur votre disque dur. Demain : state **distant** dans S3 (versionné, chiffré, **verrouillé**), migration sans casse, `import` pour adopter l'existant, chirurgie du state (`mv`, `rm`), tflint et checkov — et la revue d'un projet **volontairement catastrophique** pour tout réviser.

**Ce soir, plus que jamais : le destroy du TP est un point de contrôle. NAT GW + ALB + RDS = ~2,50 $ par nuit oubliée.** 💰

