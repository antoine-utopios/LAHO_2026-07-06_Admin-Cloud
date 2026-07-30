# Solution — Exercice 4-1 : Plans d'adressage VPC : trois scénarios d'entreprise

## Approche pédagogique

Il n'existe pas UN plan juste : on note la **cohérence** (pas de chevauchement, frontières valides, multi-AZ réel), la **justification** du CIDR et la **lisibilité** de la convention. Les plans ci-dessous sont des références ; toute variante respectant les critères est valide. Exiger les calculs posés pour au moins deux sous-réseaux par scénario.

Convention utilisée (à valoriser si les apprenants en adoptent une) : `10.X.0.0/16` par VPC ; 3e octet : 0-9 = public, 10-19 = applicatif, 20-29 = data ; chiffre des unités = AZ (0 = a, 1 = b, 2 = c).

## Solution détaillée

### Scénario 1 — VeloCity (le cas nominal)

**1. CIDR du VPC : `10.0.0.0/16`** — plage privée RFC 1918 ; /16 = 65 536 adresses, très au-delà du besoin (~40 machines) mais la marge ne coûte rien et garantit « 5 ans sans blocage » ; aucun réseau existant à éviter (mais voir bonus 1).

**2. Sous-réseaux** (AWS : 5 adresses réservées par sous-réseau → un /24 = 256 − 5 = **251 utilisables**) :

| Nom | AZ | CIDR | Plage utilisable (AWS) | Utilisables | Rôle |
|---|---|---|---|---|---|
| public-a | eu-west-3a | 10.0.0.0/24 | 10.0.0.4 → 10.0.0.254 | 251 | ALB, NAT GW-a |
| public-b | eu-west-3b | 10.0.1.0/24 | 10.0.1.4 → 10.0.1.254 | 251 | ALB, NAT GW-b |
| app-a | eu-west-3a | 10.0.10.0/24 | 10.0.10.4 → 10.0.10.254 | 251 | EC2 (ASG) |
| app-b | eu-west-3b | 10.0.11.0/24 | 10.0.11.4 → 10.0.11.254 | 251 | EC2 (ASG) |
| data-a | eu-west-3a | 10.0.20.0/24 | 10.0.20.4 → 10.0.20.254 | 251 | base primaire |
| data-b | eu-west-3b | 10.0.21.0/24 | 10.0.21.4 → 10.0.21.254 | 251 | réplica |

Calcul posé (exemple app-b) : /24 → bloc 1 au 3e octet → réseau 10.0.11.0, broadcast 10.0.11.255 ; AWS réserve .0, .1, .2, .3 et .255 → utilisables .4 → .254 = 251. Le tier app en /24 tient 30 instances de pointe avec un facteur 8 de marge ✔.

**3. Tables de routage :**

```text
 rt-public (public-a, public-b) :      rt-privee-a (app-a, data-a) :
   10.0.0.0/16 -> local                  10.0.0.0/16 -> local
   0.0.0.0/0   -> igw-velocity           0.0.0.0/0   -> nat-gw-a
                                       rt-privee-b (app-b, data-b) :
                                         10.0.0.0/16 -> local
                                         0.0.0.0/0   -> nat-gw-b
```

**Question subsidiaire — NAT Gateway :** en production : **une par AZ** (nat-gw-a dans public-a, nat-gw-b dans public-b), chaque table privée pointant vers la NAT de **son** AZ — sinon une panne d'AZ-a prive AZ-b de sortie (dépendance croisée) et le trafic inter-AZ se paie. Réponse « une seule pour raisons de coût » : acceptable **si** le compromis (SPOF de sortie + trafic inter-AZ facturé) est explicitement assumé. 💰 Rappel : ~0,05 $/h + Go **par** NAT GW.

Remarque recevable : les sous-réseaux data n'ont pas besoin de sortir → on peut les associer à une table sans route 0.0.0.0/0 du tout (défaut fermé, encore mieux).

### Scénario 2 — MetalPro (le chevauchement)

**1. CIDR du VPC : `172.20.0.0/16`.** Justification attendue :

- interdits : `10.0.0.0/16` et `192.168.0.0/16` (on-premise) — un chevauchement rendrait le VPN inutilisable pour les plages concernées (le routage ne peut pas départager deux « 10.0.5.x ») ;
- `10.50.0.0/16` serait techniquement valide (pas de chevauchement **actuel**), mais le datacenter est « quasi plein » : son extension la plus probable est ailleurs dans `10.0.0.0/8` → risque futur ;
- la plage `172.16.0.0/12` est libre chez MetalPro : `172.20.0.0/16` élimine le risque présent **et** futur. (Accepter 10.50/16 si le risque est discuté et assumé ; c'est la qualité de l'arbitrage qui est notée.)

**2. Sous-réseaux** (200 serveurs / 3 tiers / 2 AZ → ~34 par sous-réseau applicatif, /24 = large) :

| Nom | AZ | CIDR | Utilisables | Rôle |
|---|---|---|---|---|
| public-a / public-b | a / b | 172.20.0.0/24, 172.20.1.0/24 | 251 ×2 | LB, NAT GW |
| app-a / app-b | a / b | 172.20.10.0/24, 172.20.11.0/24 | 251 ×2 | serveurs applicatifs |
| data-a / data-b | a / b | 172.20.20.0/24, 172.20.21.0/24 | 251 ×2 | bases |

**3. Tables de routage** — la table privée gagne deux routes **vers l'on-premise** via la Virtual Private Gateway :

```text
 rt-privee :
   172.20.0.0/16  -> local
   10.0.0.0/16    -> vgw-metalpro     (datacenter)
   192.168.0.0/16 -> vgw-metalpro     (usines)
   0.0.0.0/0      -> nat-gw
```

(Longest prefix match : le trafic vers 10.0.x.x prend le VPN, tout le reste la NAT — mardi appliqué.) Côté on-premise, le routeur client doit symétriquement router `172.20.0.0/16` vers le tunnel : rappeler la panne « aller sans retour ».

### Scénario 3 — DataFab (le portefeuille)

**1. Plan des CIDR :**

| VPC | CIDR | Note |
|---|---|---|
| prod | 10.10.0.0/16 | 3 AZ |
| staging | 10.20.0.0/16 | 2 AZ |
| dev | 10.30.0.0/16 | 2 AZ |
| data-lab (réserve) | 10.40.0.0/16 | réservé, non créé |

Quatre /16 disjoints → tous les peerings présents et futurs restent possibles ; la numérotation par dizaines laisse la place à des déclinaisons (10.11 = prod-bis, etc.).

**2. Sous-réseaux du VPC prod (3 AZ) :**

| Nom | AZ | CIDR | Utilisables | Rôle |
|---|---|---|---|---|
| public-a/b/c | a/b/c | 10.10.0.0/24, 10.10.1.0/24, 10.10.2.0/24 | 251 ×3 | LB, NAT GW |
| app-a/b/c | a/b/c | 10.10.10.0/24, 10.10.11.0/24, 10.10.12.0/24 | 251 ×3 | applicatif |
| data-a/b/c | a/b/c | 10.10.20.0/24, 10.10.21.0/24, 10.10.22.0/24 | 251 ×3 | bases |

**3. Routes de peering staging ↔ prod** (pcx-sp), à ajouter **des deux côtés** :

```text
 tables du VPC prod    : 10.20.0.0/16 -> pcx-sp
 tables du VPC staging : 10.10.0.0/16 -> pcx-sp
```

(Et de même dev ↔ staging via pcx-ds : dev route 10.20.0.0/16 → pcx-ds ; staging route 10.30.0.0/16 → pcx-ds.)

**Question subsidiaire :** **non**, un paquet de dev ne peut pas atteindre prod via staging : le **peering n'est pas transitif** — staging ne relaie jamais le trafic d'un peering vers un autre, et aucune table de dev ne contient 10.10.0.0/16. C'est ici une **propriété de sécurité voulue** (dev isolé de prod). Si un jour la transitivité devenait souhaitable : Transit Gateway (bonus 2).

## Variantes acceptables

1. **VPC plus petits (/20)** : défendable (« on ne consommera jamais un /16 ») ; vérifier alors que le découpage interne reste correct — c'est plus difficile, et la marge perdue n'a aucune contrepartie : le dire.
2. **Sous-réseaux VLSM** (publics en /26, app en /23) : excellent si les frontières sont justes ; noter la rigueur des calculs.
3. **Scénario 2 en 10.50.0.0/16** : valide si le risque d'extension on-premise est explicitement discuté.

## Bonus

**Bonus 1.** L'entrepôt arrive en `10.0.0.0/16` → **chevauchement frontal avec le VPC VeloCity `10.0.0.0/16`** : aucun VPN/peering possible vers l'entrepôt sans NAT acrobatique. Le plan ne survit pas tel quel. Ce qu'il aurait fallu : choisir dès le départ un CIDR moins « populaire » que 10.0.0.0/16 (ex. `10.83.0.0/16` ou un bloc de 172.16/12) — 10.0.0.0/16 et 192.168.0.0/16 sont les plages les plus squattées du monde, les éviter est un réflexe d'architecte.

**Bonus 2.** Avec un **Transit Gateway** : chaque VPC n'a plus qu'une route agrégée `10.0.0.0/8 → tgw-…` (ou une par VPC distant), et le TGW centralise la matrice de connectivité. dev → prod devient **techniquement possible** ; c'est aux **tables de routage du TGW** (et aux SG) de l'interdire si la politique l'exige. Gain : N VPC = N attachements au lieu de N×(N−1)/2 peerings.

**Bonus 3.** Tier applicatif MetalPro : ~200 serveurs / 2 AZ = 100 par sous-réseau ; +50 % = **150**. Un /24 AWS offre **251** utilisables → 150 ≤ 251 ✔ (taux de remplissage 60 %, confortable). Un /25 (123 utilisables AWS : 128 − 5) serait insuffisant : le /24 est le bon choix.
