# Solution — Exercice 2-1 : Compléter des tables de routage

## Approche pédagogique

L'exercice fait manipuler les trois idées du matin : réseaux directs vs routes apprises, route par défaut, longest prefix match — puis les deux pannes canoniques. Insister sur la question 9 : l'asymétrie aller/retour est LE piège que les apprenants recroiseront avec les peerings VPC et les NACL.

## Solution détaillée

### Partie 1 — Question 1 : la liaison /30

```text
10.0.12.0/30 : bloc = 256 - 252 = 4
réseau    = 10.0.12.0
utilisables = 10.0.12.1 (R1) et 10.0.12.2 (R2)   ✔ valides
broadcast = 10.0.12.3
```

Un /30 offre **exactement 2 adresses** utilisables : parfait pour une liaison routeur-routeur, zéro gaspillage (2 hôtes = le besoin exact).

### Partie 2 — Les tables

**Question 2 — PC-A** (passerelle par défaut : **192.168.1.1**) :

| Destination | Via | Interface |
|---|---|---|
| 192.168.1.0/24 | — (directe) | eth0 |
| 0.0.0.0/0 | 192.168.1.1 | eth0 |

**Question 3 — R1** :

| Destination | Via | Interface |
|---|---|---|
| 192.168.1.0/24 | — (directe) | eth0 |
| 10.0.12.0/30 | — (directe) | eth1 |
| 203.0.113.0/24 | — (directe) | eth2 |
| 192.168.2.0/24 | 10.0.12.2 | eth1 |
| 0.0.0.0/0 | 203.0.113.254 | eth2 |

**Question 4 — R2** : **une seule route non directe suffit** :

| Destination | Via | Interface |
|---|---|---|
| 192.168.2.0/24 | — (directe) | eth0 |
| 10.0.12.0/30 | — (directe) | eth1 |
| 0.0.0.0/0 | 10.0.12.1 | eth1 |

Tout ce que R2 ne connaît pas (LAN A **et** Internet) passe par le même voisin, R1 : la route par défaut couvre les deux. C'est le schéma « routeur feuille » — une seule sortie, une seule route.

### Partie 3 — Longest prefix match

**Question 5.**

- Paquet vers `10.0.12.2` : correspond à `10.0.0.0/8` **et** à `10.0.12.0/30` → le **/30 (directe)** gagne, le paquet part par eth1 directement.
- Paquet vers `10.99.3.7` : seul `10.0.0.0/8` correspond → via `203.0.113.254`.

Règle : à destinations multiples-correspondances, **le préfixe le plus long (le plus spécifique) gagne**, toujours. (Remarque à faire en débrief : router du 10/8 vers un FAI est artificiel — les plages privées ne sont pas routées sur Internet ; la question porte uniquement sur la sélection de route.)

**Question 6.** `192.168.2.0/24` (préfixe 24) bat `0.0.0.0/0` (préfixe 0) → le paquet part **via 192.168.1.254**. Même règle : longest prefix match. La route par défaut n'est utilisée **qu'en dernier recours**.

### Partie 4 — Question 7 : suivre le ping

| Tronçon | IP source | IP dest | MAC source | MAC dest |
|---|---|---|---|---|
| PC-A → R1 | 192.168.1.10 | 192.168.2.20 | MAC-PCA | MAC-R1-eth0 |
| R1 → R2 | 192.168.1.10 | 192.168.2.20 | MAC-R1-eth1 | MAC-R2-eth1 |
| R2 → PC-B | 192.168.1.10 | 192.168.2.20 | MAC-R2-eth0 | MAC-PCB |

Constat : **les IP ne changent jamais** (pas de NAT ici), **les MAC changent à chaque saut** — chaque routeur désencapsule la trame et en fabrique une nouvelle pour le tronçon suivant.

### Partie 5 — Diagnostics

**Question 8.** La passerelle `192.168.1.1` n'appartient pas au sous-réseau de PC-B (`192.168.2.0/24` : plage .1-.254 du 3e octet **2**). Calcul : 192.168.**1**.1 ET 255.255.255.0 = 192.168.1.0 ≠ 192.168.2.0. PC-B ne peut pas résoudre la MAC d'une adresse hors sous-réseau → l'ARP échoue.

Symptômes : PC-B **joint encore tout le LAN B** (192.168.2.x, trafic direct sans passerelle) mais **plus rien d'extérieur** (ni LAN A, ni Internet). C'est la panne de la question 11 de l'exercice 1-1, vue côté symptômes.

**Question 9.** Trajet de l'`echo reply` : PC-B l'envoie à sa passerelle R2 (destination 192.168.1.10, hors sous-réseau). **R2 consulte sa table : aucune route ne correspond à 192.168.1.0/24** (ni directe, ni statique, ni défaut) → R2 **jette le paquet** (et émet en principe un ICMP « network unreachable » vers PC-B).

Les reply meurent donc **sur R2**. La panne est trompeuse parce que :

- l'aller fonctionne parfaitement (PC-A et R1 ont leurs routes) — tcpdump sur PC-B « prouve » que « le réseau marche » ;
- le ping échoue pourtant côté PC-A, qui semble accuser sa propre config ;
- moralité : **le routage se vérifie toujours dans les deux sens** — un chemin aller n'implique jamais un chemin retour. (À reformuler vendredi : « les routes de peering s'ajoutent des deux côtés ».)

## Variantes acceptables

1. **R2 avec routes explicites** (`192.168.1.0/24 via 10.0.12.1` + `0.0.0.0/0 via 10.0.12.1`) au lieu de la seule route par défaut : fonctionnellement juste ; faire remarquer que la version minimale demandée était 1 ligne (élégance = moins de lignes à maintenir).
2. **Question 7 avec les vraies notations** `ip neigh`-style : accepter tout formalisme où IP constantes / MAC par tronçon sont corrects.

## Bonus

**Bonus 1.**

```bash
# Sur R1 :
sudo ip route add 192.168.2.0/24 via 10.0.12.2
# Sur R2 :
sudo ip route add default via 10.0.12.1
```

**Bonus 2.** Ajouts nécessaires :

- **R3** : `0.0.0.0/0 via 10.0.23.1` (routeur feuille, comme R2 avant lui) ;
- **R2** : `192.168.3.0/24 via 10.0.23.2` ;
- **R1** : `192.168.3.0/24 via 10.0.12.2` — **la ligne qu'on oublie** : sans elle, LAN A → LAN C meurt au retour… non, à l'aller sur R1 ; et LAN C → LAN A fonctionne via les défauts. On reproduit une asymétrie type question 9, côté R1 cette fois.

**Bonus 3.** Table R1 « façon VPC » :

| Destination | Cible |
|---|---|
| 192.168.1.0/24 | local |
| 192.168.2.0/24 | pcx-… (équivalent : route vers l'autre « VPC ») |
| 0.0.0.0/0 | igw-… |

La ligne `0.0.0.0/0 via 203.0.113.254` (eth2/FAI) joue le rôle de **`0.0.0.0/0 → igw-…`** : la sortie vers Internet.
