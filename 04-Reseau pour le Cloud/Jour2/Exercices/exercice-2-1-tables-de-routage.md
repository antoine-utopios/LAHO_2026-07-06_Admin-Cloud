# Exercice 2-1 — Compléter des tables de routage

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 2)
> Durée estimée : 45 min
> Difficulté : 3 / 5
> Type : Exercice d'application — sur papier

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Construire la table de routage de chaque équipement d'une topologie simple.
- Appliquer la règle du **préfixe le plus long** (longest prefix match) sur des cas ambigus.
- Suivre un paquet saut par saut en distinguant ce qui change (MAC) de ce qui ne change pas (IP).
- Diagnostiquer les deux pannes de routage les plus courantes : passerelle hors sous-réseau et route retour manquante.

## Prérequis

- Avoir suivi la partie « Routage » du module 04 (jour 2, matin).
- Environnement : papier, crayon.
- Outils : la méthode de calcul de sous-réseaux du jour 1 (elle sert dans presque chaque question).

## Contexte

L'entreprise fictive **MetalPro** relie deux sites par une liaison dédiée, et le site principal a l'accès Internet. Voici la topologie :

```text
   LAN A 192.168.1.0/24                LAN B 192.168.2.0/24
        |                                   |
   [PC-A .10]                          [PC-B .20]
        |                                   |
   +----+-----+     10.0.12.0/30      +-----+----+
   |    R1    +-----------------------+    R2    |
   | eth0 .1  | eth1 .1        eth1 .2| eth0 .1  |
   +----+-----+                       +----------+
        | eth2 : 203.0.113.10/24
        |
   [ FAI : passerelle 203.0.113.254 ] --- Internet
```

- R1 : `eth0` = 192.168.1.1/24, `eth1` = 10.0.12.1/30, `eth2` = 203.0.113.10/24.
- R2 : `eth0` = 192.168.2.1/24, `eth1` = 10.0.12.2/30.
- PC-A = 192.168.1.10/24, PC-B = 192.168.2.20/24.

## Énoncé

### Partie 1 — Vérifier la liaison

**Question 1.** Pour la liaison `10.0.12.0/30` : donnez l'adresse réseau, les adresses utilisables et le broadcast. Vérifiez que les adresses de R1 et R2 sont valides. Pourquoi un /30 est-il le choix classique pour une liaison entre deux routeurs ?

### Partie 2 — Construire les tables

Complétez chaque table au format `destination | via (passerelle) | interface`. Les réseaux directement connectés se notent `— (directe)`.

**Question 2.** La table de **PC-A** (2 lignes suffisent). Quelle est sa passerelle par défaut ?

**Question 3.** La table de **R1**, pour qu'il puisse joindre : ses réseaux directs, le LAN B, et Internet. (5 lignes.)

**Question 4.** La table de **R2**, la plus courte possible, pour qu'il joigne le LAN A **et** Internet. Combien de lignes non directes suffisent, et pourquoi une seule route peut-elle couvrir les deux besoins ?

### Partie 3 — Longest prefix match

**Question 5.** On ajoute sur R1 ces deux routes : `10.0.0.0/8 via 203.0.113.254` et la route directe `10.0.12.0/30`. Un paquet part vers `10.0.12.2` ; un autre vers `10.99.3.7`. Par où passe chacun, et pourquoi ?

**Question 6.** La table de PC-A contient `default via 192.168.1.1` et on y ajoute `192.168.2.0/24 via 192.168.1.254` (un second routeur hypothétique). Un paquet part vers `192.168.2.20`. Quelle route est choisie ? Quelle règle s'applique ?

### Partie 4 — Suivre un paquet

**Question 7.** PC-A envoie un ping à PC-B. Pour chacun des trois tronçons (PC-A→R1, R1→R2, R2→PC-B), donnez : IP source, IP destination, MAC source, MAC destination (notez les MAC symboliquement : `MAC-PCA`, `MAC-R1-eth0`, etc.). Que constatez-vous ?

### Partie 5 — Diagnostiquer

**Question 8.** PC-B est reconfiguré par erreur avec la passerelle `192.168.1.1`. Quels sont les symptômes exacts (que joint-il encore, que ne joint-il plus) ? Justifiez par le calcul du jour 1.

**Question 9.** R2 perd sa route vers le LAN A (et n'a pas de route par défaut). PC-A pingue PC-B : un `tcpdump` sur PC-B montre les `echo request` qui **arrivent**, mais PC-A n'obtient aucune réponse. Expliquez précisément où meurent les `echo reply`, et pourquoi ce type de panne (« ça passe à l'aller, pas au retour ») est si trompeur.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — construire une table sans rien oublier</summary>

Listez d'abord les réseaux **directement connectés** (un par interface). Puis demandez-vous : « quels réseaux existent dans la topologie que je ne connais pas encore ? » — chacun exige une route (ou d'être couvert par la route par défaut).

</details>

<details>
<summary>Indice 2 — question 4</summary>

Pour R2, tout ce qui n'est pas local (LAN A **et** Internet) est joignable par le même voisin : 10.0.12.1. Une route `0.0.0.0/0 via 10.0.12.1` couvre donc tout.

</details>

<details>
<summary>Indice 3 — question 9</summary>

Le routage se décide **indépendamment dans chaque sens**. L'aller utilise les tables de PC-A et R1 ; le retour utilise celles de PC-B et **R2**. Suivez l'echo reply pas à pas : PC-B → R2 → … et regardez ce que R2 sait faire de `192.168.1.10`.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Écrivez les commandes `ip route add` qui créeraient sur R1 (Linux) la route vers le LAN B, et sur R2 la route par défaut.

**Bonus 2.** L'entreprise ajoute un LAN C `192.168.3.0/24` derrière un routeur R3 connecté à R2 par la liaison `10.0.23.0/30` (R2 = .1, R3 = .2). Mettez à jour les tables de R1, R2 et R3 pour que tout le monde joigne tout le monde. Quel problème de la question 9 risque-t-on de reproduire ?

**Bonus 3.** Traduisez la table de R1 en « table de routage VPC » AWS (destinations + cibles symboliques `local` / `igw-…` / `pcx-…`) : quelle ligne joue le rôle de `eth2` vers le FAI ?
