# Exercice 2-2 — Diagnostiquer avec dig : cinq tickets DNS

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 2)
> Durée estimée : 45 min
> Difficulté : 3 / 5
> Type : Exercice d'application — manipulations sur la VM + diagnostic sur dossier

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Interroger les différents types d'enregistrements avec `dig` et lire chaque section d'une réponse.
- Mettre en évidence le cache DNS par l'observation du TTL.
- Diagnostiquer, à partir d'une sortie `dig`, les pannes DNS les plus courantes : nom inexistant, cache non expiré, alias cassé, résolveur en échec, délégation incohérente.
- Rédiger un diagnostic au format professionnel : symptôme → hypothèse → preuve → correctif.

## Prérequis

- Avoir suivi la partie « DNS en profondeur » du module 04 (jour 2) et la démo 2-1.
- Environnement : VM Ubuntu avec accès Internet pour la partie 1 ; papier ou éditeur pour la partie 2.
- Outils : `dig` (`sudo apt install -y bind9-dnsutils`), `resolvectl`.

## Contexte

Partie 1 : vous vérifiez vos réflexes `dig` sur des domaines réels. Partie 2 : vous êtes d'astreinte chez **StockLine Corp** (domaine fictif `stockline-corp.example`) ; cinq tickets arrivent avec des sorties `dig` capturées par les équipes. Les adresses utilisent les plages de documentation (`203.0.113.0/24`, `198.51.100.0/24`) : ne cherchez pas à les joindre, tout le diagnostic se fait **sur pièces**.

## Énoncé

### Partie 1 — Manipulations réelles (15 min)

Sur la VM, exécutez et notez pour chaque commande : le **statut**, le contenu de l'**ANSWER SECTION** et **qui a répondu** (ligne `SERVER:`).

**Question 1.** `resolvectl status` — identifiez votre résolveur local et le résolveur amont.

**Question 2.** `dig wikipedia.org` puis, 15 secondes plus tard, `dig wikipedia.org` à nouveau. Comparez les TTL et les `Query time`. Qu'en concluez-vous ?

**Question 3.** `dig www.wikipedia.org` — identifiez la chaîne CNAME → A dans la réponse.

**Question 4.** `dig wikipedia.org MX +short` et `dig wikipedia.org NS +short` — que signifie le nombre devant chaque MX ?

**Question 5.** `dig @1.1.1.1 wikipedia.org +short` et `dig @8.8.8.8 wikipedia.org +short` — les réponses peuvent-elles légitimement différer ? Pourquoi ?

### Partie 2 — Cinq tickets à diagnostiquer (30 min)

Pour **chaque** ticket, rédigez 3 à 5 lignes : (1) ce que dit la sortie, (2) la cause la plus probable, (3) l'action corrective, (4) comment vérifier que c'est réparé.

**Ticket A** — « Le site est mort ! » :

```text
$ dig wwww.stockline-corp.example

;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 41372
;; QUESTION SECTION:
;wwww.stockline-corp.example.        IN      A
;; AUTHORITY SECTION:
stockline-corp.example.  300  IN  SOA  ns1.stockline-corp.example. admin.stockline-corp.example. ...
;; SERVER: 127.0.0.53#53(127.0.0.53)
```

**Ticket B** — « On a migré le site hier soir vers 203.0.113.80, mais la moitié des clients voient encore l'ancien serveur » :

```text
$ dig www.stockline-corp.example

;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8250
;; ANSWER SECTION:
www.stockline-corp.example.  81523  IN  A  198.51.100.14
;; SERVER: 127.0.0.53#53(127.0.0.53)

$ dig @ns1.stockline-corp.example www.stockline-corp.example

;; ->>HEADER<<- opcode: QUERY, status: NOERROR, flags: qr aa rd
;; ANSWER SECTION:
www.stockline-corp.example.  86400  IN  A  203.0.113.80
```

**Ticket C** — « La boutique renvoie une erreur de résolution, pourtant le nom existe » :

```text
$ dig boutique.stockline-corp.example

;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 5531
;; ANSWER SECTION:
boutique.stockline-corp.example.  300  IN  CNAME  shop.ancien-hebergeur.example.
;; AUTHORITY SECTION:
ancien-hebergeur.example.  600  IN  SOA  ns1.ancien-hebergeur.example. ...
```

**Ticket D** — « Plus aucun site ne répond depuis le poste de Léa, mais tout marche depuis le serveur de build » :

```text
lea$ dig stockline-corp.example
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 61023
;; SERVER: 10.3.3.53#53(10.3.3.53)

build$ dig stockline-corp.example
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1187
;; ANSWER SECTION:
stockline-corp.example.  300  IN  A  203.0.113.10
;; SERVER: 10.3.3.10#53(10.3.3.10)
```

**Ticket E** — « On a changé de prestataire DNS la semaine dernière ; depuis, les changements de zone ne sont visibles qu'une fois sur deux » :

```text
$ dig stockline-corp.example NS +short
ns1.ancien-presta.example.
ns2.nouveau-presta.example.

$ dig @ns1.ancien-presta.example www.stockline-corp.example +short
198.51.100.14
$ dig @ns2.nouveau-presta.example www.stockline-corp.example +short
203.0.113.80
```

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — lire le statut d'abord</summary>

`NXDOMAIN` = « ce nom n'existe pas » (regardez alors le nom **exactement** demandé, lettre par lettre — et dans le ticket C, regardez sur quel nom porte le NXDOMAIN : celui demandé, ou la **cible** du CNAME ?). `SERVFAIL` = « le résolveur n'a pas réussi » : le problème est côté résolveur ou délégation, pas forcément côté zone.

</details>

<details>
<summary>Indice 2 — ticket B</summary>

Comparez les deux TTL : 81523 (en train de décompter) contre 86400 (valeur nominale chez l'autoritaire, flag `aa`). Qui répond quoi ? Combien de temps le problème va-t-il durer ? Qu'aurait-il fallu faire *avant* la migration ?

</details>

<details>
<summary>Indice 3 — tickets D et E</summary>

D : les deux machines n'interrogent pas le même serveur (ligne `SERVER:`). E : deux serveurs déclarés NS de la zone répondent des choses **différentes** — un résolveur peut interroger l'un ou l'autre au hasard. Que faut-il corriger : la zone, ou la délégation ?

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Pour le ticket B : écrivez le plan de migration DNS complet (avec chronologie) qui aurait évité le problème.

**Bonus 2.** Sur la VM : `dig +trace wikipedia.org` — identifiez dans la sortie les trois délégations successives (racine → TLD → autoritaire) et surlignez les enregistrements NS qui les matérialisent.

**Bonus 3.** `dig -x 8.8.8.8 +short` : qu'est-ce qu'une résolution inverse et quel type d'enregistrement est utilisé ?
