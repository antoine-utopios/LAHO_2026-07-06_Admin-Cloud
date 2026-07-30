# Exercice 1-2 — Découper des réseaux : sous-réseaux, dimensionnement et VLSM

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 1)
> Durée estimée : 60 min (30 min seul + 15 min en binôme + correction croisée)
> Difficulté : 3 / 5
> Type : Exercice d'application — calculs à la main, calculatrice et convertisseurs interdits

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Découper un réseau en N sous-réseaux égaux et les lister exhaustivement.
- Choisir le préfixe adapté à un besoin en nombre d'hôtes (dimensionnement).
- Réaliser un découpage **VLSM** (sous-réseaux de tailles différentes) sans chevauchement ni gaspillage.
- Agréger deux réseaux contigus en un préfixe résumé (supernetting).
- Détecter les pièges classiques : broadcast déguisé en hôte, passerelle hors sous-réseau.

## Prérequis

- Avoir terminé l'exercice 1-1 (la méthode des 4 étapes doit être posée sans hésitation).
- Environnement : papier, crayon.
- Outils : le tableau des masques (/25 → /30 : blocs 128, 64, 32, 16, 8, 4) reconstruit de tête en haut du brouillon.

## Contexte

Vous préparez le plan d'adressage d'une petite entreprise — c'est le brouillon direct de ce que vous ferez vendredi pour un VPC, et au TP2 pour de vrai. Un découpage se pose toujours de la même façon : du plus grand besoin au plus petit, chaque sous-réseau commençant là où le précédent s'arrête, sur une frontière valide. Toute réponse doit montrer le calcul posé.

## Énoncé

### Partie 1 — Découpages en sous-réseaux égaux

**Question 1.** Découpez `192.168.1.0/24` en **4** sous-réseaux égaux. Donnez le nouveau préfixe, puis pour chaque sous-réseau : adresse réseau, plage utilisable, broadcast, nombre d'hôtes.

**Question 2.** Découpez `192.168.1.0/24` en **8** sous-réseaux égaux. Donnez le préfixe et la liste des 8 adresses réseau. Combien d'hôtes chacun ?

**Question 3.** Découpez `10.10.0.0/16` en **8** sous-réseaux égaux. Donnez le préfixe et la liste des 8 adresses réseau.

Résultat attendu : nombre de bits empruntés justifié (2^b ≥ N), listes complètes.

### Partie 2 — Dimensionner

**Question 4.** Pour chaque besoin, donnez le préfixe **le plus petit possible** (celui qui gaspille le moins) et le nombre d'hôtes réellement disponibles :

a) 25 hôtes  b) 100 hôtes  c) 500 hôtes  d) 2 hôtes (liaison point à point)

**Question 5.** Combien de sous-réseaux `/28` tiennent dans un `/24` ? Combien de `/24` dans un `/16` ?

**Question 6.** Vous devez découper `172.16.0.0/22` en sous-réseaux d'**au moins 100 hôtes** chacun. Quel préfixe choisissez-vous ? Combien de sous-réseaux obtenez-vous ? Listez les **trois premiers** (réseau, plage, broadcast).

### Partie 3 — Appartenance et pièges

**Question 7.** Le réseau `10.20.128.0/18` contient-il l'adresse `10.20.131.200` ? Et l'adresse `10.20.100.9` ? Démontrez.

**Question 8.** Un collègue veut attribuer `172.16.31.255/20` à un serveur. Qu'en pensez-vous ? Démontrez.

**Question 9 (agrégation).** a) Les réseaux `10.1.4.0/24` et `10.1.5.0/24` peuvent-ils se résumer en un seul préfixe ? Lequel ? b) Même question pour `10.1.5.0/24` et `10.1.6.0/24`. Justifiez en binaire (3e octet).

**Question 10.** Une machine est configurée : adresse `192.168.50.100/27`, passerelle `192.168.50.94`. Elle ne joint aucun réseau extérieur. Diagnostiquez par le calcul.

### Partie 4 — VLSM : le découpage d'architecte

**Question 11.** Vous disposez de `192.168.100.0/24`. Créez le plan d'adressage pour :

- un sous-réseau « applications » de **60 hôtes** ;
- un sous-réseau « données » de **28 hôtes** ;
- un sous-réseau « administration » de **12 hôtes** ;
- une liaison point à point de **2 hôtes**.

Contraintes : aucun chevauchement, aucun trou inutile (chaque sous-réseau commence dès que possible après le précédent, en commençant par le plus grand), et indiquez la plage restée **libre** pour l'avenir.

Résultat attendu : un tableau `nom | CIDR | réseau | plage | broadcast | hôtes` et la plage libre.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — combien de bits emprunter ?</summary>

Pour N sous-réseaux égaux : cherchez b tel que 2^b ≥ N. 4 sous-réseaux → 2 bits ; 8 → 3 bits. Le nouveau préfixe = ancien + b. La taille de bloc donne alors directement la liste (0, bloc, 2×bloc, …).

</details>

<details>
<summary>Indice 2 — VLSM sans se tromper</summary>

Toujours du **plus grand au plus petit** besoin. Chaque sous-réseau doit commencer sur un **multiple de sa propre taille de bloc**. Si vous placez les grands d'abord en partant de 0, cette condition est automatiquement respectée.

</details>

<details>
<summary>Indice 3 — agrégation</summary>

Deux /24 se résument en un /23 seulement si leurs 3e octets ne diffèrent **que par le dernier bit** : le premier doit être pair, le second = premier + 1. Écrivez les 3e octets en binaire pour le voir.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Refaites la question 11 avec un besoin supplémentaire de **110 hôtes** (sous-réseau « invités »). Tout tient-il encore dans le /24 ? Sinon, que proposez-vous ?

**Bonus 2.** Un VPC AWS en `10.42.0.0/16` doit contenir 6 sous-réseaux `/24` (le schéma StockLine du J4 : 10.42.0.0, 10.42.1.0, 10.42.10.0, 10.42.11.0, 10.42.20.0, 10.42.21.0). Quelle proportion du /16 est utilisée ? Pourquoi ce « gâchis » est-il ici une bonne pratique ?

**Bonus 3.** Résumez `192.168.0.0/24`, `192.168.1.0/24`, `192.168.2.0/24` et `192.168.3.0/24` en un seul préfixe.
