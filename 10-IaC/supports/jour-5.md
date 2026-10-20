---
marp: true
title: Admin Cloud — CL-IAC — Jour 5
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Configuration as code avec Ansible

<img style="width:150px" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyBoZWlnaHQ9IjMxNSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiIHZpZXdCb3g9IjAgMCAyNTYgMzE1IiB3aWR0aD0iMjU2IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogPGcgZmlsbD0iIzFhMTkxOCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAyODEuODYpIj4KICA8cGF0aCBkPSJtNjcuNTE2OCAzMi4wMDM1Yy0uNTQxNTIgMC0xLjEyNjE3LS4xMzY4NS0xLjUzMjEyLS42ODU4M2wtMTcuMzgzNS0yMi44NjEydjIzLjMxODdoLTMuOTY0MzF2LTI4LjcxNDJjMC0xLjE0MjUzLjk0NTkyLTIuMDU3MSAyLjAyNzgtMi4wNTcxLjYyOTcxIDAgMS4xNzA4NC4xODI2IDEuNTc0ODUuNzMxNThsMTcuMzM5NiAyMi44MTU5di0yMy4yMjc2aDMuOTYzOTJ2MjguNjY4MWMwIDEuMTg5MDctLjk0NTkyIDIuMDExNzUtMi4wMjYyNSAyLjAxMTc1Ii8+CiAgPHBhdGggZD0ibTEwMC4zMDYgMzIuMjc4Yy0zLjk2Mjc2IDAtOC4xMDY5My0uODIzNDctMTEuOTgwMy0yLjI4NTg0bC45NDYzMS0zLjI5MjdjMy41NTc5NyAxLjE0MzMyIDcuNDMwOTkgMS45NjYzOSAxMS4wMzQgMS45NjYzOSA0Ljk5OTU4IDAgNy42MTE2My0xLjc4MzQgNy42MTE2My00LjI5NzU5IDAtMi4yODY2My0yLjAyNzQxLTMuNDI5NTYtOS4wMDgxNy02LjcyMTg3LTYuOTgwNzYtMy4yOTE5Mi05LjcyNzIyLTUuMzk0NzctOS43MjcyMi05LjUxMDU1IDAtNS4xNjU2MyAzLjk2Mjc2LTcuMjcwMDYgMTEuNDM4NC03LjI3MDA2IDMuMTA4MTMgMCA3Ljg4MTYyLjY0MDg3IDEwLjYzIDEuNDYzOTVsLS42MzA4NyAzLjM4MzAyYy0zLjAxODM5LS43MzExOS02LjgwMDUxLTEuMjM0MDItOS45MDg2NC0xLjIzNDAyLTUuMjY4MzkgMC03LjQzMDYgMS4wMDUyOC03LjQzMDYgMy41MjA2NiAwIDIuNDY4NDQgMS41NzU2MiAzLjUyMDI2IDguOTYxOTQgNi45NDk4MiA3Ljc5MTg4IDMuNjEyMTYgOS43NzM0NSA1LjQ0MTMgOS43NzM0NSA5LjE4OTkyIDAgNS40NDE3LTUuMTM1MTUgOC4xMzg4OC0xMS43MSA4LjEzODg4Ii8+CiAgPHBhdGggZD0ibTEzMC43OTggMS4zMjM2N2g0LjA5ODMzdjMwLjQ1MTFoLTQuMDk4MzN6Ii8+CiAgPHBhdGggZD0ibTE2OS43NTggMTcuOTY2OWgtMTAuMTc5OHYxMC4zMzRoMTAuMTc5OGMzLjQ2NzQ2IDAgNS41ODQyMi0yLjE5NTE0IDUuNTg0MjItNS4yNTkxIDAtMi44ODA1Ny0yLjIwNjUtNS4wNzQ5Mi01LjU4NDIyLTUuMDc0OTJtLTEuOTgyNzQtMTMuMTY4NWgtOC4xOTcwNXY5LjczOTI5aDguMTk3MDVjMy4yODgzOCAwIDUuNjc1MTItMi4xMDM2NCA1LjY3NTEyLTUuMDI5NTcgMC0yLjg4MDU3LTIuMDcyMDgtNC43MDk3Mi01LjY3NTEyLTQuNzA5NzJtMi4wMjc0MSAyNi45NzY2aC0xMi4yNDk5Yy0xLjE3MTYyIDAtMi4wNzI0Ny0uOTE0OTctMi4wNzI0Ny0yLjA1NzV2LTI2LjMzNjFjMC0xLjA5Nzk2LjkwMDg2LTIuMDU3NSAyLjA3MjQ3LTIuMDU3NWgxMC4xMzMyYzYuMjE1MDkgMCA5LjkwNzg2IDMuMDYzMTcgOS45MDc4NiA3Ljg2NDM5IDAgMi42MDU2OS0xLjUzMTM0IDUuMDI5MTctMy44NzM4IDYuNDQ2NTkgMy40Njk0IDEuMDUxODIgNS44MDk5MiAzLjkzMiA1LjgwOTkyIDcuNDA2OTEgMCA0Ljg0NjU3LTQuMDA3NDMgOC43MzMyMi05LjcyNzIyIDguNzMzMjIiLz4KICA8cGF0aCBkPSJtMTk5LjIxMiAzMS43NzUxYy0xLjEyNDIyIDAtMi4wMjU0Ny0uOTYwMzItMi4wMjU0Ny0yLjA1NzV2LTI4LjM5MzZoNC4wOTc1NXYyNi43NDc5aDE2LjMwNHYzLjcwMzI2aC0xOC4zNzYxeiIvPgogIDxwYXRoIGQ9Im0yNDUuNTI2IDMyLjI3OGMtOC4zNzczIDAtMTMuNDIxNS0zLjEwODkyLTEzLjQyMTUtOS4zNzI5MSAwLTIuOTcyMDcgMS42NjY5MS01LjgwNjkgNC45MDk4NC03LjEzMjgxLTIuNjEyNDQtMS42NDYxNi0zLjk2MzE0LTMuOTc4MTQtMy45NjMxNC02LjUzODQ4IDAtNS42NjkyNiA0LjM2OTg3LTguMzY4MDIgMTIuNTY1OC04LjM2ODAyIDIuNzQ3NjMgMCA2LjYyMDI2LjMyMDYzIDkuODYzNTggMS4wNTI2MWwtLjQ1MTAxIDMuMzgzMDJjLTMuNDIyMDEtLjU0ODk4LTYuNjIxMDQtLjg2ODA0LTkuNzI4MzktLjg2ODA0LTUuMzE0NjIgMC04LjE1MjM4IDEuNDYyMzctOC4xNTIzOCA0Ljk4MzQzIDAgMi43ODk0NyAyLjYxMjgzIDQuOTgzODIgNi4wODE0NiA0Ljk4MzgyaDcuMDI1MDRjLjk5MDk4IDAgMS43NTYyNi43NzczMyAxLjc1NjI2IDEuNzM3MjYgMCAxLjAwNTY4LS43NjUyOCAxLjc4MzAxLTEuNzU2MjYgMS43ODMwMWgtNy41NjUwMWMtMy45NjQ3IDAtNi40ODU0NiAxLjk2NTYxLTYuNDg1NDYgNC45ODQyMSAwIDQuNDM0ODQgNC4wOTgzMyA1Ljc2MDc1IDkuMjMyMzIgNS43NjA3NSAyLjc5MjY5IDAgNi41NzQ0Mi0uMzY0OCA5LjYzNjcxLTEuMDk2NzhsLjU4Njk3IDMuMzM3MjdjLTIuOTI4MjcuODIzNDctNi43NTcgMS4zNzE2Ni0xMC4xMzQ3IDEuMzcxNjYiLz4KICA8cGF0aCBkPSJtMTQuMTM4IDcuMDM0NyA3LjE3NzcxIDE3Ljk4NDMtMTAuODQwNi04LjY2OTMzIDMuNjYyODYtOS4zMTQ5M3ptMTIuNzUxNCAyMi4xMjc3LTExLjAzOTktMjYuOTc0NmMtLjMxNTA1LS43NzczMy0uOTQ1OTItMS4xODkwNy0xLjcxMTU5LTEuMTg5MDdzLTEuNDQxMjEuNDExNzQtMS43NTYyNiAxLjE4OTA3bC0xMi4xMTc5IDI5LjU4NzRoNC4xNDQ1Nmw0Ljc5NzU3LTEyLjE5ODMgMTQuMzE0MiAxMS43NDA4Yy41NzU3MS40NzIwOC45OTA5OC42ODU4MyAxLjUzMjEyLjY4NTgzIDEuMDgwMzMgMCAyLjAyNjI1LS44MjI2OCAyLjAyNjI1LTIuMDExMzUgMC0uMTkyODUtLjA2Nzk4LS40OTk2OC0uMTg5MTgtLjgyOTc4eiIvPgogPC9nPgogPHBhdGggZD0ibTI1NS44NzkgMTI3Ljg2OGMwIDcwLjQ1NTEtNTcuMTEwMSAxMjcuNTY1LTEyNy41NjYgMTI3LjU2NS03MC40NTAxIDAtMTI3LjU2Ni01Ny4xMDk2LTEyNy41NjYtMTI3LjU2NSAwLTcwLjQ1MDEgNTcuMTE2MS0xMjcuNTY2IDEyNy41NjYtMTI3LjU2NiA3MC40NTYxIDAgMTI3LjU2NiA1Ny4xMTYxIDEyNy41NjYgMTI3LjU2NiIgZmlsbD0iIzFhMTkxOCIvPgogPHBhdGggZD0ibTEzMC40NiA3OC4yMjg5IDMzLjAxMTYgODEuNDc2My00OS44NjM1LTM5LjI3NzggMTYuODUxOS00Mi4xOTg0em01OC42NDQ1IDEwMC4yNDUtNTAuNzc4Ni0xMjIuMjAyYy0xLjQ0OTUyLTMuNTI0MzYtNC4zNDgwNy01LjM4OTI2LTcuODY1OTEtNS4zODkyNi0zLjUyNDM2IDAtNi42MzM4NiAxLjg2NDg5LTguMDgzMzkgNS4zODkyNmwtNTUuNzMyOSAxMzQuMDRoMTkuMDY1M2wyMi4wNjIzLTU1LjI2NTMgNjUuODM4OSA1My4xODk5YzIuNjQ3OTIgMi4xNDExNCA0LjU1ODUyIDMuMTA5NSA3LjA0MjIgMy4xMDk1IDQuOTczODkgMCA5LjMyMTQ2LTMuNzI4NzggOS4zMjE0Ni05LjExMTAxIDAtLjg3NTk0LS4zMDkzOS0yLjI2NjItLjg2OTQxLTMuNzYxNDN6IiBmaWxsPSIjZmZmIi8+Cjwvc3ZnPgo=" alt="logo"/>

## Terraform a créé les machines. Qui configure l'intérieur ?

Bloc 11 — CL-IAC — Jour 5 (jour 46 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Expliquer **ce qui manque après Terraform** : l'intérieur des machines, et pourquoi un outil dédié est nécessaire.
- Décrire la philosophie d'Ansible : **agentless, SSH, push, idempotence**.
- Installer Ansible proprement (pipx ou venv) et le vérifier.
- Écrire un **inventaire** (INI puis YAML), organiser des groupes, `host_vars`/`group_vars`.
- Utiliser les **commandes ad-hoc** (`ansible -m ping`, `-m apt`, `-m service`).
- Écrire un **premier playbook** avec les modules essentiels et `become`.
- **Prouver l'idempotence** : rejouer un playbook = `changed=0`.
- Utiliser le **check mode** (`--check --diff`) avant toute exécution réelle.

Livrable du jour : `durcissement.yml`, un playbook de durcissement rejouable à volonté sur votre VM Multipass.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **Le problème restant** — Terraform s'arrête à la porte de la machine.
2. **Ansible : philosophie et installation** — agentless, SSH, push, idempotence ; pipx / venv.
3. **L'inventaire, puis les premiers ordres** — INI, YAML, groupes, `group_vars` / `host_vars` ; commandes ad-hoc.
4. **Playbooks** — plays, tasks, modules essentiels, `become`.
5. **Idempotence et check mode** — la preuve, pas la promesse.
6. **Premier vrai playbook** — durcissement de base d'un serveur.
7. Récap + quiz.

</div>

---

<!-- _class: lead -->

# 1. Le problème restant

## Terraform s'arrête à la porte de la machine

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que vous savez faire depuis hier

<div>

Après les jours 1 à 4, votre projet Terraform (`code/11-cl-iac/terraform/`) sait créer **toute l'infrastructure** de StockLine :

- le réseau : VPC, sous-réseaux, routes, security groups (module `reseau`) ;
- les données : la base (module `donnees`) ;
- le calcul : les instances EC2 (module `app`).

`terraform apply` → quelques minutes → des machines **allumées, joignables, vides**.

Question à la salle : que reste-t-il à faire pour que `curl http://<ip>/sante` réponde `{"statut":"ok"}` ?

**Tout l'intérieur** : paquets, utilisateurs, venv Python, le code de l'application, l'unité systemd, nginx, le pare-feu… Exactement ce que vous avez fait **à la main** au bloc CL-LINUX J4.

</div>

---

<style scoped>
div{ font-size:22px }
</style>

## La frontière : provisionner vs configurer

<div>

```text
        TERRAFORM                    |               ???
   « provisionner »                  |         « configurer »
                                     |
  +------------------------+        |    +------------------------+
  | VPC, sous-réseaux      |        |    | paquets (nginx, venv)  |
  | Security groups        |        |    | utilisateurs, sudoers  |
  | Instances EC2          |   SSH  |    | fichiers de conf       |
  | Volumes, IP publiques  | ------>|    | code de l'application  |
  | Tags                   |        |    | services systemd       |
  +------------------------+        |    | pare-feu (ufw)         |
                                     |    +------------------------+
   parle à l'API du cloud            |     parle à l'OS, via SSH
```

La frontière, c'est **la carte réseau de la machine**. Dehors : Terraform. Dedans : il nous faut un autre outil.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi pas un script bash ? (vous l'avez déjà vécu)

<div>

Au CL-TP1, vous avez configuré votre serveur à la main puis par script. Problèmes constatés :

- **Non rejouable** : `useradd stockline` échoue si l'utilisateur existe déjà. `>> fichier` ajoute une ligne de plus à chaque exécution.
- **Pas de gestion d'erreur** sérieuse : le script continue après un échec, l'état final est inconnu.
- **Une machine à la fois** : boucle `for` + SSH = lent, fragile, illisible.
- **Aucune vision d'état** : le script décrit des *actions*, pas un *état cible*. Impossible de savoir si le serveur est conforme sans tout relire.

On veut la même chose que Terraform, mais pour l'intérieur : **décrire l'état cible, laisser l'outil converger**. C'est la *configuration as code*.

</div>

---

<!-- _class: lead -->

# 2. Ansible : philosophie et installation

## Agentless, SSH, push, idempotence

---

<style scoped>
div{ font-size:15px }
</style>

## Ansible en une phrase

<div>

> Ansible se connecte **en SSH** aux machines de votre inventaire et y applique des **modules** jusqu'à ce que l'état réel corresponde à l'état décrit.

Quatre mots-clés à retenir :

- **Agentless** : rien à installer sur les serveurs cibles (juste SSH + Python, déjà présents sur toute machine Ubuntu). Comparez : d'autres outils (Puppet, Chef historiquement) exigent un agent sur chaque machine.
- **SSH** : le transport, c'est celui que vous maîtrisez depuis CL-LINUX J4. Clés, pas de mot de passe.
- **Push** : *vous* déclenchez l'exécution depuis votre poste (ou depuis un pipeline CI au TP4). Rien ne tourne en permanence.
- **Idempotence** : appliquer deux fois = appliquer une fois. Le second passage ne change **rien** (`changed=0`).

</div>

---

<style scoped>
div{ font-size:22px }
</style>

## Comment ça marche sous le capot

<div>

<figure>
<svg viewBox="0 0 620 210" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <defs><marker id="p5" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker>
  <marker id="p5b" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#4caf82"/></marker></defs>
  <rect x="20" y="45" width="200" height="120" rx="8" fill="#438ecc"/>
  <text x="120" y="66" fill="#fff" text-anchor="middle" font-weight="bold">POSTE DE CONTRÔLE</text>
  <text x="120" y="90"  fill="#fff" text-anchor="middle">ansible-playbook</text>
  <text x="120" y="110" fill="#fff" text-anchor="middle">inventaire · playbook</text>
  <text x="120" y="130" fill="#fff" text-anchor="middle">modules (Python)</text>
  <text x="120" y="152" fill="#fff" text-anchor="middle" font-size="11">laptop / CI — PUSH</text>
  <rect x="400" y="45" width="200" height="120" rx="8" fill="#6165ab"/>
  <text x="500" y="66" fill="#fff" text-anchor="middle" font-weight="bold">MACHINE CIBLE</text>
  <text x="500" y="90"  fill="#fff" text-anchor="middle">sshd + Python 3</text>
  <text x="500" y="110" fill="#fff" text-anchor="middle">module copié dans /tmp</text>
  <text x="500" y="130" fill="#fff" text-anchor="middle">exécuté, répond en JSON</text>
  <text x="500" y="152" fill="#fff" text-anchor="middle" font-size="11">aucun agent installé</text>
  <line x1="220" y1="85" x2="396" y2="85" stroke="#4caf82" stroke-width="2" marker-end="url(#p5)"/>
  <text x="308" y="76" text-anchor="middle" fill="#33404a">SSH (port 22)</text>
  <line x1="396" y1="130" x2="224" y2="130" stroke="#4caf82" stroke-width="2" marker-end="url(#p5b)"/>
  <text x="308" y="146" text-anchor="middle" fill="#33404a">ok / changed / failed</text>
</svg>
<figcaption>Ansible agentless : le poste de contrôle pousse les modules en SSH</figcaption>
</figure>

Prérequis côté cible : **sshd + Python 3**. C'est tout. Pas d'agent, pas de démon, pas de port à ouvrir en plus du 22.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ok / changed / failed : le vocabulaire de la convergence

<div>

Chaque tâche Ansible se termine dans l'un de ces états :

| État | Signification | Couleur |
|------|---------------|---------|
| `ok` | l'état cible était **déjà atteint** — rien n'a été fait | vert |
| `changed` | l'outil a **modifié** le système pour atteindre l'état cible | jaune |
| `failed` | impossible d'atteindre l'état cible | rouge |
| `skipped` | tâche sautée (condition `when` fausse) | bleu |

C'est le même modèle mental que `terraform plan` : on compare **état décrit** et **état réel**, on n'agit que sur l'écart. Différence clé avec Terraform : **pas de fichier de state** — chaque module interroge l'état réel de sa ressource à chaque exécution.

Conséquence directe : sur un système déjà conforme, un playbook bien écrit affiche **`changed=0`**. C'est LE critère de qualité de la journée — et de votre TP4.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Installer ansible-core proprement

<div>

Ansible est un outil **Python**. Règle vue au CL-PYTHON : jamais de `pip install` dans le Python système. Deux voies propres :

**Voie 1 — pipx (recommandée sur le poste)** :

```bash
sudo apt install pipx            # (macOS : brew install pipx)
pipx ensurepath
pipx install --include-deps ansible
```

**Voie 2 — venv (identique à vos projets Python)** :

```bash
python3 -m venv ~/.venvs/ansible
~/.venvs/ansible/bin/pip install ansible
# puis ajouter ~/.venvs/ansible/bin au PATH, ou l'activer
```

Vérification :

```bash
ansible --version
# ansible [core 2.16.x] — il faut >= 2.16
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ansible-core, ansible, collections : qui est qui ?

<div>

- **`ansible-core`** : le moteur + ~70 modules de base (`ansible.builtin.*`). Léger.
- **`ansible` (le paquet)** : ansible-core **+ un lot de collections** communautaires pré-embarquées. Confortable en formation.
- **Collection** : un paquet de modules/plugins thématique, installé avec `ansible-galaxy`. Exemples que nous utiliserons :
  - `community.general` → module `ufw` ;
  - `ansible.posix` → module `authorized_key` ;
  - `amazon.aws` → inventaire dynamique EC2 (jour 7).

```bash
ansible-galaxy collection install -r requirements.yml
```

Les modules se nomment **en toutes lettres** (FQCN) : `ansible.builtin.apt`, `community.general.ufw`. Prenez l'habitude tout de suite — `apt` tout court fonctionne, mais le FQCN lève toute ambiguïté et `ansible-lint` l'exige.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Notre environnement de travail (les deux voies)

<div>

**Voie salle (recommandée aujourd'hui et demain) — VM Multipass locale :**

```bash
multipass launch 24.04 --name srv-stockline --cpus 2 --memory 2G --disk 10G
multipass info srv-stockline | grep IPv4        # notez l'IP !
# injecter VOTRE clé publique dans la VM :
multipass exec srv-stockline -- bash -c \
  "echo '$(cat ~/.ssh/id_ed25519.pub)' >> /home/ubuntu/.ssh/authorized_keys"
ssh ubuntu@<IP>   # doit fonctionner SANS mot de passe
```

**Voie cloud — instance EC2** (si Multipass indisponible sur votre poste) : une t3.micro Ubuntu 24.04 avec votre key pair, SG ouvert en 22 depuis la salle — vous savez faire depuis CL-AWS1 J2.

Dans les deux cas : Ubuntu 24.04, utilisateur `ubuntu`, connexion **par clé**. Ansible ne demande rien de plus.

</div>

---

<!-- _class: lead -->

# 3. L'inventaire, puis les premiers ordres

## Dire à Ansible à qui il parle — et le vérifier en ad-hoc

---

<style scoped>
div{ font-size:15px }
</style>

## L'inventaire, format INI : le plus simple

<div>

L'inventaire est **la liste des machines** gérées, rangées en **groupes**. Format historique INI — lisible immédiatement :

```ini
; inventaire.ini — nos serveurs
[web]
srv-stockline ansible_host=192.168.64.10

[db]
; (vide pour l'instant — la base arrive avec la version complète)

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

- `[web]` : un **groupe**. Un hôte peut appartenir à plusieurs groupes.
- `ansible_host` : l'IP réelle (le nom `srv-stockline` est un alias libre).
- `[web:vars]` : variables appliquées à tout le groupe.

Test : `ansible -i inventaire.ini web -m ping`

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le même inventaire, format YAML (celui du projet)

<div>

```yaml
# inventaires/multipass.yml
all:
  children:
    web:
      hosts:
        srv-stockline:
          ansible_host: 192.168.64.10
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/id_ed25519
```

- `all` : le groupe racine, contient tout le monde.
- `children` : les sous-groupes ; `hosts` : les machines ; `vars` : les variables.
- Même structure que l'INI, mais **cohérent avec le reste du projet** (tout Ansible est en YAML) et prêt pour des structures plus riches.

Nous utiliserons le YAML dans le projet ; l'INI reste très courant dans les dépôts existants — sachez lire les deux.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## group_vars / host_vars : les variables sortent de l'inventaire

<div>

Dès que les variables se multiplient, on les range **dans des fichiers dédiés**, découverts automatiquement par convention de nommage :

```text
projet-ansible/
├── ansible.cfg
├── inventaires/
│   └── multipass.yml
├── group_vars/
│   ├── all/            <- variables pour TOUS les hôtes
│   │   └── main.yml       (répertoire = plusieurs fichiers possibles)
│   └── web.yml         <- variables du groupe « web »
└── host_vars/
    └── srv-stockline.yml   <- variables de CET hôte précis
```

Règle de bon sens (précédence détaillée demain) : **plus c'est spécifique, plus c'est fort** — `host_vars` bat `group_vars/web.yml`, qui bat `group_vars/all/`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ansible.cfg : la configuration par projet

<div>

À la racine du projet, `ansible.cfg` évite de répéter les options à chaque commande :

```ini
[defaults]
inventory = inventaires/multipass.yml
roles_path = roles
interpreter_python = auto_silent

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=accept-new
pipelining = True
```

- `inventory` : plus besoin de `-i` à chaque commande.
- `StrictHostKeyChecking=accept-new` : accepte la clé d'un hôte **inconnu** (VM recréées souvent en salle) mais refuse toujours une clé qui a **changé** (protection MITM conservée).
- Ansible lit `./ansible.cfg` **du répertoire courant** : lancez toujours les commandes depuis la racine du projet.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ansible -m ping : le « hello world »

<div>

```bash
ansible web -m ping
```

```text
srv-stockline | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Attention au faux ami : `ping` **n'est pas un ICMP ping**. Ce module :

1. ouvre une connexion **SSH** vers l'hôte ;
2. y trouve un **interpréteur Python** ;
3. exécute un module trivial qui répond `pong`.

S'il passe, TOUT le nécessaire d'Ansible est validé (réseau, SSH, clé, Python). C'est le premier réflexe de diagnostic — avant toute autre commande.

`ansible all -m ping` : tout l'inventaire. `ansible srv-stockline -m ping` : un seul hôte.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Ad-hoc : installer, démarrer, exécuter

<div>

```bash
# Installer nginx (module apt) — nécessite les droits root : -b (become)
ansible web -m ansible.builtin.apt -a "name=nginx state=present" -b

# S'assurer que nginx tourne et démarre au boot
ansible web -m ansible.builtin.service -a "name=nginx state=started enabled=true" -b

# Collecter les « facts » (tout ce qu'Ansible sait de la machine)
ansible web -m ansible.builtin.setup | head -40

# Dernier recours : une commande brute (PAS idempotent — on y revient)
ansible web -m ansible.builtin.command -a "uptime"
```

- `-m` : le module ; `-a` : ses arguments ; `-b` : *become* = élévation de privilèges (sudo).
- Première exécution de l'apt : `CHANGED`. Relancez-la : `SUCCESS` (ok). **Le module a vérifié l'état avant d'agir.** Vous venez de voir l'idempotence.

L'ad-hoc sert au diagnostic et aux gestes d'urgence. Dès que ça doit être **rejouable et versionné** → playbook.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 5.1 — du ping au playbook (en deux temps)

<div>

`demos/11-cl-iac/demo-5-1-premier-playbook.md`

**Première partie (maintenant)** :

1. VM Multipass fraîche, inventaire minimal, `ansible web -m ping`.
2. Panne simulée : mauvaise clé → lecture du message d'erreur SSH.
3. Ad-hoc : `apt` deux fois de suite — `CHANGED` puis `SUCCESS`.
4. `ansible web -m setup` : ce qu'Ansible sait déjà de la machine.

**Seconde partie (cet après-midi, après la section playbooks)** :
`durcissement.yml` de bout en bout — check mode, exécution, **rejeu à `changed=0`**, sabotage manuel réparé par le run suivant.

Ce que vous devez retenir : **à quel moment** l'état change (jaune) et à quel moment il ne change plus (vert).

</div>

---

<!-- _class: lead -->

# 4. Playbooks

## L'état cible, versionné dans un fichier

---

<style scoped>
div{ font-size:14px }
</style>

## Anatomie d'un playbook

<div>

```yaml
# premier-playbook.yml
---
- name: Installer et démarrer nginx          # <- un PLAY
  hosts: web                                 # cible : le groupe « web »
  become: true                               # sudo pour tout le play

  tasks:                                     # <- la liste des TÂCHES
    - name: Installer nginx                  # nom lisible (affiché au run)
      ansible.builtin.apt:                   # <- le MODULE
        name: nginx                          # ses paramètres :
        state: present                       #    « nginx doit être présent »

    - name: Démarrer nginx et l'activer au boot
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
```

Un **playbook** contient un ou plusieurs **plays** ; un play cible des **hôtes** et exécute des **tâches** dans l'ordre ; chaque tâche appelle un **module** avec des paramètres qui décrivent un **état**, pas une action.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Lire une exécution de playbook

<div>

```text
$ ansible-playbook premier-playbook.yml

PLAY [Installer et démarrer nginx] *********************************

TASK [Gathering Facts] *********************************************
ok: [srv-stockline]

TASK [Installer nginx] *********************************************
changed: [srv-stockline]

TASK [Démarrer nginx et l'activer au boot] *************************
ok: [srv-stockline]

PLAY RECAP *********************************************************
srv-stockline : ok=3  changed=1  unreachable=0  failed=0  skipped=0
```

- `Gathering Facts` : tâche implicite qui collecte les infos machine (demain).
- Le **PLAY RECAP** est votre tableau de bord : ici `changed=1` (nginx installé). Relancez : `changed=0`. Toujours finir en lisant le recap.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Les modules essentiels (1/2) : apt, copy, file

<div>

```yaml
- name: Installer une liste de paquets
  ansible.builtin.apt:
    name: [ufw, curl, vim]
    state: present            # ou : absent, latest
    update_cache: true
    cache_valid_time: 3600    # apt update au plus 1 fois/heure -> idempotent

- name: Déposer un fichier avec contenu maîtrisé
  ansible.builtin.copy:
    dest: /etc/motd
    content: "Serveur géré par Ansible — ne rien modifier à la main.\n"
    owner: root
    group: root
    mode: "0644"              # TOUJOURS en chaîne : "0644", pas 0644

- name: Garantir qu'un répertoire existe avec les bons droits
  ansible.builtin.file:
    path: /opt/stockline/data
    state: directory          # ou : touch, link, absent
    owner: stockline
    mode: "0755"
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Les modules essentiels (2/2) : user, service, lineinfile

<div>

```yaml
- name: Créer l'utilisateur d'exploitation
  ansible.builtin.user:
    name: exploit
    shell: /bin/bash
    groups: sudo
    append: true              # AJOUTE au groupe (sans, remplace la liste !)

- name: S'assurer qu'un service tourne et démarre au boot
  ansible.builtin.service:
    name: nginx
    state: started            # started/stopped/restarted/reloaded
    enabled: true

- name: Garantir UNE ligne précise dans un fichier existant
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^#?PermitRootLogin"   # la ligne à remplacer si elle existe
    line: "PermitRootLogin no"     # l'état cible
```

`lineinfile` = le remplaçant idempotent de `echo >> fichier` : la ligne est présente **une fois**, quelle que soit la situation de départ. Pour un fichier entier → `copy`, ou `template` (demain).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## become : l'élévation de privilèges explicite

<div>

Ansible se connecte en `ubuntu` (utilisateur normal). Installer un paquet exige root : c'est **become**.

```yaml
- name: Durcissement du serveur
  hosts: web
  become: true          # tout le play en sudo
```

```yaml
    - name: Cette tâche seulement en root
      ansible.builtin.apt: {name: ufw, state: present}
      become: true      # ou tâche par tâche
```

- Sous le capot : `sudo` (configurable). L'utilisateur `ubuntu` des images cloud a `NOPASSWD` — rien à saisir.
- **L'oubli de `become` est l'erreur n°1 du jour** : elle se manifeste par `Permission denied`, `Failed to lock apt`, ou `E: Could not open lock file`. Réflexe : lire l'erreur, penser « become ? ».
- Bonne pratique : `become` au niveau du play quand tout le play administre la machine — pas de saupoudrage.

</div>

---

<!-- _class: lead -->

# 5. Idempotence et check mode

## La preuve, pas la promesse

<figure>
<svg viewBox="0 0 520 180" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <text x="130" y="24" text-anchor="middle" fill="#33404a" font-weight="bold">1er run</text>
  <text x="390" y="24" text-anchor="middle" fill="#33404a" font-weight="bold">2e run (rejeu)</text>
  <!-- run 1 -->
  <rect x="40"  y="40" width="60" height="90" fill="#e0912f"/><text x="70"  y="150" text-anchor="middle">changed</text><text x="70" y="34" text-anchor="middle" font-size="12">4</text>
  <rect x="120" y="70" width="60" height="60" fill="#4caf82"/><text x="150" y="150" text-anchor="middle">ok</text><text x="150" y="64" text-anchor="middle" font-size="12">3</text>
  <!-- run 2 -->
  <rect x="300" y="128" width="60" height="2" fill="#e0912f"/><text x="330" y="150" text-anchor="middle">changed</text><text x="330" y="120" text-anchor="middle" font-size="12" fill="#4caf82" font-weight="bold">0</text>
  <rect x="380" y="40" width="60" height="90" fill="#4caf82"/><text x="410" y="150" text-anchor="middle">ok</text><text x="410" y="34" text-anchor="middle" font-size="12">7</text>
  <line x1="240" y1="40" x2="240" y2="140" stroke="#b8c4cf" stroke-width="1" stroke-dasharray="3 3"/>
  <text x="260" y="170" text-anchor="middle" fill="#33404a" font-size="12">changed=0 au second passage = idempotence prouvée</text>
</svg>
<figcaption>Le rejeu d'un playbook conforme n'affiche plus aucun changement</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## L'idempotence : définition opérationnelle

<div>

> Un playbook est **idempotent** si son second passage sur le même système ne change **rien** : `changed=0`.

Pourquoi c'est non négociable :

- **Confiance** : on peut le rejouer à tout moment (après un doute, un incident, un changement de variable) sans casser quoi que ce soit.
- **Détection de dérive** : un run qui affiche `changed=3` sur un parc « conforme » révèle que quelqu'un a modifié les serveurs à la main.
- **Automatisation** : le TP4 rejouera ce playbook **à chaque push**. Non idempotent = redémarrages de services à chaque pipeline = incidents.

Les **modules** sont idempotents par construction (ils vérifient avant d'agir). Ce qui casse l'idempotence, c'est **vous** : `shell` et `command` mal employés.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Ce qui casse l'idempotence : shell et command

<div>

`ansible.builtin.command` / `shell` exécutent une commande brute : Ansible **ne peut pas savoir** si elle a changé quelque chose → il marque `changed` **à chaque fois**.

```yaml
# ANTI-EXEMPLE — changed à chaque run, et bugs en prime :
- name: Créer l'utilisateur                 # explose au 2e run (user exists)
  ansible.builtin.shell: useradd exploit

- name: Ouvrir le port                      # une ligne AJOUTÉE à chaque run
  ansible.builtin.shell: echo "port 8000" >> /etc/app.conf
```

Remède, dans l'ordre :

1. **Un module existe ?** → utilisez-le (`user`, `lineinfile`, `copy`…). 95 % des cas.
2. Vraiment aucun module ? → `command` + garde-fous :
   - `creates: /chemin/temoin` → sauté si le fichier existe déjà ;
   - `changed_when:` → dire à Ansible ce qui compte comme un changement.

L'exercice 5.2 vous fera réparer un playbook cassé exactement comme ça.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Check mode : répéter avant de jouer

<div>

```bash
ansible-playbook durcissement.yml --check --diff
```

- `--check` : **simulation**. Ansible interroge l'état réel et annonce ce qu'il *ferait* (`changed`), sans **rien modifier**.
- `--diff` : pour les fichiers, affiche le **diff** ligne à ligne entre l'existant et la cible.

```text
TASK [Interdire la connexion SSH root] ***************************
--- before: /etc/ssh/sshd_config.d/99-durcissement.conf
+++ after: ...
+PermitRootLogin no
+PasswordAuthentication no
changed: [srv-stockline]
```

C'est le `terraform plan` d'Ansible. Réflexe professionnel : **`--check --diff` d'abord, exécution ensuite** — surtout sur des machines que vous n'avez pas créées vous-même.

Limite honnête : certaines tâches dépendantes l'une de l'autre (installer puis configurer) peuvent afficher des erreurs en check sur un système vierge — normal, la 1re n'a pas réellement eu lieu.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le rituel de qualité (à appliquer dès aujourd'hui)

<div>

Pour **tout** playbook, dans cet ordre :

```bash
# 1. La syntaxe est-elle valide ?
ansible-playbook durcissement.yml --syntax-check

# 2. Que ferait-il ? (simulation + diffs)
ansible-playbook durcissement.yml --check --diff

# 3. Exécution réelle
ansible-playbook durcissement.yml

# 4. LA PREUVE d'idempotence : rejouer immédiatement
ansible-playbook durcissement.yml
#    PLAY RECAP attendu : ok=N  changed=0  failed=0
```

L'étape 4 n'est pas optionnelle : c'est elle qui transforme « je pense que c'est bon » en « c'est prouvé ». La grille du TP4 note ce `changed=0`.

</div>

---

<!-- _class: lead -->

# 6. Premier vrai playbook

## Durcir un serveur, et pouvoir le refaire mille fois

---

<style scoped>
div{ font-size:15px }
</style>

## Le cahier des charges de durcissement.yml

<div>

Ce que tout serveur StockLine doit garantir **avant** d'héberger quoi que ce soit — c'est le durcissement du CL-LINUX J4, industrialisé :

1. **Paquets** : `ufw`, `unattended-upgrades`, `curl`, `vim` présents, cache apt frais.
2. **Utilisateur d'exploitation** `exploit` : shell bash, membre de `sudo`, **votre clé publique** autorisée, sudo sans mot de passe (fichier sudoers **validé** avant dépôt).
3. **sshd durci** : pas de root, pas de mot de passe, 3 essais max — via un **drop-in** `/etc/ssh/sshd_config.d/99-durcissement.conf` (la config d'origine reste intacte), **validé** par `sshd -t` avant dépôt, sshd redémarré **seulement si le fichier a changé**.
4. **Pare-feu ufw** : politique entrante `deny`, ports 22 et 80 autorisés.

Fichier complet : `code/11-cl-iac/ansible/durcissement.yml` — parcourons-le.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## durcissement.yml (extrait 1/2) : paquets et utilisateur

<div>

```yaml
- name: Durcissement de base d'un serveur Ubuntu
  hosts: web
  become: true
  vars:
    paquets_de_base: [ufw, unattended-upgrades, curl, vim]
    utilisateur_exploitation: exploit
    cle_publique: "{{ lookup('ansible.builtin.file',
                     lookup('ansible.builtin.env', 'HOME') + '/.ssh/id_ed25519.pub') }}"
  tasks:
    - name: Mettre à jour le cache apt (au plus une fois par heure)
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600        # <- garde l'idempotence du cache

    - name: Installer les paquets de base
      ansible.builtin.apt:
        name: "{{ paquets_de_base }}"
        state: present

    - name: Créer l'utilisateur d'exploitation
      ansible.builtin.user:
        name: "{{ utilisateur_exploitation }}"
        shell: /bin/bash
        groups: sudo
        append: true

    - name: Autoriser la clé publique de l'exploitant
      ansible.posix.authorized_key:
        user: "{{ utilisateur_exploitation }}"
        key: "{{ cle_publique }}"
```

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## durcissement.yml (extrait 2/2) : sshd validé, notify, ufw

<div>

```yaml
    - name: Interdire la connexion SSH root et par mot de passe
      ansible.builtin.copy:
        dest: /etc/ssh/sshd_config.d/99-durcissement.conf
        content: |
          PermitRootLogin no
          PasswordAuthentication no
          MaxAuthTries 3
        mode: "0644"
        validate: "sshd -t -f %s"      # <- config testée AVANT d'écraser
      notify: Redémarrer sshd          # <- seulement si changed

    - name: Autoriser les ports entrants nécessaires (ufw)
      community.general.ufw: {rule: allow, port: "{{ item }}", proto: tcp}
      loop: [22, 80]

    - name: Activer ufw (politique par défaut = tout refuser en entrée)
      community.general.ufw: {state: enabled, policy: deny, direction: incoming}

  handlers:
    - name: Redémarrer sshd
      ansible.builtin.service: {name: ssh, state: restarted}
```

Deux filets de sécurité à retenir : **`validate`** (jamais écraser une conf sshd/sudoers sans l'avoir testée — sinon vous vous enfermez dehors) et **`notify`/handler** (redémarrer un service *uniquement* quand sa conf a changé — approfondi demain).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercices de la journée

<div>

**Exercice 5.1 — Écrire un playbook idempotent et le prouver**
`exercices/11-cl-iac/exercice-5-1-playbook-idempotent.md`
Page d'accueil de maintenance + paquets + service, sur votre VM Multipass. Livrable : deux PLAY RECAP (premier run, puis `changed=0`).

**Exercice 5.2 — Réparer un playbook NON idempotent**
`exercices/11-cl-iac/exercice-5-2-reparer-idempotence.md`
Un playbook truffé de `shell`/`command` mal employés fonctionne… mais affiche `changed=5` à chaque run et casse au 2e passage. Diagnostiquez, remplacez par les bons modules, prouvez `changed=0`.

Corrigés : `solutions/11-cl-iac/` — après votre tentative, pas avant.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap : les points clés du jour

<div>

- Terraform **provisionne** (dehors), Ansible **configure** (dedans) : la frontière est la carte réseau de la machine.
- Ansible = **agentless** (SSH + Python cible, rien d'autre), **push**, **sans state** : l'état réel est interrogé à chaque run.
- **Inventaire** : des hôtes dans des groupes ; variables dans `group_vars`/`host_vars` ; `ansible.cfg` par projet.
- Ad-hoc pour le diagnostic ; **playbook** pour tout ce qui doit être rejouable et versionné.
- Une tâche décrit un **état** (`state: present`), pas une action — c'est le module qui converge.
- `become` = sudo explicite ; son oubli = l'erreur n°1.
- **Idempotence prouvée** : rejouer = `changed=0`. `shell`/`command` la cassent ; modules d'abord, garde-fous sinon.
- Rituel : `--syntax-check` → `--check --diff` → exécution → **rejeu de preuve**.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 1 et 2

<div>

**Question 1** — Ansible est dit « agentless ». Concrètement, de quoi une machine Ubuntu cible a-t-elle besoin pour être gérée par Ansible ?

- A. Un agent `ansibled` installé et démarré via systemd
- B. Uniquement sshd et un interpréteur Python 3
- C. Docker, pour exécuter les modules dans des conteneurs
- D. Un compte root accessible en SSH avec mot de passe

**Question 2** — Vous relancez un playbook bien écrit sur un serveur déjà conforme. Que doit afficher le PLAY RECAP ?

- A. `ok=0 changed=0` — rien n'est exécuté du tout
- B. `changed=0` — les tâches sont évaluées mais rien n'est modifié
- C. Le même nombre de `changed` qu'au premier passage
- D. Une erreur : un playbook ne peut pas être exécuté deux fois

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Que fait réellement `ansible web -m ping` ?

- A. Il envoie des paquets ICMP aux hôtes du groupe web
- B. Il teste la connexion SSH et l'exécution d'un module Python sur chaque hôte
- C. Il vérifie que le port 80 des hôtes répond
- D. Il mesure la latence réseau entre le poste et les hôtes

**Question 4** — Une tâche `apt` échoue avec `Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)`. Cause la plus probable ?

- A. Le paquet n'existe pas dans les dépôts
- B. La machine cible n'a pas d'accès Internet
- C. `become: true` manque : la tâche s'exécute sans privilèges root
- D. Le cache apt est corrompu, il faut redémarrer la VM

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Quelle affirmation sur l'inventaire est correcte ?

- A. Un hôte ne peut appartenir qu'à un seul groupe
- B. Le format YAML est obligatoire depuis ansible-core 2.16
- C. `group_vars/web.yml` est chargé automatiquement pour les hôtes du groupe `web`
- D. Les variables ne peuvent être définies que dans le fichier d'inventaire

**Question 6** — Pourquoi la tâche `ansible.builtin.shell: echo "port 8000" >> /etc/app.conf` est-elle un problème ?

- A. Le module shell n'a pas le droit d'écrire dans /etc
- B. Elle ajoute une ligne supplémentaire à chaque exécution et est marquée `changed` à chaque run
- C. Il faudrait utiliser `command` au lieu de `shell` pour les redirections
- D. echo n'est pas disponible sur Ubuntu Server

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Que fait `ansible-playbook site.yml --check --diff` ?

- A. Il applique le playbook puis affiche ce qui a changé
- B. Il vérifie uniquement la syntaxe YAML du playbook
- C. Il simule l'exécution sans rien modifier et affiche les diffs des fichiers
- D. Il compare le playbook avec sa version précédente dans git

**Question 8** — Quelle est la différence fondamentale entre Ansible et Terraform concernant l'état ?

- A. Ansible stocke son state dans S3, Terraform en local
- B. Terraform maintient un fichier de state ; Ansible interroge l'état réel des ressources à chaque exécution
- C. Ansible et Terraform partagent le même fichier de state
- D. Aucune : les deux outils gèrent l'état de la même façon

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — Dans une tâche `copy` qui dépose un fichier sudoers, à quoi sert `validate: "visudo -cf %s"` ?

- A. À vérifier que le fichier n'existe pas déjà
- B. À tester la validité du fichier AVANT de le mettre en place — s'il est invalide, rien n'est écrasé
- C. À valider que l'utilisateur a le droit d'utiliser sudo
- D. À chiffrer le fichier avant le transfert SSH

**Question 10** — Vous devez garantir que la ligne `PermitRootLogin no` figure dans un fichier de configuration existant, sans toucher au reste du fichier. Quel module est le plus adapté ?

- A. `ansible.builtin.shell` avec `sed -i`
- B. `ansible.builtin.copy` avec le contenu complet du fichier
- C. `ansible.builtin.lineinfile` avec `regexp` et `line`
- D. `ansible.builtin.file` avec `state: touch`

*Réponses commentées : guide formateur (demain matin, correction collective).*

</div>

---

<!-- _class: lead -->

# À demain

## Jour 6 — passer à l'échelle

Votre playbook fonctionne sur UNE machine. Demain : variables et précédence, facts, **templates Jinja2** (nginx et systemd paramétrés), handlers, boucles et conditions, découpage en **rôles** réutilisables (`base`, `nginx`, `stockline`), secrets chiffrés avec **ansible-vault**, qualité avec **ansible-lint**.

Le même code servira 1 machine… ou 200.
