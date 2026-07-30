# Solution — Exercice 1-2 : Découper des réseaux : sous-réseaux, dimensionnement et VLSM

## Approche pédagogique

Après la lecture (1-1), la conception. Le point culminant est la question 11 (VLSM) : c'est le niveau attendu au TP1 et l'ancêtre direct du plan VPC du J4. Faire verbaliser la règle « du plus grand au plus petit, chaque sous-réseau commence sur un multiple de sa taille de bloc ».

## Solution détaillée

### Partie 1 — Découpages égaux

**Question 1 — 192.168.1.0/24 en 4.** 4 = 2² → 2 bits empruntés → **/26**, bloc = 64, 62 hôtes chacun.

| Sous-réseau | Plage utilisable | Broadcast | Hôtes |
|---|---|---|---|
| 192.168.1.0/26 | .1 → .62 | 192.168.1.63 | 62 |
| 192.168.1.64/26 | .65 → .126 | 192.168.1.127 | 62 |
| 192.168.1.128/26 | .129 → .190 | 192.168.1.191 | 62 |
| 192.168.1.192/26 | .193 → .254 | 192.168.1.255 | 62 |

**Question 2 — en 8.** 8 = 2³ → **/27**, bloc = 32, 2⁵ − 2 = **30 hôtes** chacun.
Réseaux : 192.168.1.**0**, **32**, **64**, **96**, **128**, **160**, **192**, **224** (/27).

**Question 3 — 10.10.0.0/16 en 8.** 3 bits → **/19**, masque 255.255.224.0, bloc = 32 dans le **3e octet**.
Réseaux : 10.10.**0**.0, 10.10.**32**.0, 10.10.**64**.0, 10.10.**96**.0, 10.10.**128**.0, 10.10.**160**.0, 10.10.**192**.0, 10.10.**224**.0 (/19).

### Partie 2 — Dimensionner

**Question 4.** Chercher 2^h ≥ besoin + 2 :

| Besoin | besoin+2 | 2^h | h | Préfixe | Disponible |
|---|---|---|---|---|---|
| a) 25 | 27 | 32 | 5 | **/27** | 30 |
| b) 100 | 102 | 128 | 7 | **/25** | 126 |
| c) 500 | 502 | 512 | 9 | **/23** | 510 |
| d) 2 | 4 | 4 | 2 | **/30** | 2 |

**Question 5.** /28 dans /24 : 2^(28−24) = **16**. /24 dans /16 : 2^(24−16) = **256**.

**Question 6.** ≥ 100 hôtes → **/25** (126 hôtes ; un /26 n'en offre que 62). /22 = 1024 adresses ; 1024 / 128 = **8 sous-réseaux /25**. Les trois premiers :

| Sous-réseau | Plage | Broadcast |
|---|---|---|
| 172.16.0.0/25 | 172.16.0.1 → 172.16.0.126 | 172.16.0.127 |
| 172.16.0.128/25 | 172.16.0.129 → 172.16.0.254 | 172.16.0.255 |
| 172.16.1.0/25 | 172.16.1.1 → 172.16.1.126 | 172.16.1.127 |

### Partie 3 — Appartenance et pièges

**Question 7.** /18 = 16+2 → 3e octet, masque 255.255.192.0, bloc = 64. Réseau donné : 10.20.128.0/18 → couvre les 3e octets **128 → 191** (10.20.128.0 → 10.20.191.255).

- `10.20.131.200` : 131 ∈ [128-191] → **oui** ;
- `10.20.100.9` : 100 < 128 (100 est dans le bloc 64-127) → **non**.

**Question 8.** /20 → 3e octet, bloc 16. 31 → multiple de 16 ≤ 31 → 16 → réseau 172.16.16.0/20, suivant 32 → **broadcast = 172.16.31.255**. L'adresse proposée **est l'adresse de broadcast** du sous-réseau : inattribuable à un serveur. Refuser (et proposer p. ex. 172.16.31.254).

**Question 9.**

a) 3e octets : 4 = `00000100`, 5 = `00000101` → identiques sur 7 bits, ne diffèrent que par le dernier ; 4 est pair (frontière /23 valide) → agrégation en **10.1.4.0/23** ✔

b) 5 = `00000101`, 6 = `00000110` → diffèrent sur les bits 7 **et** 8 ; et un /23 commençant à 5 (impair) n'est pas une frontière valide → **pas d'agrégat exact en /23**. Le plus petit préfixe couvrant les deux serait 10.1.4.0/22 (couvre 4-7 : sur-inclusif, à signaler comme tel).

**Question 10.** /27 → bloc 32.

- Machine `192.168.50.100` : multiple de 32 ≤ 100 → 96 → sous-réseau **192.168.50.96/27** (plage .97-.126, bc .127) ;
- Passerelle `192.168.50.94` : multiple ≤ 94 → 64 → sous-réseau **192.168.50.64/27** (plage .65-.94, bc .95).

La passerelle est une adresse valide… **d'un autre sous-réseau** : la machine ne peut pas l'atteindre en direct (pas d'ARP hors sous-réseau) → aucun trafic extérieur ne sort. Correctif : passerelle dans .97-.126 (classiquement .97 ou .126).

### Partie 4 — VLSM

**Question 11.** Ordre décroissant : 60 → /26 (62), 28 → /27 (30), 12 → /28 (14), 2 → /30 (2). Placement à partir de .0 :

| Nom | CIDR | Réseau | Plage utilisable | Broadcast | Hôtes (besoin) |
|---|---|---|---|---|---|
| applications | 192.168.100.0/26 | .0 | .1 → .62 | .63 | 62 (60) ✔ |
| données | 192.168.100.64/27 | .64 | .65 → .94 | .95 | 30 (28) ✔ |
| administration | 192.168.100.96/28 | .96 | .97 → .110 | .111 | 14 (12) ✔ |
| liaison | 192.168.100.112/30 | .112 | .113 → .114 | .115 | 2 (2) ✔ |

Vérification des frontières : 64 = multiple de 32 ✔, 96 = multiple de 16 ✔, 112 = multiple de 4 ✔. Aucun chevauchement, aucun trou.

**Plage libre : 192.168.100.116 → 192.168.100.255** (140 adresses pour l'avenir).

## Variantes acceptables

1. **VLSM dans un autre ordre de placement** (ex. liaison à la fin du /24, en .252/30) : valide si aucune règle de frontière n'est violée et si l'énoncé « chaque sous-réseau commence dès que possible » n'est pas exigé strictement — ici l'énoncé l'exige, donc signaler l'écart sans pénaliser lourdement.
2. **Sur-dimensionnement volontaire** (prendre /25 pour 60 hôtes « pour la croissance ») : bonne intuition d'architecte, mais hors contrainte « sans gaspillage » — à discuter en débrief, c'est exactement l'arbitrage du J4.


## Bonus

**Bonus 1.** Nouveau total minimal : invités /25 (128) + app /26 (64) + données /27 (32) + admin /28 (16) + liaison /30 (4) = **244 ≤ 256 : ça tient**, à condition de re-placer du plus grand au plus petit :

| Nom | CIDR | Plage | Broadcast |
|---|---|---|---|
| invités (110) | 192.168.100.0/25 | .1 → .126 | .127 |
| applications (60) | 192.168.100.128/26 | .129 → .190 | .191 |
| données (28) | 192.168.100.192/27 | .193 → .222 | .223 |
| administration (12) | 192.168.100.224/28 | .225 → .238 | .239 |
| liaison (2) | 192.168.100.240/30 | .241 → .242 | .243 |

Libre : .244 → .255. (Si un apprenant garde l'ancien plan et « case » le /25… il n'y a plus de multiple de 128 libre : démonstration que le VLSM se re-planifie, on ne rafistole pas.)

**Bonus 2.** 6 × 256 = 1536 adresses sur 65 536 → **≈ 2,3 %** du /16. Bonne pratique car : les sous-réseaux ne se renumérotent pas (on les détruit) ; la marge permet d'ajouter tiers, AZ et services (endpoints, load balancers) pendant des années sans toucher à l'existant.

**Bonus 3.** 3e octets 0-3 = `000000xx` → 2 bits libres → **192.168.0.0/22**.
