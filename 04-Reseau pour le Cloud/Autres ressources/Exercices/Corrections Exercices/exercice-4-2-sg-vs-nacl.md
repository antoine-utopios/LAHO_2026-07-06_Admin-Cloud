# Solution — Exercice 4-2 : Security groups vs NACL : qui bloque quoi ?

## Approche pédagogique

L'apprenant joue le moteur d'évaluation : NACL du subnet (stateless, ordre des numéros) puis SG (stateful, évaluation globale), aller **puis** retour. La grille de correction ci-dessous suit ce rituel pour chaque flux — exiger le même formalisme dans les copies. Les flux 6, 7 et 8 et la panne B départagent réellement les niveaux.

## Solution détaillée

### Partie 1 — Les huit flux

Rappel de méthode : entrant dans un subnet = NACL IN puis SG ; sortant = SG (rien si réponse : stateful) puis NACL OUT. La NACL matche sur le **port de destination** du paquet considéré.

**Flux 1 — Internet → ALB :443 : ✅ PASSE.**
Aller : NACL-PUB IN #110 (dport 443) ALLOW → sg-alb (443 depuis 0.0.0.0/0) ALLOW. Retour (sport 443 → dport éphémère du client) : sg-alb stateful (rien à vérifier) → NACL-PUB OUT #100 (dport 1024-65535) ALLOW.

**Flux 2 — Internet → ALB :80 : ✅ PASSE.**
Aller : IN #100 ALLOW → sg-alb (80) ALLOW. Retour : OUT #100 (dport éphémère) ALLOW.

**Flux 3 — scanner → ALB :22 : ❌ BLOQUÉ par NACL-PUB IN, règle `*` DENY.**
dport 22 ∉ {80} (#100), ∉ {443} (#110), ∉ 1024-65535 (#120) → première correspondance = `*` DENY. Le paquet **n'atteint jamais le SG** (qui l'aurait refusé aussi — mais la NACL passe en premier : réponse « bloqué par le SG » = à moitié juste seulement).

**Flux 4 — ALB → app :8000 (+ réponse) : ✅ PASSE.**
Aller : sortie du subnet public : NACL-PUB OUT #100 (dport 8000 ∈ 1024-65535) ALLOW → entrée subnet APP : NACL défaut ALLOW → sg-app (8000 depuis sg-alb, et la source EST l'ALB porteur de sg-alb) ALLOW.
Retour (sport 8000 → dport éphémère de l'ALB) : NACL défaut OUT ALLOW → entrée subnet public : NACL-PUB IN #120 (dport 1024-65535) ALLOW → sg-alb stateful.

**Flux 5 — app → RDS :5432 (+ réponse) : ✅ PASSE.**
NACL défaut des deux subnets ALLOW dans les deux sens ; sg-db autorise 5432 depuis sg-app ; retour couvert par le stateful des SG.

**Flux 6 — réponse de RDS vers app : AUCUNE règle ne l'autorise — et c'est normal.**
Question piège : la connexion a été **initiée par l'app** ; le SG est **stateful**, la réponse est automatiquement admise. `sg-app` n'a besoin d'**aucune règle entrante** pour recevoir les réponses de RDS. (Réponse « il faudrait ajouter 1024-65535 depuis sg-db » = le contresens stateless à corriger en débrief.)

**Flux 7 — admin Internet → app :22 : ❌ BLOQUÉ, deux raisons indépendantes.**
(1) **Routage** : le subnet APP est privé — aucune route entrante depuis l'IGW n'y mène et l'instance n'a pas d'adresse publique : le paquet ne peut même pas y être acheminé. (2) **sg-app** : le port 22 n'y est autorisé que depuis `10.42.0.5/32` (bastion) — 203.0.113.50 ne matche pas. Chemin légitime : SSH vers le bastion (sg-bastion : 22 depuis 203.0.113.50), puis rebond bastion → app.

**Flux 8 — app → Internet :80 via NAT GW : ❌ BLOQUÉ par NACL-PUB OUT, règle `*` DENY.**
Trajet : sortie subnet APP (NACL défaut OK, SG sortant OK) → la NAT GW (subnet public) réémet le paquet vers l'IGW : il **sort du subnet public** avec **dport 80**. NACL-PUB OUT : #100 (1024-65535 : 80 ∉), #110 (443 : non) → `*` DENY. Le flux HTTPS (dport 443), lui, passe par #110 — d'où la panne A.

### Partie 2 — Les pannes

**Panne A — apt HTTP échoue, HTTPS marche.**
Cause : celle du flux 8 — la NACL-PUB, traversée par le trafic de la NAT GW, n'autorise en sortie que les dports 443 et 1024-65535 ; les dépôts en HTTP (dport 80) tombent sur `*` DENY. Le retour, lui, serait passé (IN #120, dport éphémère de la NAT GW) : c'est bien l'aller qui meurt.

Correctif :

| # | Sens | Proto | Ports | Dest | Action |
|---|---|---|---|---|---|
| **105** | OUT | TCP | **80** | 0.0.0.0/0 | ALLOW |

Choix du numéro : n'importe quel numéro **avant `*`** fonctionne (toutes les règles sont des ALLOW disjoints, aucun conflit d'ordre) ; 105 garde les règles web groupées entre #100 et #110 — argument de lisibilité, à valoriser. (Alternative propre : ajouter aussi le commentaire « NAT GW egress ».)

**Panne B — instances « unhealthy », connexions en SYN-RECV.**
Trajet du health check : ALB → app :8000. Aller : NACL-APP custom IN #100 (8000 depuis 10.42.0.0/24) ALLOW → sg-app ALLOW → le SYN **arrive** (d'où SYN-RECV : uvicorn répond). Retour : le **SYN-ACK** repart avec sport 8000 → **dport = port éphémère de l'ALB** (1024-65535). NACL-APP OUT ne contient que « 5432 vers 10.42.20.0/24 » → `*` DENY : **le SYN-ACK meurt en sortant du subnet APP**. Le handshake n'aboutit jamais, l'ALB déclare l'instance morte.

Dégâts collatéraux à faire remarquer : les **réponses de RDS** vers l'app (sport 5432 → dport éphémère de l'app) sont aussi tuées **en entrée** (IN ne connaît que 8000), et le SSH bastion, et les sorties NAT. NACL corrigée (minimale et cohérente) :

| # | Sens | Proto | Ports | Source/Dest | Action | Rôle |
|---|---|---|---|---|---|---|
| 100 | IN | TCP | 8000 | 10.42.0.0/24 | ALLOW | ALB → app |
| 110 | IN | TCP | 22 | 10.42.0.5/32 | ALLOW | bastion → app |
| 120 | IN | TCP | 1024-65535 | 0.0.0.0/0 | ALLOW | réponses (RDS, Internet via NAT) |
| * | IN | tout | tout | — | DENY | |
| 100 | OUT | TCP | 5432 | 10.42.20.0/24 | ALLOW | app → RDS |
| 110 | OUT | TCP | **1024-65535** | 0.0.0.0/0 | ALLOW | **SYN-ACK/réponses vers ALB & bastion** |
| 120 | OUT | TCP | 443 | 0.0.0.0/0 | ALLOW | sorties HTTPS via NAT |
| 130 | OUT | TCP | 80 | 0.0.0.0/0 | ALLOW | sorties HTTP via NAT |
| * | OUT | tout | tout | — | DENY | |

Réponse alternative pleinement recevable (et professionnelle) : **revenir à la NACL par défaut** et porter tout le filtrage sur les SG — c'est la doctrine du bonus 3.

### Partie 3 — Synthèse

- **Security group : non.** Stateful : si l'aller a été admis, le retour l'est toujours — un SG ne peut pas laisser s'établir un handshake puis tuer les réponses.
- **NACL : oui.** Stateless : l'aller et le retour sont évalués indépendamment ; une règle IN sans son pendant OUT (ports éphémères) produit exactement ce symptôme.

Ce symptôme est donc une **signature** : « handshake ou trafic partiel puis silence » → chercher une NACL (ou tout filtre stateless) avant tout.

## Variantes acceptables

1. **Panne A corrigée avec un autre numéro** (#101, #115…) : juste — le raisonnement « pas de conflit car tout est ALLOW » doit apparaître.
2. **Panne B : plages resserrées** (OUT 1024-65535 limité à 10.42.0.0/24) : plus strict, valide tant que les sorties NAT (443/80 vers 0.0.0.0/0) sont traitées à part — vérifier la complétude.
3. **Flux 7 : citer la NACL par défaut comme « laissant passer »** : exact et bienvenu (elle n'est PAS une des raisons du blocage — bien classer les trois barrières : route, NACL, SG).

## Bonus

**Bonus 1.** Insérer des DENY **avant** les ALLOW web (numéros inférieurs à 100) :

| # | Sens | Proto | Ports | Source | Action |
|---|---|---|---|---|---|
| 90 | IN | TCP | 80 | 198.51.100.0/24 | DENY |
| 95 | IN | TCP | 443 | 198.51.100.0/24 | DENY |

Le reste inchangé : pour toute autre source, #90/#95 ne matchent pas et l'évaluation continue vers #100/#110. (Un DENY placé **après** #100 ne servirait à rien — première correspondance gagne.)

**Bonus 2.** Oui, c'est faisable : le « OUT tout autorisé » du SG n'est qu'une **règle par défaut**, supprimable. `sg-app` sortant : `TCP 443 → 0.0.0.0/0` (et rien d'autre) — dès qu'une règle sortante existe, le défaut disparaît et tout le reste est refusé. Point d'attention à créditer : il faudra aussi autoriser ce dont l'instance a réellement besoin (DNS UDP/53 si résolveur hors VPC, 5432 vers sg-db) — « sauf HTTPS » strict casserait la base : l'exercice montre qu'un durcissement se **rejoue flux par flux**.

**Bonus 3.** Doctrine : le SG est stateful, attaché à la ressource et capable de référencer d'autres SG → idéal pour exprimer finement « qui initie quoi vers qui », sans gérer les retours. La NACL est stateless et ne connaît que des CIDR → toute finesse y double les règles (éphémères !) et chaque oubli casse silencieusement un retour ; en revanche, son **deny** ordonné, appliqué à tout le subnet, est parfait pour bannir en bloc une plage hostile. D'où : **autoriser au SG, bannir à la NACL** — et laisser la NACL par défaut tant qu'on n'a rien à bannir.
