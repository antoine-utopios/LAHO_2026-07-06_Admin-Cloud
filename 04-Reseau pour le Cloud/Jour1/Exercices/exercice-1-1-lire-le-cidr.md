# Exercice 1-1 — Lire le CIDR : masques, plages et sous-réseaux

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 1)
> Durée estimée : 45 min (20 min seul + 10 min en binôme + correction croisée)
> Difficulté : 2 / 5
> Type : Exercice d'application — calculs à la main, calculatrice et convertisseurs interdits

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Convertir un masque décimal en notation CIDR et inversement, sans hésiter.
- Calculer le nombre d'adresses et d'hôtes utilisables d'un préfixe.
- Déterminer l'adresse réseau, l'adresse de broadcast et la plage utilisable de n'importe quelle adresse en notation CIDR.
- Dire si deux adresses appartiennent au même sous-réseau.
- Reconnaître les plages privées RFC 1918.

## Prérequis

- Avoir suivi la partie « Adressage IPv4 » du module 04 (jour 1, matin).
- Environnement : papier, crayon, et rien d'autre.
- Outils : la ligne des poids `128 64 32 16 8 4 2 1` recopiée en haut de votre brouillon, et le tableau des masques reconstruit de tête.

## Contexte

Vous êtes administrateur cloud junior. Ces questions sont celles que vous vous poserez des dizaines de fois par semaine : en lisant un `ip a`, en concevant un VPC, en déboguant un security group. L'objectif n'est pas seulement de trouver la bonne réponse : c'est de **poser la méthode** (octet intéressant → taille de bloc → multiple inférieur → suivant − 1) jusqu'à ce qu'elle devienne un réflexe. Posez chaque calcul par écrit, même quand la réponse vous semble évidente.

## Énoncé

### Partie 1 — Conversions masque ↔ CIDR

**Question 1.** Donnez la notation CIDR (`/n`) de chacun de ces masques :

a) `255.255.255.0`  b) `255.255.255.192`  c) `255.255.0.0`  d) `255.255.240.0`

**Question 2.** Donnez le masque décimal pointé de chacun de ces préfixes :

a) `/25`  b) `/27`  c) `/30`  d) `/22`

Résultat attendu : 8 conversions justes, sans passer par le binaire complet (utilisez la suite 128, 192, 224, 240, 248, 252, 254, 255).

### Partie 2 — Tailles de réseaux

**Question 3.** Pour chaque préfixe, donnez le nombre **total** d'adresses puis le nombre d'**hôtes utilisables** :

a) `/24`  b) `/27`  c) `/30`  d) `/16`

**Question 4.** Un `/29` : combien de bits d'hôte ? Combien d'hôtes utilisables ? Écrivez la formule utilisée.

Résultat attendu : la formule 2^(bits d'hôte) − 2 appliquée et justifiée à chaque fois.

### Partie 3 — Réseau, broadcast, plage

Pour chacune des adresses suivantes, donnez : l'**adresse réseau**, l'adresse de **broadcast**, la **première** et la **dernière** adresse utilisable. Posez les 4 étapes de la méthode à chaque fois.

**Question 5.** `192.168.10.77/26`

**Question 6.** `10.0.0.130/25`

**Question 7.** `172.16.50.10/20` (attention : la frontière n'est pas dans le 4e octet)

**Question 8.** `192.168.4.10/23`

**Question 9.** `10.20.135.90/21`

Résultat attendu : pour chaque question, un calcul posé en 4 lignes (octet intéressant, taille de bloc, réseau, broadcast) puis le tableau des 4 valeurs.

### Partie 4 — Même sous-réseau ?

**Question 10.** Les machines `10.0.5.200/22` et `10.0.4.10/22` sont-elles dans le même sous-réseau ? Démontrez-le en calculant l'adresse réseau de chacune.

**Question 11.** Une machine est configurée ainsi : adresse `10.0.0.130/25`, passerelle par défaut `10.0.0.1`. Cette configuration peut-elle fonctionner ? Justifiez par le calcul.

### Partie 5 — Privée ou publique ?

**Question 12.** Classez chacune de ces adresses : **privée (RFC 1918)**, **publique**, ou **spéciale** (précisez laquelle) :

a) `10.250.1.1`  b) `172.20.1.1`  c) `172.32.1.1`  d) `192.168.100.100`  e) `192.169.1.1`  f) `169.254.10.10`

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — la taille de bloc</summary>

Taille de bloc = 256 − (valeur du masque dans l'octet intéressant). Exemple : /26 → masque 192 dans le 4e octet → bloc de 64 → les sous-réseaux commencent à 0, 64, 128, 192. L'adresse réseau est le multiple du bloc **inférieur ou égal** à votre octet.

</details>

<details>
<summary>Indice 2 — quand la frontière n'est pas dans le 4e octet</summary>

Pour /17 à /24, l'octet intéressant est le **3e** : appliquez la même méthode sur le 3e octet, puis mettez le 4e octet à **0** pour l'adresse réseau et à **255** pour le broadcast. Exemple : /20 → masque 255.255.**240**.0 → bloc de 16 dans le 3e octet.

</details>

<details>
<summary>Indice 3 — les plages privées</summary>

10.0.0.0/8 (10.0.0.0 → 10.255.255.255) ; 172.16.0.0/12 (172.**16**.0.0 → 172.**31**.255.255 — pas au-delà !) ; 192.168.0.0/16 (192.**168** seulement). Et 169.254.0.0/16 n'est ni privée ni publique : c'est la plage link-local (APIPA).

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** `203.0.113.156/28` : adresse réseau, broadcast, plage utilisable ?

**Bonus 2.** Sans rien calculer d'autre que ce que vous savez déjà : combien y a-t-il de sous-réseaux `/26` dans un `/24` ? Dans un `/16` ?

**Bonus 3.** Vérifiez vos réponses des questions 5 et 9 en posant la conversion binaire complète du dernier octet concerné (une seule fois — pour vous convaincre que la méthode du bloc et le binaire disent la même chose).
