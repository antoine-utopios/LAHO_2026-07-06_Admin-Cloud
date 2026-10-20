---
marp: true
title: Admin Cloud — CL-IAC — Jour 6
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Ansible à l'échelle

<img style="width:150px" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyBoZWlnaHQ9IjMxNSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiIHZpZXdCb3g9IjAgMCAyNTYgMzE1IiB3aWR0aD0iMjU2IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogPGcgZmlsbD0iIzFhMTkxOCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAyODEuODYpIj4KICA8cGF0aCBkPSJtNjcuNTE2OCAzMi4wMDM1Yy0uNTQxNTIgMC0xLjEyNjE3LS4xMzY4NS0xLjUzMjEyLS42ODU4M2wtMTcuMzgzNS0yMi44NjEydjIzLjMxODdoLTMuOTY0MzF2LTI4LjcxNDJjMC0xLjE0MjUzLjk0NTkyLTIuMDU3MSAyLjAyNzgtMi4wNTcxLjYyOTcxIDAgMS4xNzA4NC4xODI2IDEuNTc0ODUuNzMxNThsMTcuMzM5NiAyMi44MTU5di0yMy4yMjc2aDMuOTYzOTJ2MjguNjY4MWMwIDEuMTg5MDctLjk0NTkyIDIuMDExNzUtMi4wMjYyNSAyLjAxMTc1Ii8+CiAgPHBhdGggZD0ibTEwMC4zMDYgMzIuMjc4Yy0zLjk2Mjc2IDAtOC4xMDY5My0uODIzNDctMTEuOTgwMy0yLjI4NTg0bC45NDYzMS0zLjI5MjdjMy41NTc5NyAxLjE0MzMyIDcuNDMwOTkgMS45NjYzOSAxMS4wMzQgMS45NjYzOSA0Ljk5OTU4IDAgNy42MTE2My0xLjc4MzQgNy42MTE2My00LjI5NzU5IDAtMi4yODY2My0yLjAyNzQxLTMuNDI5NTYtOS4wMDgxNy02LjcyMTg3LTYuOTgwNzYtMy4yOTE5Mi05LjcyNzIyLTUuMzk0NzctOS43MjcyMi05LjUxMDU1IDAtNS4xNjU2MyAzLjk2Mjc2LTcuMjcwMDYgMTEuNDM4NC03LjI3MDA2IDMuMTA4MTMgMCA3Ljg4MTYyLjY0MDg3IDEwLjYzIDEuNDYzOTVsLS42MzA4NyAzLjM4MzAyYy0zLjAxODM5LS43MzExOS02LjgwMDUxLTEuMjM0MDItOS45MDg2NC0xLjIzNDAyLTUuMjY4MzkgMC03LjQzMDYgMS4wMDUyOC03LjQzMDYgMy41MjA2NiAwIDIuNDY4NDQgMS41NzU2MiAzLjUyMDI2IDguOTYxOTQgNi45NDk4MiA3Ljc5MTg4IDMuNjEyMTYgOS43NzM0NSA1LjQ0MTMgOS43NzM0NSA5LjE4OTkyIDAgNS40NDE3LTUuMTM1MTUgOC4xMzg4OC0xMS43MSA4LjEzODg4Ii8+CiAgPHBhdGggZD0ibTEzMC43OTggMS4zMjM2N2g0LjA5ODMzdjMwLjQ1MTFoLTQuMDk4MzN6Ii8+CiAgPHBhdGggZD0ibTE2OS43NTggMTcuOTY2OWgtMTAuMTc5OHYxMC4zMzRoMTAuMTc5OGMzLjQ2NzQ2IDAgNS41ODQyMi0yLjE5NTE0IDUuNTg0MjItNS4yNTkxIDAtMi44ODA1Ny0yLjIwNjUtNS4wNzQ5Mi01LjU4NDIyLTUuMDc0OTJtLTEuOTgyNzQtMTMuMTY4NWgtOC4xOTcwNXY5LjczOTI5aDguMTk3MDVjMy4yODgzOCAwIDUuNjc1MTItMi4xMDM2NCA1LjY3NTEyLTUuMDI5NTcgMC0yLjg4MDU3LTIuMDcyMDgtNC43MDk3Mi01LjY3NTEyLTQuNzA5NzJtMi4wMjc0MSAyNi45NzY2aC0xMi4yNDk5Yy0xLjE3MTYyIDAtMi4wNzI0Ny0uOTE0OTctMi4wNzI0Ny0yLjA1NzV2LTI2LjMzNjFjMC0xLjA5Nzk2LjkwMDg2LTIuMDU3NSAyLjA3MjQ3LTIuMDU3NWgxMC4xMzMyYzYuMjE1MDkgMCA5LjkwNzg2IDMuMDYzMTcgOS45MDc4NiA3Ljg2NDM5IDAgMi42MDU2OS0xLjUzMTM0IDUuMDI5MTctMy44NzM4IDYuNDQ2NTkgMy40Njk0IDEuMDUxODIgNS44MDk5MiAzLjkzMiA1LjgwOTkyIDcuNDA2OTEgMCA0Ljg0NjU3LTQuMDA3NDMgOC43MzMyMi05LjcyNzIyIDguNzMzMjIiLz4KICA8cGF0aCBkPSJtMTk5LjIxMiAzMS43NzUxYy0xLjEyNDIyIDAtMi4wMjU0Ny0uOTYwMzItMi4wMjU0Ny0yLjA1NzV2LTI4LjM5MzZoNC4wOTc1NXYyNi43NDc5aDE2LjMwNHYzLjcwMzI2aC0xOC4zNzYxeiIvPgogIDxwYXRoIGQ9Im0yNDUuNTI2IDMyLjI3OGMtOC4zNzczIDAtMTMuNDIxNS0zLjEwODkyLTEzLjQyMTUtOS4zNzI5MSAwLTIuOTcyMDcgMS42NjY5MS01LjgwNjkgNC45MDk4NC03LjEzMjgxLTIuNjEyNDQtMS42NDYxNi0zLjk2MzE0LTMuOTc4MTQtMy45NjMxNC02LjUzODQ4IDAtNS42NjkyNiA0LjM2OTg3LTguMzY4MDIgMTIuNTY1OC04LjM2ODAyIDIuNzQ3NjMgMCA2LjYyMDI2LjMyMDYzIDkuODYzNTggMS4wNTI2MWwtLjQ1MTAxIDMuMzgzMDJjLTMuNDIyMDEtLjU0ODk4LTYuNjIxMDQtLjg2ODA0LTkuNzI4MzktLjg2ODA0LTUuMzE0NjIgMC04LjE1MjM4IDEuNDYyMzctOC4xNTIzOCA0Ljk4MzQzIDAgMi43ODk0NyAyLjYxMjgzIDQuOTgzODIgNi4wODE0NiA0Ljk4MzgyaDcuMDI1MDRjLjk5MDk4IDAgMS43NTYyNi43NzczMyAxLjc1NjI2IDEuNzM3MjYgMCAxLjAwNTY4LS43NjUyOCAxLjc4MzAxLTEuNzU2MjYgMS43ODMwMWgtNy41NjUwMWMtMy45NjQ3IDAtNi40ODU0NiAxLjk2NTYxLTYuNDg1NDYgNC45ODQyMSAwIDQuNDM0ODQgNC4wOTgzMyA1Ljc2MDc1IDkuMjMyMzIgNS43NjA3NSAyLjc5MjY5IDAgNi41NzQ0Mi0uMzY0OCA5LjYzNjcxLTEuMDk2NzhsLjU4Njk3IDMuMzM3MjdjLTIuOTI4MjcuODIzNDctNi43NTcgMS4zNzE2Ni0xMC4xMzQ3IDEuMzcxNjYiLz4KICA8cGF0aCBkPSJtMTQuMTM4IDcuMDM0NyA3LjE3NzcxIDE3Ljk4NDMtMTAuODQwNi04LjY2OTMzIDMuNjYyODYtOS4zMTQ5M3ptMTIuNzUxNCAyMi4xMjc3LTExLjAzOTktMjYuOTc0NmMtLjMxNTA1LS43NzczMy0uOTQ1OTItMS4xODkwNy0xLjcxMTU5LTEuMTg5MDdzLTEuNDQxMjEuNDExNzQtMS43NTYyNiAxLjE4OTA3bC0xMi4xMTc5IDI5LjU4NzRoNC4xNDQ1Nmw0Ljc5NzU3LTEyLjE5ODMgMTQuMzE0MiAxMS43NDA4Yy41NzU3MS40NzIwOC45OTA5OC42ODU4MyAxLjUzMjEyLjY4NTgzIDEuMDgwMzMgMCAyLjAyNjI1LS44MjI2OCAyLjAyNjI1LTIuMDExMzUgMC0uMTkyODUtLjA2Nzk4LS40OTk2OC0uMTg5MTgtLjgyOTc4eiIvPgogPC9nPgogPHBhdGggZD0ibTI1NS44NzkgMTI3Ljg2OGMwIDcwLjQ1NTEtNTcuMTEwMSAxMjcuNTY1LTEyNy41NjYgMTI3LjU2NS03MC40NTAxIDAtMTI3LjU2Ni01Ny4xMDk2LTEyNy41NjYtMTI3LjU2NSAwLTcwLjQ1MDEgNTcuMTE2MS0xMjcuNTY2IDEyNy41NjYtMTI3LjU2NiA3MC40NTYxIDAgMTI3LjU2NiA1Ny4xMTYxIDEyNy41NjYgMTI3LjU2NiIgZmlsbD0iIzFhMTkxOCIvPgogPHBhdGggZD0ibTEzMC40NiA3OC4yMjg5IDMzLjAxMTYgODEuNDc2My00OS44NjM1LTM5LjI3NzggMTYuODUxOS00Mi4xOTg0em01OC42NDQ1IDEwMC4yNDUtNTAuNzc4Ni0xMjIuMjAyYy0xLjQ0OTUyLTMuNTI0MzYtNC4zNDgwNy01LjM4OTI2LTcuODY1OTEtNS4zODkyNi0zLjUyNDM2IDAtNi42MzM4NiAxLjg2NDg5LTguMDgzMzkgNS4zODkyNmwtNTUuNzMyOSAxMzQuMDRoMTkuMDY1M2wyMi4wNjIzLTU1LjI2NTMgNjUuODM4OSA1My4xODk5YzIuNjQ3OTIgMi4xNDExNCA0LjU1ODUyIDMuMTA5NSA3LjA0MjIgMy4xMDk1IDQuOTczODkgMCA5LjMyMTQ2LTMuNzI4NzggOS4zMjE0Ni05LjExMTAxIDAtLjg3NTk0LS4zMDkzOS0yLjI2NjItLjg2OTQxLTMuNzYxNDN6IiBmaWxsPSIjZmZmIi8+Cjwvc3ZnPgo=" alt="logo"/>

## Variables, templates, rôles, vault : le même code pour 1 ou 200 machines

Bloc 11 — CL-IAC — Jour 6 (jour 47 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Utiliser les **variables** au bon endroit et prédire qui gagne (**précédence** : defaults < group_vars < host_vars < extra-vars).
- Exploiter les **facts** (`ansible_facts`) pour adapter la configuration à la machine.
- Écrire des **templates Jinja2** : `stockline.conf.j2` (nginx) et `stockline.service.j2` (systemd), avec variables et conditions.
- Déclencher des redémarrages **seulement quand il faut** : `notify` → **handlers**.
- Conditionner (`when`) et répéter (`loop`) des tâches.
- Découper le playbook d'hier en **rôles** réutilisables : `base`, `nginx`, `stockline`.
- Chiffrer les secrets avec **ansible-vault** (create/edit/rekey, `--ask-vault-pass`).
- Contrôler la qualité avec **ansible-lint** et cibler avec les **tags**.

Livrable du jour : `site.yml` + 3 rôles — le code qui tournera sur AWS demain.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **Variables** — où les mettre, qui gagne (précédence simplifiée).
2. **Facts** — ce qu'Ansible sait déjà de chaque machine.
3. **Templates Jinja2** — nginx.conf et stockline.service paramétrés.
4. **Handlers** — redémarrer un service *seulement* si sa conf a changé.
5. **Conditions et boucles** — `when`, `loop`.
6. **Rôles** — la structure standard, `ansible-galaxy init`, refactoring du J5.
7. **ansible-vault** — le mot de passe DB chiffré dans git.
8. **Qualité** — ansible-lint, tags.
9. Récap + quiz.

</div>

---

<!-- _class: lead -->

# 1. Variables

## Où les mettre, et qui gagne

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi des variables partout ?

<div>

Hier, `durcissement.yml` contenait ses valeurs **dans le play** (`vars:`). Ça suffit pour un fichier ; ça meurt à l'échelle :

- le port de StockLine apparaît dans l'unité systemd **et** dans la conf nginx → deux endroits à modifier, un oubli = panne ;
- la VM Multipass et les EC2 de demain n'ont pas la même IP, le même nombre de CPU, parfois pas le même environnement ;
- un rôle réutilisable doit fonctionner **sans être modifié** : on change ses variables, pas son code.

Principe : **le code décrit la logique, les variables portent les valeurs.** Une valeur écrite en dur dans une tâche est une future dette.

Syntaxe d'appel — toujours Jinja2, toujours entre guillemets quand la valeur commence la chaîne :

```yaml
name: "{{ stockline_utilisateur }}"
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## La précédence, version simplifiée (et suffisante)

<div>

Ansible a 22 niveaux de précédence. **Quatre suffisent en pratique**, du plus faible au plus fort :

```text
  FAIBLE                                                        FORT
    |                                                             |
 defaults        <   group_vars      <   host_vars    <   extra-vars
 (du rôle)          (all puis groupe)    (l'hôte)          (-e cli)
    |                    |                   |                 |
 « valeur           « politique         « exception       « décision
  d'usine »          du parc »           locale »           de l'instant »
```

- `roles/<rôle>/defaults/main.yml` : valeurs d'usine du rôle — **tout doit être surchargeable**.
- `group_vars/all/` puis `group_vars/<groupe>.yml` : les choix de votre organisation (le groupe précis bat `all`).
- `host_vars/<hôte>.yml` : l'exception pour UNE machine.
- `-e "stockline_port=9000"` : **gagne toujours**. Pratique en debug, dangereux en routine (invisible dans git).

Mémo : **plus c'est spécifique et proche de l'exécution, plus c'est fort.**

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Vérifier qui gagne : debug et ansible-inventory

<div>

Ne devinez pas, demandez :

```bash
# La valeur effective d'une variable pour un hôte donné
ansible srv-stockline -m ansible.builtin.debug -a "var=stockline_port"
```

```text
srv-stockline | SUCCESS => {
    "stockline_port": 8000
}
```

```bash
# Toutes les variables posées par l'inventaire et group_vars/host_vars
ansible-inventory --host srv-stockline
# La structure des groupes
ansible-inventory --graph
```

Réflexe à prendre : au moindre doute sur « quelle valeur sera utilisée ? », un `debug` avant de lancer le playbook. Trente secondes qui évitent une heure.

</div>

---

<!-- _class: lead -->

# 2. Facts

## Ce qu'Ansible sait déjà de chaque machine

---

<style scoped>
div{ font-size:14px }
</style>

## gather_facts : la première tâche de chaque play

<div>

Au début de chaque play, la tâche implicite `Gathering Facts` exécute le module `setup` et remplit `ansible_facts` : OS, IP, CPU, mémoire, disques, hostname…

```bash
ansible web -m ansible.builtin.setup | less    # tout voir (des centaines)
ansible web -m ansible.builtin.setup -a "filter=ansible_distribution*"
```

Les plus utiles :

| Fact | Exemple de valeur | Usage typique |
|------|-------------------|---------------|
| `ansible_facts['distribution']` | `Ubuntu` | choisir apt vs dnf |
| `ansible_facts['distribution_version']` | `24.04` | garde-fou de compatibilité |
| `ansible_facts['default_ipv4']['address']` | `10.42.1.12` | conf réseau, bind |
| `ansible_facts['processor_vcpus']` | `2` | dimensionner des workers |
| `ansible_facts['memtotal_mb']` | `2048` | dimensionner un cache |
| `ansible_facts['hostname']` | `srv-stockline` | bannières, en-têtes |

`gather_facts: false` dans le play pour les désactiver (gain de temps si inutiles).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Facts en action

<div>

```yaml
- name: Refuser les distributions non testées
  ansible.builtin.fail:
    msg: "Rôle validé sur Ubuntu uniquement (ici : {{ ansible_facts['distribution'] }})"
  when: ansible_facts['distribution'] != "Ubuntu"

- name: Adapter le nombre de workers uvicorn aux CPU
  ansible.builtin.set_fact:
    stockline_workers: "{{ ansible_facts['processor_vcpus'] }}"
```

Et dans un template (section suivante), un fact s'utilise comme n'importe quelle variable :

```text
# Généré pour {{ ansible_facts['hostname'] }} ({{ ansible_facts['default_ipv4']['address'] }})
```

Les facts sont ce qui rend un même rôle **portable** : le code interroge la machine au lieu de supposer.

</div>

---

<!-- _class: lead -->

# 3. Templates Jinja2

## Un modèle + des variables = la conf de chaque machine

<figure>
<svg viewBox="0 0 600 180" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <defs><marker id="j6" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="20" y="20" width="150" height="52" rx="6" fill="#6165ab"/>
  <text x="95" y="42" fill="#fff" text-anchor="middle" font-weight="bold">stockline.conf.j2</text>
  <text x="95" y="60" fill="#fff" text-anchor="middle" font-size="11">{{ nginx_port }} …</text>
  <rect x="20" y="108" width="150" height="52" rx="6" fill="#4caf82"/>
  <text x="95" y="130" fill="#fff" text-anchor="middle" font-weight="bold">variables + facts</text>
  <text x="95" y="148" fill="#fff" text-anchor="middle" font-size="11">port=80, hostname…</text>
  <rect x="250" y="60" width="120" height="60" rx="8" fill="#438ecc"/>
  <text x="310" y="88" fill="#fff" text-anchor="middle" font-weight="bold">template</text>
  <text x="310" y="106" fill="#fff" text-anchor="middle" font-size="11">(rendu Jinja2)</text>
  <rect x="440" y="55" width="150" height="70" rx="6" fill="#33404a"/>
  <text x="515" y="82" fill="#fff" text-anchor="middle" font-weight="bold">fichier rendu</text>
  <text x="515" y="102" fill="#fff" text-anchor="middle" font-size="11">listen 80; server_name …</text>
  <line x1="170" y1="46"  x2="246" y2="72"  stroke="#6165ab" stroke-width="2" marker-end="url(#j6)"/>
  <line x1="170" y1="134" x2="246" y2="108" stroke="#6165ab" stroke-width="2" marker-end="url(#j6)"/>
  <line x1="370" y1="90"  x2="436" y2="90"  stroke="#6165ab" stroke-width="2" marker-end="url(#j6)"/>
</svg>
<figcaption>Un modèle unique + les variables de chaque machine = la configuration rendue</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## copy vs template

<div>

- `copy` : dépose un fichier **identique pour tous**.
- `template` : prend un fichier **`.j2`** (Jinja2 — déjà croisé avec FastAPI au CL-PYTHON), y **injecte les variables et facts**, et dépose le **résultat rendu**.

```yaml
- name: Déposer la configuration du site nginx
  ansible.builtin.template:
    src: stockline.conf.j2        # le modèle, versionné dans git
    dest: /etc/nginx/sites-available/stockline.conf
    mode: "0644"
  notify: Recharger nginx
```

Syntaxe Jinja2, trois constructions à connaître :

| Syntaxe | Rôle |
|---------|------|
| `{{ variable }}` | insérer une valeur |
| `{% if %} … {% else %} … {% endif %}` | bloc conditionnel |
| `{% for x in liste %} … {% endfor %}` | répétition |

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## stockline.conf.j2 : la conf nginx du CL-LINUX, paramétrée

<div>

```text
# {{ ansible_managed }}
# Généré par le rôle « nginx » — toute modification manuelle sera ÉCRASÉE.

server {
{% if nginx_site_par_defaut %}
    listen {{ nginx_port_ecoute }} default_server;
{% else %}
    listen {{ nginx_port_ecoute }};
{% endif %}
    server_name {{ nginx_nom_serveur }};

    add_header X-Serveur "{{ inventory_hostname }}" always;

    location / {
        proxy_pass http://{{ nginx_backend_hote }}:{{ nginx_backend_port }};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- `{{ ansible_managed }}` : bannière « fichier géré par Ansible » — dissuade l'édition manuelle.
- `{% if %}` : le **même template** produit un site par défaut… ou non, selon la variable.
- `inventory_hostname` : variable magique = le nom de l'hôte dans l'inventaire (pratique demain avec 2 serveurs : `curl -sI` dira qui répond).

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## stockline.service.j2 : l'unité systemd templatée

<div>

```text
# {{ ansible_managed }}
[Unit]
Description=API StockLine Lite (FastAPI/uvicorn) — deployé par Ansible
After=network.target

[Service]
User={{ stockline_utilisateur }}
Group={{ stockline_utilisateur }}
WorkingDirectory={{ stockline_rep_app }}
# Le secret ne vit PAS ici (unité lisible par tous) : fichier à part, mode 0640
EnvironmentFile={{ stockline_racine }}/stockline.env
ExecStart={{ stockline_venv }}/bin/uvicorn main:app --host 127.0.0.1 --port {{ stockline_port }}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Comparez avec le `stockline.service` écrit à la main au CL-LINUX J4 : **même contenu, zéro valeur en dur**. Changer le port ? Une variable, un run, et l'unité **et** la conf nginx sont cohérentes — c'était le but.

</div>

---

<!-- _class: lead -->

# 4. Handlers

## Redémarrer un service seulement si sa conf a changé

---

<style scoped>
div{ font-size:15px }
</style>

## notify → handler : le mécanisme

<div>

Problème : après avoir déposé une conf nginx, il faut recharger nginx. Mais **pas** à chaque run — seulement si la conf a **réellement changé** (sinon : interruptions de service gratuites, et adieu `changed=0`).

```yaml
tasks:
  - name: Déposer la configuration du site
    ansible.builtin.template:
      src: stockline.conf.j2
      dest: /etc/nginx/sites-available/stockline.conf
    notify: Recharger nginx        # <- notifie SI ET SEULEMENT SI changed

handlers:
  - name: Recharger nginx          # <- le nom doit correspondre EXACTEMENT
    ansible.builtin.service:
      name: nginx
      state: reloaded
```

Règles de fonctionnement :
- un handler ne s'exécute **que s'il a été notifié** par une tâche `changed` ;
- il s'exécute **une seule fois par play, à la fin** — même notifié par 5 tâches ;
- conséquence : 3 fichiers de conf modifiés = **1 seul** reload.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Handler avec filet : tester la conf avant de recharger

<div>

Recharger nginx sur une conf invalide = site mort. Le projet chaîne deux handlers : le premier **teste**, le second recharge — si le test échoue, nginx continue de servir l'ancienne conf.

```yaml
handlers:
  - name: Recharger nginx
    ansible.builtin.command:
      cmd: nginx -t                 # test de la conf
    changed_when: false             # un test ne « change » rien
    notify: Recharger nginx - reload

  - name: Recharger nginx - reload
    ansible.builtin.service:
      name: nginx
      state: reloaded
```

Notez `changed_when: false` : `command` marquerait `changed` à chaque exécution (vu hier) ; on déclare explicitement que ce test n'est **pas** un changement. C'est le garde-fou d'idempotence appliqué aux handlers.

Piège classique : une tâche échoue **après** la notification → le handler ne tourne pas ce run-là ; au run suivant la conf est `ok` → plus de notification → service jamais rechargé. Parade : relancer avec `--force-handlers`, ou refaire converger le fichier.

</div>

---

<!-- _class: lead -->

# 5. Conditions et boucles

## when, loop

---

<style scoped>
div{ font-size:14px }
</style>

## when : exécuter sous condition

<div>

```yaml
- name: Désactiver le site par défaut du paquet nginx
  ansible.builtin.file:
    path: /etc/nginx/sites-enabled/default
    state: absent
  when: nginx_supprimer_site_defaut          # booléen -> tel quel

- name: Installer via apt (familles Debian uniquement)
  ansible.builtin.apt:
    name: nginx
  when: ansible_facts['os_family'] == "Debian"

- name: Plusieurs conditions = ET logique
  ansible.builtin.include_tasks: durcissement-avance.yml
  when:
    - environnement == "production"
    - ansible_facts['distribution_version'] is version("22.04", ">=")
```

- `when` est du **Jinja2 sans les accolades** : `when: ma_variable`, pas `when: {{ ma_variable }}`.
- Une tâche sautée apparaît en `skipped` (bleu) dans le recap — ni ok, ni changed.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## loop : répéter une tâche

<div>

```yaml
# Sur une liste simple (item = chaque valeur)
- name: Autoriser les ports entrants nécessaires
  community.general.ufw:
    rule: allow
    port: "{{ item }}"
    proto: tcp
  loop: "{{ base_ufw_ports_ouverts }}"        # [22, 80]

# Sur une liste de dictionnaires (item.cle)
- name: Créer les répertoires applicatifs
  ansible.builtin.file:
    path: "{{ item.chemin }}"
    state: directory
    mode: "{{ item.mode }}"
  loop:
    - {chemin: /opt/stockline/app, mode: "0755"}
    - {chemin: /opt/stockline/data, mode: "0750"}
```

Cas particulier à connaître : pour **installer des paquets**, ne bouclez PAS — donnez la liste au module (`name: "{{ liste }}"`) : une seule transaction apt, dix fois plus rapide, même résultat.

</div>

---

<!-- _class: lead -->

# 6. Les rôles

## De « mon playbook » à « des briques réutilisables »

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi des rôles ?

<div>

`durcissement.yml` fait 90 lignes pour UNE responsabilité. Ajoutez nginx, l'application, demain la supervision… : un playbook de 400 lignes, impossible à réutiliser ni à tester par morceau.

Le **rôle** est l'unité de réutilisation d'Ansible : un répertoire **autonome** qui regroupe tout ce qui concerne UNE responsabilité — tâches, handlers, templates, valeurs par défaut.

Découpage du projet StockLine — une responsabilité, un rôle :

| Rôle | Responsabilité | Réutilisable pour… |
|------|----------------|--------------------|
| `base` | durcissement commun (paquets, user exploit, sshd, ufw) | **tout** serveur de l'entreprise |
| `nginx` | reverse proxy paramétré | n'importe quelle app derrière nginx |
| `stockline` | l'application (user, venv, code, systemd) | chaque environnement de StockLine |

Le playbook devient une simple **composition** de rôles.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## La structure standard d'un rôle

<div>

<figure>
<svg viewBox="0 0 600 250" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12.5">
  <rect x="220" y="14" width="160" height="34" rx="6" fill="#6165ab"/>
  <text x="300" y="36" fill="#fff" text-anchor="middle" font-weight="bold">roles/nginx/</text>
  <line x1="300" y1="48" x2="300" y2="64" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="70" y1="64" x2="530" y2="64" stroke="#b8c4cf" stroke-width="2"/>
  <g>
    <rect x="20"  y="80" width="110" height="52" rx="6" fill="#438ecc"/><text x="75"  y="102" fill="#fff" text-anchor="middle">tasks/</text><text x="75"  y="120" fill="#fff" text-anchor="middle" font-size="11">main.yml</text>
    <rect x="145" y="80" width="110" height="52" rx="6" fill="#438ecc"/><text x="200" y="102" fill="#fff" text-anchor="middle">handlers/</text><text x="200" y="120" fill="#fff" text-anchor="middle" font-size="11">main.yml</text>
    <rect x="270" y="80" width="110" height="52" rx="6" fill="#438ecc"/><text x="325" y="102" fill="#fff" text-anchor="middle">templates/</text><text x="325" y="120" fill="#fff" text-anchor="middle" font-size="11">*.j2</text>
    <rect x="395" y="80" width="90"  height="52" rx="6" fill="#438ecc"/><text x="440" y="102" fill="#fff" text-anchor="middle">files/</text>
    <rect x="500" y="80" width="90"  height="52" rx="6" fill="#4caf82"/><text x="545" y="102" fill="#fff" text-anchor="middle">defaults/</text><text x="545" y="120" fill="#fff" text-anchor="middle" font-size="11">main.yml</text>
  </g>
  <line x1="75"  y1="64" x2="75"  y2="80" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="200" y1="64" x2="200" y2="80" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="325" y1="64" x2="325" y2="80" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="440" y1="64" x2="440" y2="80" stroke="#b8c4cf" stroke-width="2"/>
  <line x1="545" y1="64" x2="545" y2="80" stroke="#b8c4cf" stroke-width="2"/>
  <text x="75"  y="150" text-anchor="middle" fill="#33404a" font-size="11">les tâches</text>
  <text x="200" y="150" text-anchor="middle" fill="#33404a" font-size="11">redémarrages</text>
  <text x="325" y="150" text-anchor="middle" fill="#33404a" font-size="11">modèles Jinja2</text>
  <text x="440" y="150" text-anchor="middle" fill="#33404a" font-size="11">fichiers bruts</text>
  <text x="545" y="150" text-anchor="middle" fill="#33404a" font-size="11">variables (contrat)</text>
  <text x="300" y="185" text-anchor="middle" fill="#33404a" font-size="12">Ansible charge tasks/handlers/defaults <tspan font-style="italic">main.yml</tspan> automatiquement — convention avant configuration</text>
</svg>
<figcaption>La structure standard d'un rôle : une responsabilité, des répertoires conventionnels</figcaption>
</figure>

- **Convention avant configuration** : Ansible charge `tasks/main.yml`, `handlers/main.yml`, `defaults/main.yml` **automatiquement**. Aucun câblage à écrire.
- Dans un rôle, `template: src: stockline.conf.j2` cherche **dans `templates/` du rôle** ; `copy: src: main.py` cherche dans `files/`. Pas de chemin relatif fragile.
- Squelette généré en une commande :

```bash
ansible-galaxy init roles/monrole
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## defaults/main.yml : le contrat du rôle

<div>

Les defaults sont la **documentation vivante** du rôle : tout ce qui est paramétrable, avec une valeur raisonnable, surchargeable par n'importe quoi (précédence minimale).

```yaml
# roles/nginx/defaults/main.yml
nginx_nom_site: stockline
nginx_port_ecoute: 80
nginx_nom_serveur: "_"
nginx_site_par_defaut: true
nginx_backend_hote: 127.0.0.1
nginx_backend_port: "{{ stockline_port | default(8000) }}"
nginx_supprimer_site_defaut: true
```

Deux conventions professionnelles :

- **Préfixer chaque variable du nom du rôle** (`nginx_*`, `base_*`, `stockline_*`) : les variables sont globales chez Ansible, le préfixe évite les collisions entre rôles.
- Le filtre `| default(8000)` : le rôle fonctionne même si la variable amont n'existe pas — un rôle ne doit jamais planter sur une variable absente qu'il peut deviner.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le refactoring du jour : durcissement.yml → rôles → site.yml

<div>

```text
   HIER (J5)                          AUJOURD'HUI (J6)
   durcissement.yml                   site.yml
   ┌──────────────────┐              ┌─────────────────────────┐
   │ vars: ...        │              │ - hosts: web            │
   │ tasks:           │              │   become: true          │
   │  - apt ...       │   devient    │   roles:                │
   │  - user ...      │  ────────>   │     - base              │
   │  - sshd ...      │              │     - stockline         │
   │  - ufw ...       │              │     - nginx             │
   │ handlers: ...    │              └─────────────────────────┘
   └──────────────────┘               + roles/base/{tasks,handlers,
                                         defaults,templates}/...
```

Méthode (celle de la démo 6.1) : ① `ansible-galaxy init roles/base` — ② déplacer les tâches dans `tasks/main.yml`, les handlers dans `handlers/main.yml` — ③ les `vars:` du play deviennent `defaults/main.yml` préfixées — ④ le contenu inline `copy` devient un template — ⑤ rejouer : **`changed=0` attendu**, puisque l'état cible décrit est le même.

Le `changed=0` post-refactoring est la **preuve que le refactoring est neutre**.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## site.yml : la composition finale

<div>

```yaml
- name: Configurer les serveurs web StockLine
  hosts: web
  become: true
  any_errors_fatal: true          # un hôte échoue -> tout s'arrête (J7)

  roles:
    - role: base
      tags: [base, durcissement]
    - role: stockline
      tags: [stockline, app]
    - role: nginx
      tags: [nginx, web]

  post_tasks:
    - name: Vérifier la chaîne complète nginx -> uvicorn
      ansible.builtin.uri:
        url: "http://127.0.0.1/sante"
        status_code: 200
```

- L'ordre des rôles est **l'ordre d'exécution** : base d'abord (durcir), app ensuite, proxy enfin.
- `post_tasks` : après tous les rôles — idéal pour la **vérification** de bout en bout ; le play échoue si l'API ne répond pas. Un déploiement non vérifié n'est pas un déploiement.

</div>

---

<!-- _class: lead -->

# 7. ansible-vault

## Des secrets chiffrés DANS le dépôt git

---

<style scoped>
div{ font-size:15px }
</style>

## Le problème : le mot de passe de la base

<div>

La version complète de StockLine (TP4) parle à PostgreSQL : il faut un mot de passe. Où le mettre ?

- En clair dans `group_vars/` ? → il part dans git. **Un secret commité est un secret compromis** (historique git = pour toujours), règle du dépôt depuis le premier jour.
- Hors de git, dans un fichier local ? → chaque collègue/CI doit le recréer à la main ; ça finit sur un post-it.

**ansible-vault** : le fichier de secrets est chiffré (AES-256) **avant** d'entrer dans git. Le dépôt reste complet et partageable ; seul le **mot de passe vault** (une phrase, transmise par un canal sûr) reste hors git.

```text
git contient :   vault.yml (illisible, chiffré)   <- versionné, diffable
vous détenez :   le mot de passe vault            <- JAMAIS dans git
```

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Vault : les commandes du quotidien

<div>

```bash
# Créer un fichier chiffré (ouvre $EDITOR, chiffre à la sauvegarde)
ansible-vault create group_vars/all/vault.yml

# Éditer / afficher / changer le mot de passe / déchiffrer
ansible-vault edit  group_vars/all/vault.yml
ansible-vault view  group_vars/all/vault.yml
ansible-vault rekey group_vars/all/vault.yml
ansible-vault decrypt group_vars/all/vault.yml   # (rare — repasser en clair)
```

Contenu (côté clair) et à quoi ressemble le fichier dans git :

```yaml
vault_stockline_db_password: "F0rmation-Ut0pios-2026!"
```

```text
$ANSIBLE_VAULT;1.1;AES256
62313365396662343061393464336163383764373764613633653634306231386433626436623361
6134333665353966363534333632666535333761666131620a663537646436643839616531643561
...
```

Exécution : `ansible-playbook site.yml --ask-vault-pass` (ou `vault_password_file` dans `ansible.cfg`, pointant un fichier **gitignoré** — c'est ce que fera la CI au TP4).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le motif d'indirection (la bonne pratique à copier)

<div>

Deux fichiers dans `group_vars/all/` :

```yaml
# main.yml — EN CLAIR, versionné, lisible par tous
stockline_db_password: "{{ vault_stockline_db_password }}"
```

```yaml
# vault.yml — CHIFFRÉ (contenu une fois déchiffré)
vault_stockline_db_password: "F0rmation-Ut0pios-2026!"
```

Pourquoi cette indirection ?

- un `grep stockline_db_password` dans le code montre **où le secret est utilisé** — sans jamais révéler sa valeur ;
- le fichier chiffré ne contient **que** des variables préfixées `vault_` : on sait d'un coup d'œil ce qui est secret ;
- les rôles ne référencent jamais `vault_*` directement : le jour où le secret vient d'ailleurs (AWS Secrets Manager, vu en CL-SECU), seul `main.yml` change.

Et côté serveur ? Le secret atterrit dans `/opt/stockline/stockline.env`, **mode 0640** — jamais dans l'unité systemd, lisible par tous.

</div>

---

<!-- _class: lead -->

# 8. Qualité

## ansible-lint et tags

---

<style scoped>
div{ font-size:14px }
</style>

## ansible-lint : le tflint d'Ansible

<div>

```bash
pipx install ansible-lint     # ou pip dans le venv d'Ansible
cd code/11-cl-iac/ansible
ansible-lint
```

```text
WARNING  fqcn[action-core]: Use FQCN for builtin module actions (apt)
tasks/main.yml:12 Task/Handler: Installer nginx

WARNING  risky-file-permissions: File permissions unset or incorrect
roles/stockline/tasks/main.yml:34

WARNING  no-changed-when: Commands should not change things if nothing
needs doing  roles/nginx/handlers/main.yml:6
```

Il attrape exactement les pièges vus depuis hier : modules sans FQCN, permissions non définies, `command` sans `changed_when`, noms de tâches manquants…

Même logique que `terraform fmt` + `tflint` au J4 : **la qualité se vérifie mécaniquement, avant le run** — et au TP4, c'est le pipeline qui l'exécutera, pas vous.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Tags : exécuter une tranche du playbook

<div>

Les tags posés dans `site.yml` permettent de ne rejouer **qu'une partie** :

```bash
# Seulement le rôle nginx (itération rapide sur un template)
ansible-playbook site.yml --ask-vault-pass --tags nginx

# Tout SAUF le durcissement (déjà validé, gagne 1 minute par run)
ansible-playbook site.yml --ask-vault-pass --skip-tags base

# Lister les tags disponibles sans rien exécuter
ansible-playbook site.yml --list-tags
```

Deux mises en garde :

- les tags servent au **confort d'itération**, pas à l'architecture : le run de référence (celui de la CI, celui de la preuve) reste **le playbook complet** ;
- une tâche jamais exécutée parce que « toujours skippée par tags » est une tâche **non testée** — méfiance.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 6.1 et ✏️ exercices du jour

<div>

**Démo 6.1 — Des rôles et des templates** — `demos/11-cl-iac/demo-6-1-roles-templates.md`
Refactoring en direct : `ansible-galaxy init`, migration du J5 vers `roles/base`, template nginx avec variable modifiée → handler déclenché → rejeu `changed=0`. Puis vault : create, run avec `--ask-vault-pass`, et démonstration de ce que voit git.

**Exercice 6.1 — Templater une configuration avec conditions**
`exercices/11-cl-iac/exercice-6-1-template-conditionnel.md`
Un `stockline.env.j2` et une conf nginx qui changent selon l'environnement (`formation` vs `production`) : `{% if %}`, facts, `| default()`.

**Exercice 6.2 — Concevoir l'arborescence de rôles d'un cas d'entreprise**
`exercices/11-cl-iac/exercice-6-2-architecture-roles.md`
Sur papier : découper le SI d'une PME (3 types de serveurs, 2 environnements) en rôles, group_vars et playbooks. Sans écrire une tâche — l'architecture d'abord.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap : les points clés du jour

<div>

- **Variables** : le code porte la logique, les variables les valeurs. Précédence : `defaults` < `group_vars` < `host_vars` < `-e`. Au doute → `debug var=`.
- **Facts** : Ansible interroge chaque machine (`gather_facts`) ; un rôle portable s'appuie sur les facts, pas sur des suppositions.
- **Templates Jinja2** : `{{ }}`, `{% if %}`, `{% for %}` ; `ansible_managed` en bannière ; le même modèle sert tous les environnements.
- **Handlers** : `notify` seulement si `changed` ; exécution unique en fin de play ; testez la conf (`nginx -t`) avant de recharger.
- **Rôles** : une responsabilité par rôle, structure standard auto-chargée, variables préfixées, defaults = contrat. Refactoring prouvé par `changed=0`.
- **Vault** : secrets chiffrés dans git, mot de passe hors git, motif d'indirection `vault_*`.
- **ansible-lint** avant chaque commit ; **tags** pour itérer, playbook complet pour prouver.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 1 et 2

<div>

**Question 1** — `stockline_port` vaut 8000 dans `roles/stockline/defaults/main.yml`, 8080 dans `group_vars/web.yml`, et vous lancez `ansible-playbook site.yml -e "stockline_port=9000"`. Quelle valeur est utilisée ?

- A. 8000 — les defaults du rôle sont prioritaires
- B. 8080 — group_vars bat toujours la ligne de commande
- C. 9000 — les extra-vars (-e) ont la précédence la plus forte
- D. Erreur : Ansible refuse les définitions multiples d'une variable

**Question 2** — Quelle est la différence entre `roles/x/defaults/main.yml` et `roles/x/vars/main.yml` ?

- A. Aucune, ce sont deux emplacements équivalents
- B. defaults a une précédence très faible (surchargeable par tout) ; vars une précédence forte
- C. vars est chargé uniquement en mode --check
- D. defaults ne peut contenir que des chaînes de caractères

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Un handler notifié par 4 tâches `changed` dans le même play s'exécute :

- A. 4 fois, immédiatement après chaque tâche
- B. 1 fois, à la fin du play
- C. 1 fois, immédiatement après la première notification
- D. 0 fois : il faut l'appeler explicitement dans tasks

**Question 4** — Dans un rôle, la tâche `ansible.builtin.template: src: stockline.conf.j2` cherche le fichier source :

- A. Dans le répertoire courant d'exécution d'ansible-playbook
- B. Dans `templates/` à la racine du projet
- C. Dans `roles/<nom-du-rôle>/templates/`
- D. Dans `/etc/ansible/templates/`

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Que signifie `{{ stockline_port | default(8000) }}` dans un template ?

- A. La valeur de stockline_port est forcée à 8000
- B. Si stockline_port n'est pas définie, utiliser 8000 ; sinon utiliser sa valeur
- C. stockline_port est validée : elle doit valoir 8000, sinon erreur
- D. Le port 8000 est ouvert par défaut dans le pare-feu

**Question 6** — Pourquoi préfixer les variables d'un rôle (`nginx_port_ecoute` plutôt que `port`) ?

- A. C'est une obligation syntaxique d'ansible-core 2.16
- B. Les variables sont globales : le préfixe évite les collisions entre rôles
- C. Les variables non préfixées ne sont pas visibles dans les templates
- D. Pour que ansible-vault puisse les chiffrer

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Que contient le fichier `group_vars/all/vault.yml` une fois dans le dépôt git ?

- A. Les secrets en clair, mais dans un fichier caché
- B. Un en-tête `$ANSIBLE_VAULT` suivi du contenu chiffré en AES-256
- C. Rien : ansible-vault empêche de commiter le fichier
- D. Un lien vers un coffre-fort externe (AWS Secrets Manager)

**Question 8** — À quoi sert `ansible-vault rekey` ?

- A. À régénérer les clés SSH des machines cibles
- B. À changer le mot de passe qui protège un fichier vault
- C. À déchiffrer définitivement un fichier vault
- D. À dupliquer un fichier vault vers un autre projet

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — Après le refactoring de `durcissement.yml` en rôle `base`, vous rejouez `site.yml` sur la même VM et obtenez `changed=0`. Qu'est-ce que cela prouve ?

- A. Que le rôle ne fait rien
- B. Que le refactoring est neutre : le nouvel agencement décrit le même état cible
- C. Que la VM doit être recréée avant chaque refactoring
- D. Que les handlers ont été supprimés du rôle

**Question 10** — Un handler `command: nginx -t` sans `changed_when: false` pose quel problème ?

- A. La commande échoue car nginx -t exige un terminal interactif
- B. Il sera marqué `changed` à chaque exécution, faussant le recap et l'idempotence affichée
- C. nginx est rechargé deux fois au lieu d'une
- D. Le handler devient prioritaire sur les autres

*Réponses commentées : guide formateur (demain matin, correction collective).*

</div>

---

<!-- _class: lead -->

# À demain

## Jour 7 — la chaîne complète

Vos rôles tournent sur une VM locale. Demain : **Terraform crée** le réseau et 2 EC2 taguées, **Ansible les découvre** (inventaire dynamique `aws_ec2`) **et les configure** avec les rôles d'aujourd'hui — sans changer une ligne de rôle.

Provisionner, configurer, vérifier, détruire : la chaîne complète de l'admin cloud. Et le quiz de synthèse de TOUT le bloc IaC.
