# Exercice 4-1 — Plans d'adressage VPC : trois scénarios d'entreprise

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 4)
> Durée estimée : 50 min
> Difficulté : 4 / 5
> Type : Exercice de conception — sur papier, en binôme conseillé

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Choisir et justifier le CIDR d'un VPC en fonction du contexte (croissance, interconnexions présentes et futures).
- Découper un VPC en sous-réseaux multi-AZ cohérents (rôles, tailles, marge).
- Éviter les chevauchements avec un réseau on-premise existant ou entre VPC destinés au peering.
- Produire un livrable de plan d'adressage professionnel : tableau des sous-réseaux, routes, justifications.

## Prérequis

- Avoir suivi les parties « Anatomie d'un VPC » et « Interconnexion » du module 04 (jour 4).
- Environnement : papier, crayon — aucun accès cloud nécessaire.
- Outils : la méthode de calcul du jour 1 (chaque plage doit être posée et vérifiée) ; rappel : AWS réserve 5 adresses par sous-réseau.

## Contexte

Vous êtes consultant cloud. Trois clients vous confient la conception de leur plan d'adressage. Pour **chaque scénario**, le livrable est identique :

1. le CIDR du VPC (ou des VPC), **justifié en 2-3 lignes** ;
2. le tableau des sous-réseaux : `nom | AZ | CIDR | plage utilisable | adresses utilisables (AWS) | rôle` ;
3. les tables de routage principales (destination → cible symbolique : `local`, `igw-…`, `nat-…`, `pcx-…`, `vgw-…`) ;
4. les calculs posés pour au moins deux sous-réseaux (preuve de méthode).

## Énoncé

### Scénario 1 — VeloCity, PME e-commerce (le cas nominal)

VeloCity vend des vélos en ligne. Besoins :

- une application web 3-tiers : load balancer public, ~10 instances applicatives (jusqu'à 30 en pointe), une base managée avec réplica ;
- haute disponibilité sur **2 AZ** (eu-west-3a / eu-west-3b) ;
- les instances applicatives doivent télécharger leurs mises à jour ;
- aucun réseau on-premise, mais le CTO veut « ne jamais être bloqué dans 5 ans ».

Produisez le livrable complet. Question subsidiaire : où placez-vous la ou les NAT Gateway, et combien ?

### Scénario 2 — MetalPro, groupe industriel hybride (le piège du chevauchement)

MetalPro possède déjà un réseau on-premise très utilisé :

- datacenter principal : `10.0.0.0/16` (quasi plein) ;
- sites d'usine : `192.168.0.0/16` (découpé par usine) ;
- un **VPN site-à-site** reliera le datacenter au futur VPC dès le premier jour ;
- besoin cloud : ~200 serveurs répartis en 3 tiers, 2 AZ.

Produisez le livrable complet. Votre choix de CIDR doit être justifié **spécifiquement contre le risque de chevauchement**, y compris en cas d'extension future du réseau on-premise. Ajoutez à la table de routage privée les routes vers les deux réseaux on-premise.

### Scénario 3 — DataFab, plateforme multi-environnements (penser en portefeuille)

DataFab veut trois environnements strictement isolés mais interconnectables :

- **prod** : 3 tiers sur **3 AZ** (a, b, c) ;
- **staging** : 3 tiers sur 2 AZ ;
- **dev** : plus petit, 2 tiers (pas de tier data séparé) sur 2 AZ ;
- peering prévu : dev → staging et staging → prod (jamais dev → prod directement) ;
- un quatrième environnement (« data-lab ») arrivera l'an prochain.

Produisez : le plan des trois CIDR de VPC (+ la réserve pour data-lab), le tableau des sous-réseaux **du VPC prod uniquement** (les autres : CIDR seuls), et les routes de peering à ajouter de chaque côté pour staging ↔ prod. Question subsidiaire : un paquet de dev peut-il atteindre prod via staging ? Pourquoi ?

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — une convention de numérotation qui aide</summary>

Beaucoup d'équipes utilisent : `10.X.0.0/16` par VPC (X = numéro d'environnement), puis le 3e octet par rôle : 0-9 public, 10-19 applicatif, 20-29 data, et le chiffre des unités = l'AZ (0 = a, 1 = b, 2 = c). Ainsi `10.10.21.0/24` se lit d'un coup d'œil : prod, data, AZ-b.

</details>

<details>
<summary>Indice 2 — scénario 2</summary>

Il faut fuir `10.0.0.0/16` ET `192.168.0.0/16`. Deux familles de candidats : un autre bloc du 10/8 (ex. `10.50.0.0/16` — valide, mais risqué si l'on-premise s'étend dans 10/8), ou la plage `172.16.0.0/12`, presque toujours libre en entreprise. Justifiez votre arbitrage : c'est lui qui est noté.

</details>

<details>
<summary>Indice 3 — le peering n'est pas transitif</summary>

Un peering ne route que entre ses **deux** extrémités : les routes `pcx-…` n'existent que dans les tables des deux VPC concernés, et un VPC ne relaie jamais le trafic d'un peering vers un autre. La réponse à la question subsidiaire du scénario 3 en découle directement.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Scénario 1 : le marketing annonce l'ouverture d'un entrepôt connecté qui utilisera `10.0.0.0/16` en interne… et devra se relier au VPC dans 18 mois. Votre CIDR survit-il ? Si non, qu'auriez-vous dû choisir dès le départ ?

**Bonus 2.** Scénario 3 : remplacez les peerings par un **Transit Gateway** (hub central) : redessinez les routes en conséquence. Qu'est-ce qui devient possible entre dev et prod, et est-ce souhaitable ?

**Bonus 3.** Pour le scénario 2, calculez combien d'adresses utilisables (au sens AWS) offre chacun de vos sous-réseaux, et vérifiez que le tier applicatif tient les 200 serveurs avec 50 % de marge.
