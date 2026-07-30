# Exercice 4-2 — Security groups vs NACL : qui bloque quoi ?

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 4)
> Durée estimée : 30 min
> Difficulté : 4 / 5
> Type : Exercice d'application — simulation sur papier (vous jouez le rôle du pare-feu)

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Évaluer le sort d'un paquet traversant successivement NACL (stateless) et security group (stateful).
- Appliquer l'évaluation ordonnée des règles NACL (numéros, première correspondance) et l'évaluation globale des règles SG.
- Diagnostiquer les pannes typiques dues aux ports éphémères oubliés sur une NACL.
- Corriger une NACL en choisissant des numéros de règles cohérents.

## Prérequis

- Avoir suivi la partie « Security groups vs NACL » du module 04 (jour 4).
- Environnement : papier, crayon.
- Outils : le tableau comparatif SG/NACL de la cheatsheet (autorisé — en poste aussi, vous l'aurez).

## Contexte

Architecture StockLine simplifiée dans le VPC `10.42.0.0/16` :

```text
 subnet PUBLIC 10.42.0.0/24  (NACL-PUB)   : [ALB 10.42.0.25] [NAT GW 10.42.0.60] [bastion 10.42.0.5]
 subnet APP    10.42.10.0/24 (NACL défaut): [EC2 app 10.42.10.14, port 8000]
 subnet DATA   10.42.20.0/24 (NACL défaut): [RDS 10.42.20.30, port 5432]
```

**Security groups** (rappel : stateful, allow uniquement, OUT tout autorisé par défaut — aucun SG ci-dessous n'a de règle sortante restrictive) :

| SG | Règles entrantes |
|---|---|
| `sg-alb` (ALB) | TCP 80 depuis 0.0.0.0/0 ; TCP 443 depuis 0.0.0.0/0 |
| `sg-app` (EC2 app) | TCP 8000 depuis `sg-alb` ; TCP 22 depuis `10.42.0.5/32` |
| `sg-db` (RDS) | TCP 5432 depuis `sg-app` |
| `sg-bastion` (bastion) | TCP 22 depuis `203.0.113.50/32` |

**NACL-PUB** (custom, appliquée au subnet public — stateless !) :

| # | Sens | Proto | Ports | Source/Dest | Action |
|---|---|---|---|---|---|
| 100 | IN | TCP | 80 | 0.0.0.0/0 | ALLOW |
| 110 | IN | TCP | 443 | 0.0.0.0/0 | ALLOW |
| 120 | IN | TCP | 1024-65535 | 0.0.0.0/0 | ALLOW |
| * | IN | tout | tout | 0.0.0.0/0 | DENY |
| 100 | OUT | TCP | 1024-65535 | 0.0.0.0/0 | ALLOW |
| 110 | OUT | TCP | 443 | 0.0.0.0/0 | ALLOW |
| * | OUT | tout | tout | 0.0.0.0/0 | DENY |

Les subnets APP et DATA utilisent la **NACL par défaut** (tout autorisé dans les deux sens).

## Énoncé

### Partie 1 — Huit paquets au tribunal

Pour chaque flux, répondez : **passe / bloqué**, et si bloqué : **par quoi exactement** (SG ou NACL, quelle règle ou absence de règle, à l'aller ou au retour). Traitez toujours l'aller **puis** le retour.

**Flux 1.** Client Internet `198.51.100.7` → ALB, TCP 443.

**Flux 2.** Client Internet → ALB, TCP 80.

**Flux 3.** Un scanner Internet → ALB, TCP 22.

**Flux 4.** ALB `10.42.0.25` → EC2 app, TCP 8000 (et la réponse).

**Flux 5.** EC2 app → RDS, TCP 5432 (et la réponse).

**Flux 6.** La réponse de RDS vers l'EC2 app : quelle règle du `sg-app` l'autorise ?

**Flux 7.** Le poste d'admin `203.0.113.50` → EC2 app directement, TCP 22 (deux raisons indépendantes de ne pas passer — trouvez-les toutes les deux).

**Flux 8.** EC2 app → dépôt de paquets sur Internet en TCP **80**, via la NAT GW (suivez le paquet : subnet APP → subnet PUBLIC → IGW ; n'oubliez pas que la NAT GW vit dans le subnet public et que NACL-PUB s'applique à ce qui **sort** de ce subnet).

### Partie 2 — Deux pannes à diagnostiquer

**Panne A.** Depuis les instances app, `apt update` échoue sur les dépôts en HTTP mais `curl https://…` fonctionne parfaitement. Expliquez la cause exacte (appuyez-vous sur votre analyse du flux 8), puis donnez la règle NACL corrective **avec son numéro** (justifiez le choix du numéro).

**Panne B.** Un admin remplace la NACL par défaut du subnet APP par une NACL custom :

| # | Sens | Proto | Ports | Source/Dest | Action |
|---|---|---|---|---|---|
| 100 | IN | TCP | 8000 | 10.42.0.0/24 | ALLOW |
| 100 | OUT | TCP | 5432 | 10.42.20.0/24 | ALLOW |
| * | IN/OUT | tout | tout | — | DENY |

Depuis, l'ALB marque toutes les instances app « unhealthy » alors que le service tourne (`ss -tlnp` montre bien uvicorn sur :8000, et on voit des connexions en `SYN-RECV`). Expliquez précisément où meurent les paquets, et corrigez la NACL (règles + numéros).

### Partie 3 — Question de synthèse

**Question.** « Le handshake TCP s'établit mais les réponses se perdent » : ce symptôme peut-il être causé par un security group ? Par une NACL ? Justifiez en une phrase chacun — c'est la question qui départage stateful et stateless.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — l'ordre de traversée</summary>

Paquet entrant dans un subnet : NACL d'abord, SG ensuite. Paquet sortant : SG (rien à vérifier s'il s'agit d'une réponse : stateful), puis NACL du subnet (qui, elle, revérifie TOUT, réponse ou pas).

</details>

<details>
<summary>Indice 2 — flux 8</summary>

Le paquet de l'instance app traverse DEUX subnets : il sort du subnet APP (NACL défaut : OK) puis entre et ressort du subnet PUBLIC via la NAT GW. Regardez les règles OUT de NACL-PUB : quels ports de destination sont autorisés vers Internet ? 80 en fait-il partie ?

</details>

<details>
<summary>Indice 3 — panne B</summary>

`SYN-RECV` = le SYN est arrivé, le serveur a répondu SYN-ACK… qui n'est jamais parvenu au client. Le SYN-ACK sort du subnet APP vers l'ALB : sur quel port de destination (côté ALB) ? Cherchez la règle OUT qui l'autoriserait.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Récrivez NACL-PUB pour bloquer en plus toute la plage `198.51.100.0/24` (réputée hostile) sur les ports web, sans rien casser d'autre. Attention aux numéros : le deny doit être évalué **avant** les allow 80/443.

**Bonus 2.** L'équipe sécurité demande : « interdisez aux instances app toute sortie sauf HTTPS ». Est-ce faisable avec le SG (rappel : allow only, OUT tout autorisé par défaut) ? Écrivez la règle sortante du `sg-app` correspondante et expliquez ce que « remplacer le défaut » signifie pour un SG.

**Bonus 3.** Justifiez en trois lignes la doctrine « SG pour autoriser finement, NACL pour bannir grossièrement » à partir de tout ce que cet exercice vous a fait constater.
