# Solution — Exercice 1-1 : Lire le CIDR : masques, plages et sous-réseaux

## Approche pédagogique

Cet exercice installe la méthode des 4 étapes (octet intéressant → taille de bloc → multiple inférieur ou égal → suivant − 1). Exiger le calcul **posé** à chaque question, même triviale : c'est la répétition du geste qui crée le réflexe. En correction croisée, faire poser les calculs au tableau par les apprenants, pas par le formateur.

## Solution détaillée

### Partie 1 — Conversions masque ↔ CIDR

**Question 1.**

| Masque | Décomposition | CIDR |
|---|---|---|
| 255.255.255.0 | 8+8+8 bits à 1 | **/24** |
| 255.255.255.192 | 8+8+8+2 (192 = 11000000) | **/26** |
| 255.255.0.0 | 8+8 | **/16** |
| 255.255.240.0 | 8+8+4 (240 = 11110000) | **/20** |

**Question 2.**

| CIDR | Calcul | Masque |
|---|---|---|
| /25 | 24+1 → 4e octet = 10000000 | **255.255.255.128** |
| /27 | 24+3 → 4e octet = 11100000 | **255.255.255.224** |
| /30 | 24+6 → 4e octet = 11111100 | **255.255.255.252** |
| /22 | 16+6 → 3e octet = 11111100 | **255.255.252.0** |

### Partie 2 — Tailles de réseaux

**Question 3.** Formule : total = 2^(32−n), hôtes = total − 2.

| Préfixe | Bits hôte | Total | Hôtes utilisables |
|---|---|---|---|
| /24 | 8 | 256 | **254** |
| /27 | 5 | 32 | **30** |
| /30 | 2 | 4 | **2** |
| /16 | 16 | 65 536 | **65 534** |

**Question 4.** /29 → 32 − 29 = **3 bits d'hôte** → 2³ − 2 = 8 − 2 = **6 hôtes**.

### Partie 3 — Réseau, broadcast, plage

Chaque calcul posé selon la méthode.

**Question 5 — 192.168.10.77/26**

```text
1. /26 = 24+2 -> 4e octet ; masque 255.255.255.192
2. bloc = 256 - 192 = 64        (sous-réseaux : 0, 64, 128, 192)
3. 77 : multiple de 64 <= 77 -> 64   => réseau  = 192.168.10.64
4. suivant = 128                     => broadcast = 192.168.10.127
```

| Réseau | 1re | Dernière | Broadcast |
|---|---|---|---|
| 192.168.10.64/26 | 192.168.10.65 | 192.168.10.126 | 192.168.10.127 |

**Question 6 — 10.0.0.130/25**

```text
1. /25 -> 4e octet ; masque 255.255.255.128
2. bloc = 256 - 128 = 128       (sous-réseaux : 0, 128)
3. 130 : multiple de 128 <= 130 -> 128   => réseau = 10.0.0.128
4. suivant = 256 (octet suivant)         => broadcast = 10.0.0.255
```

| Réseau | 1re | Dernière | Broadcast |
|---|---|---|---|
| 10.0.0.128/25 | 10.0.0.129 | 10.0.0.254 | 10.0.0.255 |

**Question 7 — 172.16.50.10/20**

```text
1. /20 = 16+4 -> 3e octet ; masque 255.255.240.0
2. bloc = 256 - 240 = 16        (0, 16, 32, 48, 64, ...)
3. 3e octet = 50 : multiple de 16 <= 50 -> 48  => réseau = 172.16.48.0
4. suivant = 64 => broadcast = 172.16.63.255   (4e octet à 255)
```

| Réseau | 1re | Dernière | Broadcast |
|---|---|---|---|
| 172.16.48.0/20 | 172.16.48.1 | 172.16.63.254 | 172.16.63.255 |

**Question 8 — 192.168.4.10/23**

```text
1. /23 = 16+7 -> 3e octet ; masque 255.255.254.0
2. bloc = 256 - 254 = 2         (0, 2, 4, 6, ...)
3. 3e octet = 4 : multiple de 2 <= 4 -> 4   => réseau = 192.168.4.0
4. suivant = 6 => broadcast = 192.168.5.255
```

| Réseau | 1re | Dernière | Broadcast |
|---|---|---|---|
| 192.168.4.0/23 | 192.168.4.1 | 192.168.5.254 | 192.168.5.255 |

**Question 9 — 10.20.135.90/21**

```text
1. /21 = 16+5 -> 3e octet ; masque 255.255.248.0
2. bloc = 256 - 248 = 8         (0, 8, ..., 128, 136, ...)
3. 3e octet = 135 : multiple de 8 <= 135 -> 128  => réseau = 10.20.128.0
4. suivant = 136 => broadcast = 10.20.135.255
```

| Réseau | 1re | Dernière | Broadcast |
|---|---|---|---|
| 10.20.128.0/21 | 10.20.128.1 | 10.20.135.254 | 10.20.135.255 |

### Partie 4 — Même sous-réseau ?

**Question 10.** /22 = 16+6 → 3e octet, masque 255.255.252.0, bloc = 256 − 252 = 4.

- `10.0.5.200` : 3e octet 5 → multiple de 4 ≤ 5 → 4 → réseau **10.0.4.0/22** ;
- `10.0.4.10` : 3e octet 4 → réseau **10.0.4.0/22**.

Même adresse réseau → **oui, même sous-réseau** (10.0.4.0 → 10.0.7.255).

**Question 11.** La machine est dans `10.0.0.128/25` (question 6). La passerelle `10.0.0.1` : multiple de 128 ≤ 1 → 0 → elle est dans `10.0.0.0/25`, **un autre sous-réseau**. La machine ne peut pas faire d'ARP vers une adresse hors de son sous-réseau : la passerelle est **injoignable**, la configuration **ne fonctionne pas** (aucun trafic hors sous-réseau ne sortira). Correctif : passerelle dans 10.0.0.129-254, ou adresse machine dans 10.0.0.0/25.

### Partie 5 — Privée ou publique ?

| Adresse | Verdict | Justification |
|---|---|---|
| a) 10.250.1.1 | **privée** | dans 10.0.0.0/8 |
| b) 172.20.1.1 | **privée** | 172.16.0.0/12 couvre 172.16 → 172.31 ; 20 ∈ [16-31] |
| c) 172.32.1.1 | **publique** | 32 > 31 : hors plage — le piège classique |
| d) 192.168.100.100 | **privée** | dans 192.168.0.0/16 |
| e) 192.169.1.1 | **publique** | 192.**169** ≠ 192.**168** |
| f) 169.254.10.10 | **spéciale** | link-local/APIPA (169.254.0.0/16) : ni privée routable, ni publique |

## Variantes acceptables

1. **Méthode binaire complète** : poser les 32 bits et faire le ET logique — juste mais lente ; valider le résultat, puis encourager la méthode du bloc pour la vitesse.
   - Avantage : démontre la compréhension profonde.
   - Inconvénient : impraticable en situation réelle (entretien, prod).
2. **Méthode « soustraction du modulo »** (réseau = octet − (octet mod bloc)) : équivalente, l'accepter telle quelle.

## Bonus

**Bonus 1 — 203.0.113.156/28** : /28 → 4e octet, masque 240, bloc = 16 (0, 16, …, 144, 160). 156 → multiple de 16 ≤ 156 → 144. Réseau **203.0.113.144**, broadcast **203.0.113.159**, plage **.145 → .158** (14 hôtes).

**Bonus 2** : /26 dans /24 : 2^(26−24) = **4**. /26 dans /16 : 2^(26−16) = **1024**.

**Bonus 3** :

```text
77  = 01001101 ; /26 garde 2 bits du 4e octet : 01|001101
     hôte à 0 : 01000000 = 64  ✔ (réseau .64)
135 = 10000111 ; /21 garde 5 bits du 3e octet : 10000|111
     hôte à 0 : 10000000 = 128 ✔ (réseau 10.20.128.0)
```
