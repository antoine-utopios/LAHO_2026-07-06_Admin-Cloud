---
marp: true
title: Admin Cloud — CL-IAC — Jour 4
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Le state en équipe, l'import et les bonnes pratiques

<img style="width:190px" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTAgNjAuMTUiPgogIDxwYXRoIGNsYXNzPSJ0ZXh0IiBmaWxsPSIjMDAwIiBkPSJNNzcuMzUgNy44NlY0LjYzaC0zdjMuMjNoLTEuNDZWLjExaDEuNTF2My4yNWgzVi4xMWgxLjUxdjcuNzV6bTcgMGgtMS4ybC0uMTEtLjM4YTMuMjggMy4yOCAwIDAgMS0xLjcuNTJjLTEuMDYgMC0xLjUyLS43LTEuNTItMS42NiAwLTEuMTQuNTEtMS41NyAxLjctMS41N2gxLjR2LS42MmMwLS42Mi0uMTgtLjg0LTEuMTEtLjg0YTguNDYgOC40NiAwIDAgMC0xLjYxLjE3TDgwIDIuNDJhNy44OSA3Ljg5IDAgMCAxIDItLjI2YzEuODMgMCAyLjM3LjYyIDIuMzcgMnptLTEuNDMtMi4xMWgtMS4wOGMtLjQ4IDAtLjYxLjEzLS42MS41NXMuMTMuNTYuNTkuNTZhMi4zNyAyLjM3IDAgMCAwIDEuMS0uMjl6TTg3LjQzIDhhNy4xMiA3LjEyIDAgMCAxLTItLjMybC4yLTEuMDdhNi43NyA2Ljc3IDAgMCAwIDEuNzMuMjRjLjY1IDAgLjc0LS4xNC43NC0uNTZzLS4wNy0uNTItMS0uNzNjLTEuNDItLjMzLTEuNTktLjY4LTEuNTktMS43NnMuNDktMS42NSAyLjE2LTEuNjVhOCA4IDAgMCAxIDEuNzUuMmwtLjE0IDEuMTFhMTAuNjYgMTAuNjYgMCAwIDAtMS42LS4xNmMtLjYzIDAtLjc0LjE0LS43NC40OHMwIC40OC44Mi42OGMxLjYzLjQxIDEuNzguNjIgMS43OCAxLjc3Uzg5LjE5IDggODcuNDMgOHptNi42OC0uMTFWNGMwLS4zLS4xMy0uNDUtLjQ3LS40NWE0LjE0IDQuMTQgMCAwIDAtMS41Mi40NXYzLjg2aC0xLjQ2VjBsMS40Ni4yMnYyLjQ3YTUuMzEgNS4zMSAwIDAgMSAyLjEzLS41NGMxIDAgMS4zMi42NSAxLjMyIDEuNjV2NC4wNnptMi42OC02LjM4Vi4xMWgxLjQ2djEuMzd6bTAgNi4zOFYyLjI3aDEuNDZ2NS41OXptMi42Mi01LjU0YzAtMS40Ljg1LTIuMjIgMi44My0yLjIyYTkuMzcgOS4zNyAwIDAgMSAyLjE2LjI1bC0uMTcgMS4yNWExMi4yMSAxMi4yMSAwIDAgMC0xLjk1LS4yYy0xIDAtMS4zNy4zNC0xLjM3IDEuMTZWNS41YzAgLjgxLjMzIDEuMTYgMS4zNyAxLjE2YTEyLjIxIDEyLjIxIDAgMCAwIDEuOTUtLjJsLjE3IDEuMjVhOS4zNyA5LjM3IDAgMCAxLTIuMTYuMjVjLTIgMC0yLjgzLS44MS0yLjgzLTIuMjJ6TTEwNy42MyA4Yy0yIDAtMi41My0xLjA2LTIuNTMtMi4yVjQuMzZjMC0xLjE1LjU0LTIuMiAyLjUzLTIuMnMyLjUzIDEuMDYgMi41MyAyLjJ2MS40MWMuMDEgMS4xNS0uNTMgMi4yMy0yLjUzIDIuMjN6bTAtNC42M2MtLjc4IDAtMS4wOC4zMy0xLjA4IDF2MS41YzAgLjYzLjMgMSAxLjA4IDFzMS4wOC0uMzMgMS4wOC0xVjQuMzFjMC0uNjMtLjMtLjk2LTEuMDgtLjk2em02LjY0LjA5YTExLjU3IDExLjU3IDAgMCAwLTEuNTQuODF2My42aC0xLjQ2di01LjZoMS4yM2wuMS42MmE2LjYzIDYuNjMgMCAwIDEgMS41My0uNzN6TTEyMC4xIDZhMS43MyAxLjczIDAgMCAxLTEuOTIgMiA4LjM2IDguMzYgMCAwIDEtMS41NS0uMTZ2Mi4yNmwtMS40Ni4yMnYtOGgxLjE2bC4xNC40N2EzLjE1IDMuMTUgMCAwIDEgMS44NC0uNTljMS4xNyAwIDEuNzkuNjcgMS43OSAxLjk0em0tMy40OC42M2E2LjcyIDYuNzIgMCAwIDAgMS4yOS4xNWMuNTMgMCAuNzMtLjI0LjczLS43NXYtMmMwLS40Ni0uMTgtLjcxLS43Mi0uNzFhMi4xMSAyLjExIDAgMCAwLTEuMy41MXpNODEuNzggMTkuNTRoLTguODl2LTUuMzFIOTYuN3Y1LjMxaC04Ljl2MjYuNTNoLTZ6Ii8+CiAgPHBhdGggY2xhc3M9InRleHQiIGZpbGw9IiMwMDAiIGQ9Ik0xMDIuMTkgNDEuNzdhMjQuMzkgMjQuMzkgMCAwIDAgNy4xMi0xLjFsLjkxIDQuNGEyNSAyNSAwIDAgMS04LjU2IDEuNDhjLTcuMzEgMC05Ljg1LTMuMzktOS44NS05VjMxLjRjMC00LjkyIDIuMi05LjA4IDkuNjYtOS4wOHM5LjEzIDQuMzUgOS4xMyA5LjM3djVoLTEzdjEuMmMuMDUgMi43OCAxLjA1IDMuODggNC41OSAzLjg4ek05Ny42NSAzMmg3LjQxdi0xLjE4YzAtMi4yLS42Ny0zLjczLTMuNTQtMy43M3MtMy44NyAxLjUzLTMuODcgMy43M3ptMjguNTQtNC4zM2E0NS42NSA0NS42NSAwIDAgMC02LjE5IDMuMzl2MTVoLTUuODNWMjIuNzloNC45MmwuMzggMi41OGEyNi4wOSAyNi4wOSAwIDAgMSA2LjEyLTMuMDZ6bTE0LjI0IDBhNDUuNjUgNDUuNjUgMCAwIDAtNi4xNyAzLjM5djE1aC01LjgzVjIyLjc5aDQuOTJsLjM4IDIuNThhMjYuMDkgMjYuMDkgMCAwIDEgNi4xMi0zLjA2em0xOS41MSAxOC40aC00Ljc4bC0uNDMtMS41OGExMi43MyAxMi43MyAwIDAgMS02LjkzIDIuMDZjLTQuMjUgMC02LjA3LTIuOTItNi4wNy02LjkzIDAtNC43MyAyLjA2LTYuNTUgNi43OS02LjU1aDUuNTl2LTIuNDRjMC0yLjU4LS43Mi0zLjQ5LTQuNDUtMy40OWEzMi41MyAzMi41MyAwIDAgMC02LjQ1LjcybC0uNzItNC40NWEzMC4zOCAzMC4zOCAwIDAgMSA4LTEuMWM3LjMxIDAgOS40NyAyLjU4IDkuNDcgOC40MXptLTUuODMtOC44aC00LjNjLTEuOTEgMC0yLjQ0LjUzLTIuNDQgMi4yOXMuNTMgMi4zNCAyLjM0IDIuMzRhOS4xOCA5LjE4IDAgMCAwIDQuNC0xLjJ6bTIzLjc1LTE5Ljc5YTE3LjExIDE3LjExIDAgMCAwLTMuMzUtLjM4Yy0yLjI5IDAtMi42MyAxLTIuNjMgMi43N3YyLjkyaDUuOTNsLS4zMyA0LjY0aC01LjU5djE4LjY0aC01LjgzVjI3LjQzaC0zLjczdi00LjY0aDMuNzN2LTMuMjVjMC00LjgzIDIuMjUtNy4yMiA3LjQxLTcuMjJhMTguNDcgMTguNDcgMCAwIDEgNSAuNjd6bTExLjM4IDI5LjA3Yy04IDAtMTAuMTMtNC40LTEwLjEzLTkuMTh2LTUuODhjMC00Ljc4IDIuMTUtOS4xOCAxMC4xMy05LjE4czEwLjEzIDQuNCAxMC4xMyA5LjE4djUuODhjLjAxIDQuNzgtMi4xNSA5LjE4LTEwLjEzIDkuMTh6bTAtMTkuMjdjLTMuMTEgMC00LjMgMS4zOS00LjMgNHY2LjI2YzAgMi42MyAxLjIgNCA0LjMgNHM0LjMtMS4zOSA0LjMtNFYzMS4zYzAtMi42My0xLjE5LTQuMDItNC4zLTQuMDJ6bTI1LjE0LjM5YTQ1LjY1IDQ1LjY1IDAgMCAwLTYuMTcgMy4zOXYxNWgtNS44M1YyMi43OWg0LjkybC4zOCAyLjU4YTI2LjA4IDI2LjA4IDAgMCAxIDYuMTItMy4wNnptMTYuMDIgMTguNFYyOS44MmMwLTEuMjQtLjUzLTEuODYtMS44Ni0xLjg2YTE2LjA4IDE2LjA4IDAgMCAwLTYuMDcgMnYxNi4xMWgtNS44M1YyMi43OWg0LjQ1bC41NyAyYTIzLjMyIDIzLjMyIDAgMCAxIDkuMzQtMi40OCA0LjQyIDQuNDIgMCAwIDEgNC40IDIuNDkgMjIuODMgMjIuODMgMCAwIDEgOS4zNy0yLjQ5YzMuODcgMCA1LjI2IDIuNzIgNS4yNiA2Ljg4djE2Ljg4aC01LjgzVjI5LjgyYzAtMS4yNC0uNTMtMS44Ni0xLjg2LTEuODZhMTUuNDMgMTUuNDMgMCAwIDAtNi4wNyAydjE2LjExeiIvPgogIDxwYXRoIGNsYXNzPSJyZWN0LWRhcmsiIGZpbGw9IiM0MDQwQjIiIGQ9Ik0zNi40IDIwLjJ2MTguOTNsMTYuNC05LjQ2VjEwLjcyTDM2LjQgMjAuMnoiLz4KICA8cGF0aCBjbGFzcz0icmVjdC1saWdodCIgZmlsbD0iIzVDNEVFNSIgZD0iTTE4LjIgMTAuNzJsMTYuNCA5LjQ4djE4LjkzbC0xNi40LTkuNDdWMTAuNzJ6Ii8+CiAgPHBhdGggY2xhc3M9InJlY3QtbGlnaHQiIGZpbGw9IiM1QzRFRTUiIGQ9Ik0wIC4xNXYxOC45NGwxNi40IDkuNDdWOS42MkwwIC4xNXptMTguMiA1MC41M2wxNi40IDkuNDdWNDEuMjFsLTE2LjQtOS40N3YxOC45NHoiLz4KPC9zdmc+Cg==" alt="logo"/>

## Votre state contient un mot de passe de prod. Il vit sur votre laptop.

Bloc 11 — CL-IAC — Jour 4 (jour 45 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Expliquer pourquoi le state local ne survit ni au travail d'équipe ni à un laptop perdu.
- Configurer un **backend S3** : bucket versionné, chiffré, **verrouillé** — et **migrer** un state existant sans rien casser.
- Inspecter et opérer le state : `state list`, `state show`, `state mv` (et le bloc `moved`), `state rm`, `force-unlock`.
- **Importer** une ressource créée à la main avec le bloc `import` (Terraform ≥ 1.5).
- Appliquer les bonnes pratiques du métier : `default_tags`, secrets hors du code, moindre privilège, versions épinglées.
- Lancer **tflint** et **checkov**, et comprendre ce qu'ils attrapent que `validate` ne voit pas.
- **Auditer un projet Terraform mal écrit** — et argumenter chaque critique.

Livrable du jour : votre state dans **votre** bucket S3, et une revue de code complète.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **Le problème du state local** — équipe, durabilité, secrets.
2. **Backend S3 + verrouillage** — configuration, migration du state.
3. **Chirurgie du state** — list, show, mv/moved, rm, force-unlock.
4. **Import** — adopter l'existant avec le bloc `import`.
5. **Bonnes pratiques** — tags, secrets, moindre privilège, versions.
6. **tflint et checkov** — l'analyse statique en avant-goût du bloc 15.
7. **Revue de projet** — démonter un projet mal écrit, pièce par pièce.
8. **Transition** — ce que Terraform ne fera jamais : Ansible dès demain.
9. Récap + quiz.

</div>

---

<!-- _class: lead -->

# 1. Le problème du state local

## Trois raisons de le faire déménager

<figure>
<svg viewBox="0 0 560 200" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <defs><marker id="b4" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="20"  y="20" width="130" height="42" rx="6" fill="#438ecc"/><text x="85"  y="46" fill="#fff" text-anchor="middle">dev A</text>
  <rect x="20"  y="138" width="130" height="42" rx="6" fill="#438ecc"/><text x="85" y="164" fill="#fff" text-anchor="middle">dev B</text>
  <rect x="330" y="70" width="210" height="60" rx="8" fill="#6165ab"/>
  <text x="435" y="94" fill="#fff" text-anchor="middle" font-weight="bold">state S3 partagé</text>
  <text x="435" y="114" fill="#fff" text-anchor="middle" font-size="12">versionné · chiffré · 🔒 verrouillé</text>
  <line x1="150" y1="45"  x2="326" y2="90"  stroke="#4caf82" stroke-width="2" marker-end="url(#b4)"/>
  <text x="230" y="58" text-anchor="middle" fill="#4caf82" font-size="12">apply (verrou pris)</text>
  <line x1="150" y1="159" x2="326" y2="115" stroke="#d1495b" stroke-width="2" stroke-dasharray="5 4" marker-end="url(#b4)"/>
  <text x="230" y="165" text-anchor="middle" fill="#d1495b" font-size="12">attend / échoue</text>
  <text x="435" y="150" text-anchor="middle" fill="#33404a" font-size="12">un seul apply à la fois : pas de corruption</text>
</svg>
<figcaption>Backend distant : un state unique, partagé et verrouillé entre développeurs</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## Le drame du state local, en trois actes

<div>

**Acte 1 — l'équipe.** Lundi : vous appliquez depuis votre laptop. Mardi : votre collègue applique depuis le sien — **son state à lui est vide** : il recrée tout, ou détruit ce qu'il ne « connaît » pas. Deux states = deux vérités = une infra ingérable.

**Acte 2 — la durabilité.** Votre laptop meurt. Le state meurt avec lui. L'infra tourne toujours, facture toujours 💰, mais plus rien ne la gère (souvenez-vous du J1 : Terraform amnésique).

**Acte 3 — les secrets.** `terraform.tfstate` contient le mot de passe RDS **en clair**, posé sur un disque de laptop, sauvegardé qui-sait-où.

Le remède aux trois : un state **distant**, **partagé**, **durable**, **chiffré** — et **verrouillé** pour que deux apply simultanés ne s'écrasent pas.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les backends

<div>

Le **backend** = l'endroit où Terraform lit et écrit le state. Défaut : `local` (le fichier à côté du code — nos J1-J3).

| Backend | Stockage | Verrouillage | Notre cas |
|---------|----------|--------------|-----------|
| `local` | fichier local | fichier `.lock` local | J1-J3, apprentissage |
| **`s3`** | bucket S3 | lockfile S3 (≥ 1.10) ou DynamoDB | **aujourd'hui** — le standard AWS |
| `azurerm` | blob Azure | natif | bloc 09, si Terraform sur Azure |
| HCP Terraform / autres | SaaS / divers | natif | à connaître de nom |

Le **verrouillage (locking)** : pendant un apply, le state est verrouillé ; un deuxième apply simultané **attend ou échoue** au lieu de corrompre. Git ne sait pas faire ça — raison de plus pour laquelle le state n'a rien à faire dans git.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le bucket de state — un par apprenant, jamais partagé

<div>

⚠️ **En salle : chacun SON bucket, préfixé par SON trigramme.** Un backend partagé entre apprenants = vos apply se verrouillent mutuellement et vos states s'entremêlent.

```bash
# 1. Le bucket (nom mondialement unique : prefix + ID de compte)
aws s3api create-bucket \
  --bucket ${PREFIX}-iac-tfstate-<ACCOUNT_ID> --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3

# 2. Le versioning : CHAQUE écriture du state est conservée.
#    C'est votre filet de sécurité (state écrasé -> version précédente).
aws s3api put-bucket-versioning \
  --bucket ${PREFIX}-iac-tfstate-<ACCOUNT_ID> \
  --versioning-configuration Status=Enabled
```

Poule et œuf assumé : le bucket du state est créé **en CLI**, pas par le projet qu'il héberge (sinon son propre state n'aurait nulle part où vivre pendant sa création). En entreprise : un petit projet « bootstrap » séparé.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le bloc backend — déjà écrit dans le fil rouge

<div>

`backend.tf` du projet StockLine — il suffit de décommenter et personnaliser :

```hcl
terraform {
  backend "s3" {
    bucket       = "abc-iac-tfstate-123456789012"   # VOTRE bucket ($PREFIX)
    key          = "stockline/dev/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true          # Terraform >= 1.10
    # dynamodb_table = "abc-iac-tf-locks"   # Terraform < 1.10 (clé LockID)
  }
}
```

- `key` : le chemin dans le bucket — un `key` **par projet et par environnement**.
- `encrypt = true` : chiffrement côté serveur — le mot de passe RDS n'est plus en clair sur un disque.
- Verrouillage : `use_lockfile = true` (fichier `.tflock` posé dans le bucket, ≥ 1.10) ; avant 1.10 : table DynamoDB avec clé de partition `LockID` (String). Les deux peuvent coexister le temps d'une transition d'équipe.
- ⚠️ Pas de variables dans un bloc backend (`var.` interdit ici) : valeurs en dur ou `-backend-config`.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## La migration — sortie réelle

<div>

Le state existe déjà en local (votre TP d'hier, si vous ne l'aviez pas détruit — ici : recréé ce matin). On ne le recrée pas, on le **déménage** :

```text
$ terraform init -migrate-state

Initializing the backend...
Terraform detected that the backend type changed from "local" to "s3".

Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend
  to the newly configured "s3" backend. [...] Should Terraform migrate your
  existing state?

  Enter a value: yes

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

Vérifications immédiates, dans l'ordre :

```bash
terraform plan                       # doit dire : No changes. (rien n'a bougé chez AWS)
aws s3 ls s3://abc-iac-tfstate-123456789012/stockline/dev/   # le state est là
rm terraform.tfstate terraform.tfstate.backup               # l'ancien local, APRÈS le plan vert
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le verrou en action — et `force-unlock`

<div>

Deux terminaux, deux apply simultanés — le second reçoit :

```text
╷
│ Error: Error acquiring the state lock
│
│ Error message: operation error S3: PutObject, https response error
│ StatusCode: 412, PreconditionFailed: At least one of the pre-conditions
│ you specified did not hold
│
│ Lock Info:
│   ID:        7d4c9f0a-3b1e-4f2a-9c8d-5e6f7a8b9c0d
│   Operation: OperationTypeApply
│   Who:       ihab@poste-formation
│   Created:   2026-07-06 14:32:07 UTC
╵
```

C'est le comportement **désiré** : mieux vaut une erreur qu'un state corrompu.

Verrou **orphelin** (apply tué net, machine éteinte) : `terraform force-unlock 7d4c9f0a-...` — l'ID exact du message, et **seulement** après avoir vérifié qu'aucun apply ne tourne réellement quelque part. Forcer un verrou actif = corruption garantie.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 4-1 — Migration du state + import

<div>

**`demos/11-cl-iac/demo-4-1-state-distant-import.md`**

Au programme, en direct :

1. Création de **mon** bucket de state (versionné), lecture du `backend.tf`.
2. `terraform init -migrate-state` → `plan` = `No changes.` — la migration parfaite.
3. Le verrou : deux terminaux, l'erreur `Error acquiring the state lock`, lecture du message.
4. `state list` / `state show` sur le projet migré.
5. Un bucket créé **à la main** en CLI → bloc `import` → `plan` → l'adoption sans recréation.

Votre tour ensuite : la première heure de l'après-midi est consacrée à migrer **votre** state (checklist dans la démo, section « à vous »).

</div>

---

<!-- _class: lead -->

# 2. Chirurgie du state

## Inspecter, renommer, désinscrire — sans jamais l'éditer

---

<style scoped>
div{ font-size:15px }
</style>

## `state list` et `state show` — l'inspection

<div>

```text
$ terraform state list
aws_s3_bucket.front
aws_s3_bucket_policy.front_lecture_publique
module.app.aws_autoscaling_group.stockline
module.app.aws_lb.alb
module.donnees.aws_db_instance.db
module.reseau.aws_nat_gateway.nat
module.reseau.aws_subnet.app["eu-west-3a"]
...

$ terraform state show module.donnees.aws_db_instance.db
# module.donnees.aws_db_instance.db:
resource "aws_db_instance" "db" {
    address              = "abc-iac-db.c9akciq32rze.eu-west-3.rds.amazonaws.com"
    engine               = "postgres"
    instance_class       = "db.t3.micro"
    password             = (sensitive value)
    publicly_accessible  = false
    ...
}
```

Lecture seule, sans danger, à utiliser sans modération. C'est aussi l'outil de diagnostic n°1 : « Terraform gère-t-il cette ressource ? » → `state list | grep`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Renommer sans détruire : le bloc `moved` (et `state mv`)

<div>

Vous renommez `aws_s3_bucket.b1` en `aws_s3_bucket.sauvegardes_dev` dans le code. Au plan suivant : **destroy + create** — pour Terraform, `b1` a disparu et une inconnue est apparue. Sur un bucket plein : perte de données.

La solution moderne — **déclarative, versionnée, revue en PR** :

```hcl
moved {
  from = aws_s3_bucket.b1
  to   = aws_s3_bucket.sauvegardes_dev
}
```

```text
  # aws_s3_bucket.b1 has moved to aws_s3_bucket.sauvegardes_dev
    resource "aws_s3_bucket" "sauvegardes_dev" { ... }

Plan: 0 to add, 0 to change, 0 to destroy.
```

L'ancienne méthode, impérative : `terraform state mv aws_s3_bucket.b1 aws_s3_bucket.sauvegardes_dev` — même effet, mais hors git. Préférez `moved` ; retenez `state mv` pour les cas que `moved` ne couvre pas (déplacement **entre states**).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## `state rm` — désinscrire sans détruire

<div>

```text
$ terraform state rm aws_s3_bucket.legacy
Removed aws_s3_bucket.legacy
Successfully removed 1 resource instance(s).
```

- La ressource **existe toujours chez AWS** — Terraform cesse simplement de la gérer. (Pensez à retirer le bloc du code, sinon le prochain plan proposera de la **recréer**.)
- Cas d'usage : transférer une ressource à une autre équipe/projet, sortir du périmètre une ressource adoptée par erreur.
- Le miroir exact d'`import` : `import` = entrée dans le state, `state rm` = sortie du state — dans les deux cas, **AWS n'est pas touché**.

À ne pas confondre :

| Commande | State | AWS |
|----------|-------|-----|
| `terraform state rm` | retiré | **intact** |
| `terraform destroy -target=...` | retiré | **détruit** |

</div>

---

<!-- _class: lead -->

# 3. L'import

## Adopter ce qui a été créé à la main

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi importer ?

<div>

La réalité de tout poste d'admin cloud : l'infra existante n'est **pas née dans Terraform**. Des années de console, de scripts, de CloudFormation partiel. Deux stratégies :

- reconstruire à côté et basculer (propre, pas toujours possible : bases de données, DNS…) ;
- **importer** : raccrocher la ressource existante au code, sans la toucher.

Depuis Terraform **1.5**, l'import est **déclaratif** : un bloc `import` dans le code, visible dans le plan, rejouable, versionné — fini la commande `terraform import` à l'aveugle (elle existe toujours, on la garde pour les scripts).

C'est aussi la réponse au **state perdu** (J1) : réimporter, ressource par ressource.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le bloc `import` — Terraform ≥ 1.5

<div>

Un bucket `abc-legacy-archives` créé à la main en CLI le mois dernier :

```hcl
# 1. Le bloc import : QUOI (l'ID AWS) va OÙ (l'adresse Terraform).
import {
  to = aws_s3_bucket.archives
  id = "abc-legacy-archives"      # pour un bucket : son nom. Chaque type
}                                 # documente son format d'ID (registry).

# 2. La ressource correspondante — à écrire, ou à générer :
resource "aws_s3_bucket" "archives" {
  bucket = "abc-legacy-archives"
}
```

Pas envie d'écrire le bloc `resource` à la main ? Terraform le **génère** :

```bash
terraform plan -generate-config-out=genere.tf
# relire genere.tf, le nettoyer, l'intégrer — c'est un brouillon, pas un produit fini
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le plan d'un import — sortie réelle

<div>

```text
$ terraform plan

Terraform will perform the following actions:

  # aws_s3_bucket.archives will be imported
    resource "aws_s3_bucket" "archives" {
        arn    = "arn:aws:s3:::abc-legacy-archives"
        bucket = "abc-legacy-archives"
        id     = "abc-legacy-archives"
        region = "eu-west-3"
        tags   = {}
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

La ligne de compte a gagné un terme : **`1 to import`**. À vérifier avant d'appliquer :

- `0 to destroy` — un import ne détruit jamais rien ;
- et surtout **pas de `~ update` sur la ressource importée** : s'il y en a un, votre bloc `resource` ne décrit pas fidèlement l'existant — Terraform le *modifierait* juste après l'adoption. On corrige le code d'abord, on applique ensuite.

Après l'apply : le bloc `import` a fait son œuvre, il peut être supprimé du code.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 4-1 — Scénarios de crise du state

<div>

**`exercices/11-cl-iac/exercice-4-1-scenarios-state.md`** — 45 min, en binômes, papier puis machine.

Six situations réelles, à traiter comme des incidents (diagnostic → risque → remède → prévention) :

1. `terraform.tfstate` supprimé par erreur, pas de backend distant.
2. Apply tué net (Ctrl-C ×2) : `Error acquiring the state lock`.
3. Le state a été **commité dans git** avec le mot de passe RDS dedans.
4. Une ressource détruite **à la main** en console, toujours présente dans le state.
5. Deux personnes ont appliqué en parallèle sans verrouillage : states divergents.
6. Renommage de ressource prévu : comment éviter le destroy/recreate ?

Tout ce qu'il faut a été vu ce matin. Interdiction formelle de proposer « on édite le JSON ».

</div>

---

<!-- _class: lead -->

# 4. Bonnes pratiques

## Ce qui distingue un projet pro d'un projet de stage

---

<style scoped>
div{ font-size:15px }
</style>

## `default_tags` — plus jamais de ressource anonyme

<div>

```hcl
# providers.tf du fil rouge — vous l'utilisez depuis le J3 sans le savoir
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Projet        = "stockline"
      Proprietaire  = var.prefix
      Environnement = var.environnement
      GerePar       = "terraform"
    }
  }
}
```

- Appliqué à **toutes** les ressources du provider qui acceptent des tags — fini les ressources introuvables dans la facture (douleur du TP2).
- `GerePar = "terraform"` : dans la console, on sait immédiatement qu'il ne faut **pas** toucher (la dérive du J3, prévention).
- Piège vu au J3 : ne descend **pas** dans les instances lancées par un ASG → bloc `tag { propagate_at_launch = true }`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les secrets — la synthèse du bloc

<div>

Par ordre de préférence :

1. **Ne pas avoir de secret** : rôles IAM (le module `app` n'a aucune clé), identités fédérées.
2. **Généré + coffre** : `random_password` → SSM SecureString / Secrets Manager — le motif du fil rouge, personne ne connaît le mot de passe.
3. **Coffre existant, lu par data source** : `data "aws_ssm_parameter"` — le secret est géré ailleurs, jamais dans le code.
4. En dernier recours : variable `sensitive`, valeur passée par `TF_VAR_...`, tfvars **non commité** (`secret*.tfvars` dans le `.gitignore`).

Jamais, à aucun niveau : secret en dur dans un `.tf`, un tfvars commité, un `user_data`.

Et dans tous les cas : le secret finit **en clair dans le state** → backend chiffré (fait ce matin) + accès au bucket de state **restreint** — le state EST un secret.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Moindre privilège — pour Terraform lui-même

<div>

Question jamais posée jusqu'ici : avec quels droits **Terraform** tourne-t-il ? Sur vos sandbox : les vôtres, larges. En entreprise, c'est une faute :

- Terraform en CI avec `AdministratorAccess` = toute compromission du pipeline devient une compromission **totale** du compte.
- Cible : un **rôle IAM dédié par projet** (assumé par le CI), limité aux services que le projet gère réellement — et une politique distincte, plus restreinte, pour ceux qui ne font que `plan`.
- Même logique **dans** l'infra : le rôle des instances du module `app` lit deux préfixes (SSM `/abc/stockline/*`, S3 `code`) — pas `s3:*`.

Réflexe d'audit : chaque `"Action": "*"` ou `"Resource": "*"` doit pouvoir être justifié à voix haute. Vous approfondirez au bloc 15 (CL-SECU).

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## La checklist du projet propre

<div>

Tout y est déjà dans le fil rouge — c'est votre modèle de référence :

- [ ] `required_version` + providers **épinglés** (`~>`) ; `.terraform.lock.hcl` **commité**.
- [ ] `.gitignore` posé **avant** le premier commit : state, `.terraform/`, tfplan, tfvars sensibles.
- [ ] Fichiers standards : `versions.tf`, `providers.tf`, `backend.tf`, `variables.tf`, `main.tf`, `outputs.tf`.
- [ ] Variables : `type` + `description` + `validation` ; **zéro** valeur en dur qui devrait être variable.
- [ ] `default_tags` + préfixe de nommage systématique.
- [ ] Secrets : générés/coffre, jamais dans le code ni les tfvars commités.
- [ ] `for_each` plutôt que `count` (sauf 0/1) ; noms de ressources qui disent le **rôle**.
- [ ] `depends_on` rares et **commentés** ; le reste par références.
- [ ] Backend distant chiffré + verrouillage dès qu'on n'est plus seul (donc : toujours).
- [ ] `fmt` + `validate` avant chaque commit — et bientôt tflint/checkov en CI (bloc 12).

</div>

---

<!-- _class: lead -->

# 5. tflint et checkov

## Des yeux qui ne fatiguent jamais

---

<style scoped>
div{ font-size:14px }
</style>

## tflint — le linter

<div>

`validate` vérifie la cohérence ; **tflint** attrape ce qui est *valide mais faux* :

```text
$ tflint --init && tflint

3 issue(s) found:

Error: "t3.mocro" is an invalid value as instance_type
  (aws_instance_invalid_type)
  on main.tf line 49:
  49:   instance_type = "t3.mocro"

Warning: Missing version constraint for provider "aws" in "required_providers"
  (terraform_required_providers)

Warning: terraform "required_version" attribute is required
  (terraform_required_version)
```

- `t3.mocro` : faute de frappe **syntaxiquement valide** — `validate` ne dit rien, l'apply échouerait après 30 s ; tflint le voit en 1 s, **avant**.
- Le ruleset AWS connaît les types d'instances, classes RDS, runtimes Lambda…
- Installation : binaire unique ; config `.tflint.hcl` au projet. En CI dès le bloc 12.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## checkov — le scanner de sécurité

<div>

**checkov** évalue des règles de **sécurité et conformité** sur votre HCL — avant tout apply :

```text
$ checkov -d . --quiet --compact

terraform scan results:

Passed checks: 38, Failed checks: 4, Skipped checks: 0

Check: CKV_AWS_16: "Ensure all data stored in the RDS is securely encrypted at rest"
    FAILED for resource: aws_db_instance.db
    File: /main.tf:78-87

Check: CKV_AWS_17: "Ensure all data stored in RDS is not publicly accessible"
    FAILED for resource: aws_db_instance.db
    File: /main.tf:78-87

Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
    FAILED for resource: aws_security_group.sg
    File: /main.tf:22-46

Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
    FAILED for resource: aws_security_group.sg
    File: /main.tf:22-46
```

(sortie réelle sur… le projet que vous allez critiquer dans dix minutes)

- Des centaines de règles : chiffrement, exposition publique, IMDSv2, journalisation…
- Chaque règle se **justifie ou s'ignore explicitement** (`#checkov:skip=CKV_AWS_260: ALB public assumé`) — jamais en masse.
- tflint + checkov = le filet automatique ; la **lecture du plan** reste votre filet humain. Suite au bloc 15 (CL-SECU J5, avec trivy).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 4-2 — La revue de projet

<div>

**`exercices/11-cl-iac/exercice-4-2-revue-projet.md`** — 1 h, en binômes.

`code/11-cl-iac/terraform/exemples/projet-a-critiquer/` : un projet **volontairement catastrophique** (« fait vite fait par le stagiaire »). Il compile. Il appliquerait. Tout y est faux.

Votre mission de relecteur :

1. Listez **tous** les problèmes (il y en a au moins **douze**) — y compris un qui n'est pas dans le `.tf`.
2. Classez chacun : 🔴 sécurité / 🟠 fiabilité / 🟡 maintenabilité.
3. Pour les cinq pires : la correction concrète (le code, pas l'intention).
4. Bonus : passez-y checkov, comparez avec votre liste — qu'a-t-il vu ? qu'avez-**vous** vu qu'il a raté ?

N'exécutez ni init ni apply ici (l'AVERTISSEMENT.md du dossier vous le rappelle).

</div>

---

<!-- _class: lead -->

# 6. Transition

## Terraform s'arrête à la porte de la machine

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que Terraform ne fera jamais (bien)

<div>

Regardez `modules/app/user-data.sh.tpl` : 84 lignes de bash pour installer Python, créer l'utilisateur, poser le service systemd… C'est du **shell impératif caché dans du Terraform** — la limite de l'outil :

- Terraform **provisionne** : il crée, modifie, détruit des ressources via des API.
- Il ne sait pas gérer **l'intérieur** d'une machine dans la durée : paquets, fichiers de conf, services, utilisateurs. Le user data ne s'exécute qu'**au premier boot** — pour reconfigurer, il faut… détruire l'instance.
- Modifier une ligne de conf nginx ne devrait pas exiger un remplacement d'instance.

Il manque un outil **idempotent**, qui parle aux machines existantes, décrit leur état désiré et ne change que ce qui doit l'être : **Ansible**, dès demain (J5-J7) — jusqu'à la chaîne complète Terraform → Ansible sur StockLine au J7.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Récap des 4 jours Terraform

<div>

- **J1** — déclaratif > impératif ; HCL ; cycle `init`/`plan`/`apply`/`destroy` ; **lire le plan ligne par ligne** ; le **state sacré** ; dépendances par référence.
- **J2** — variables typées/validées, locals, outputs ; data sources (AMI, AZ) ; **`for_each`** ; modules = contrat d'entrée + corps + contrat de sortie ; registry.
- **J3** — le TP2 recodé : 3 modules + front, ~50 ressources ; secrets générés → SSM → rôle IAM ; **dérive détectée** par le plan ; destroy 💰 rituel.
- **J4** — backend S3 versionné/chiffré/**verrouillé**, migration ; `state list/show/mv/rm`, bloc `moved`, `force-unlock` ; bloc **`import`** ; bonnes pratiques ; tflint/checkov ; revue de code.

Les trois mantras à emporter :

1. **On lit le plan avant d'appliquer.** Toujours. Tout le plan.
2. **Le state est sacré** : jamais dans git, jamais édité, distant + chiffré + verrouillé.
3. **Destroy chaque soir** — et vérification console. 💰

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

**Question 1.** Donnez les trois problèmes du state local qu'un backend S3 bien configuré résout, et pour chacun, la propriété du backend qui le résout (versioning, chiffrement, verrouillage, partage).

**Question 2.** Quelle commande migre un state local vers un backend S3 fraîchement déclaré ? Quelle vérification fait-on **immédiatement après**, et qu'attend-on comme résultat ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3.** Que fait `use_lockfile = true` dans un backend S3 ? Quelle était (et reste, avant Terraform 1.10) l'alternative, et que faut-il créer pour qu'elle fonctionne ?

**Question 4.** Quelle est la différence exacte entre `terraform state rm aws_s3_bucket.x` et `terraform destroy -target=aws_s3_bucket.x` — côté state et côté AWS ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5.** Vous renommez une ressource dans le code. Que montrerait le plan sans précaution ? Citez les deux mécanismes qui évitent la casse, et lequel est préférable en équipe (et pourquoi).

**Question 6.** À quoi sert un bloc `import` ? Depuis quelle version existe-t-il ? Que doit afficher le plan d'un import réussi sur les compteurs `to add / to change / to destroy` ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7.** Un apply a été tué net et le state est resté verrouillé. Quelle commande débloque, avec quel argument — et quelle vérification est **obligatoire** avant de la lancer ?

**Question 8.** Un `terraform.tfstate` contenant un mot de passe a été poussé dans git il y a trois jours. Pourquoi supprimer le fichier au prochain commit ne suffit-il pas ? Quelles sont les deux actions indispensables ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9.** Donnez un exemple concret d'erreur attrapée par tflint et un exemple attrapé par checkov — que `terraform validate` laisse passer tous les deux.

**Question 10.** Citez cinq défauts distincts du `projet-a-critiquer`, en précisant pour chacun sa catégorie : 🔴 sécurité, 🟠 fiabilité ou 🟡 maintenabilité.

</div>

---

<!-- _class: lead -->

# À demain

## Jour 5 — Ansible : configurer l'intérieur des machines

Terraform vous livre des machines allumées, joignables… et **vides**. Demain, on apprend à les remplir proprement : inventaires, playbooks, modules, **idempotence** — le même geste, rejouable cent fois, `changed=0`. Et au J7, les deux outils travailleront ensemble sur StockLine : Terraform provisionne, Ansible configure.

**Ce soir : `terraform destroy` (le state est dans S3 maintenant — mais l'infra, elle, facture toujours), vérification console : NAT, ALB, RDS, EIP.** 💰

