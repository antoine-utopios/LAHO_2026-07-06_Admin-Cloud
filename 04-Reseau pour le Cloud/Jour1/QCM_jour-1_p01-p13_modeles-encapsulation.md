# QCM — Jour 1, pages 1 à 13 : Modèles OSI, TCP/IP, encapsulation et cloud

> **Niveau 1** (questions 1 à 8) : Comprendre les notions
> **Niveau 2** (questions 9 à 16) : Appliquer sur des cas simples
> **Niveau 3** (questions 17 à 25) : Retrouver les notions dans des situations cloud

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

**Question 1.** Dans le modèle OSI, quel est le rôle de la couche Physique (L1 — Physical layer) ?

A) Gérer les adresses MAC et former les trames (frames) avant envoi sur le réseau local

B) Transporter les bits sous forme de signaux électriques (cuivre), lumineux (fibre) ou radio (Wi-Fi)

C) Router les paquets entre différents réseaux grâce aux adresses IP

D) Assurer la fiabilité de la transmission de bout en bout entre deux machines

---

**Question 2.** Pourquoi a-t-on inventé le modèle en couches (layered model) ?

A) Chaque couche résout un problème précis et peut évoluer sans impacter les autres — c'est le principe de modularité

B) Pour permettre aux fournisseurs d'accès Internet de facturer chaque couche indépendamment

C) Pour imposer un constructeur unique d'équipements réseau dans le monde entier

D) Pour simplifier le calcul mathématique des masques de sous-réseau

---

**Question 3.** Combien de couches comporte le modèle TCP/IP ?

A) 7 couches, comme le modèle OSI

B) 5 couches, car il fusionne uniquement L1 et L2

C) 4 couches : Accès réseau (Network Access), Internet, Transport, Application

D) 3 couches : Physique, Réseau, Application

---

**Question 4.** Sur Internet et sur nos machines aujourd'hui, quel modèle est réellement implémenté ?

A) Le modèle OSI, car il est plus détaillé et plus rigoureux que le modèle TCP/IP

B) Aucun des deux : Internet utilise un modèle propriétaire appelé ISO

C) Les deux simultanément : OSI pour les couches 1 à 4, TCP/IP pour les couches 5 à 7

D) Le modèle TCP/IP, car il correspond aux protocoles réels (HTTP, TCP, IP, Ethernet). Le modèle OSI est un modèle théorique de référence

---

**Question 5.** Le moyen mnémotechnique « Pour Le Réseau, Tout Se Passe Ainsi » donne les 7 couches OSI de la couche 1 à la couche 7. La lettre « T » correspond à :

A) Transport — couche 4, qui achemine les données jusqu'à la bonne application grâce aux ports

B) Transmission — couche 2, qui transmet les trames sur le réseau local

C) Traitement — couche 5, qui gère le dialogue entre deux applications

D) Terminaison — couche 7, la dernière avant l'utilisateur

---

**Question 6.** Dans le mécanisme d'encapsulation (encapsulation), qu'ajoute la couche Transport (L4) aux données reçues de la couche supérieure ?

A) Les adresses IP source et destination

B) L'URL complète de la ressource demandée par le client

C) Les ports source et destination, pour identifier l'application destinataire (ex. port 443 = HTTPS, port 22 = SSH)

D) Les adresses MAC source et destination

---

**Question 7.** Dans l'encapsulation, à quel moment les adresses MAC sont-elles ajoutées aux données ?

A) Par la couche Application (L7), avant toute autre encapsulation

B) Par la couche Transport (L4), en même temps que les ports TCP

C) Par la couche Internet (L3), en même temps que les adresses IP

D) Par la couche Accès réseau (L2), qui enveloppe le paquet IP dans une trame (frame) avec les adresses MAC source et destination

---

**Question 8.** Quel est le nom correct de l'unité de données (PDU — Protocol Data Unit) produite par la couche Internet/Réseau (L3) ?

A) Un paquet (packet)

B) Une trame (frame)

C) Un segment (segment)

D) Un datagramme (datagram)

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

**Question 9.** Une application web ne répond plus. Tu suspectes un problème réseau. Dans quel ordre est-il le plus efficace de vérifier les couches OSI pour diagnostiquer la panne ?

A) L7 → L4 → L3 → L2 → L1 : du haut vers le bas, en commençant par l'application

B) L1 → L2 → L3 → L4 → L7 : du bas vers le haut (bottom-up). Si le câble est débranché (L1), inutile de chercher plus haut

C) L4 → L7 → L3 → L2 → L1 : un ordre arbitraire qui n'a pas d'importance

D) Peu importe l'ordre, du moment que toutes les couches sont testées une par une

---

**Question 10.** La couche Application (L7) gère des protocoles comme HTTP, DNS et SSH. A-t-elle besoin de savoir si le réseau sous-jacent utilise un câble Ethernet ou du Wi-Fi ?

A) Oui, car le Wi-Fi a une portée plus courte, ce qui oblige à réduire la taille des paquets HTTP

B) Non, car le système d'exploitation convertit automatiquement les requêtes selon le type de connexion détecté

C) Oui, car les adresses MAC sont différentes entre Ethernet et Wi-Fi, ce qui modifie les requêtes HTTP

D) Non, c'est le principe d'indépendance des couches : L7 utilise les services de L4 sans avoir besoin de connaître les détails de L1 ou L2

---

**Question 11.** Pendant l'encapsulation, que fait une couche lorsqu'elle reçoit des données de la couche supérieure, juste avant de les transmettre à la couche inférieure ?

A) Elle ajoute son propre en-tête (header) contenant les informations dont elle a besoin pour faire son travail — c'est le principe même de l'encapsulation

B) Elle compresse les données pour économiser de la bande passante réseau

C) Elle chiffre systématiquement les données pour des raisons de sécurité

D) Elle convertit les données en binaire avant de les transmettre à la couche suivante

---

**Question 12.** Un switch (commutateur) est décrit comme un équipement de couche 2. Cela signifie qu'il prend ses décisions de transfert en se basant sur :

A) Les adresses IP source et destination contenues dans les paquets

B) Le contenu HTTP des requêtes qui traversent le switch

C) Les numéros de port TCP, pour diriger le trafic vers la bonne application

D) Les adresses MAC (Media Access Control) uniquement — il ne lit jamais l'adresse IP contenue dans le paquet

---

**Question 13.** Un paquet IP traverse deux routeurs pour atteindre sa destination. Que deviennent les adresses IP et MAC durant ce trajet ?

A) Les deux — IP et MAC — changent à chaque routeur traversé

B) Les adresses IP changent à chaque routeur, mais les adresses MAC restent fixes de bout en bout

C) Les adresses IP restent fixes (elles identifient l'expéditeur et le destinataire final), mais les adresses MAC changent à chaque saut car elles ne sont valables que sur le réseau local traversé

D) Les adresses IP et MAC restent identiques de bout en bout

---

**Question 14.** Tu configures un Security Group AWS avec la règle suivante : « Autoriser le port 443 depuis 0.0.0.0/0 ». Sur quelles couches OSI ce Security Group filtre-t-il ?

A) Couches 2 et 3 : adresse MAC et adresse IP

B) Couche 7 uniquement, car il lit le contenu des requêtes HTTPS

C) Couche 4 uniquement, car il travaille sur le port TCP

D) Couches 3 et 4 : il filtre sur l'adresse IP source (L3) et le port (L4), sans jamais lire le contenu des données (L7)

---

**Question 15.** On dit souvent que « le cloud, c'est du réseau défini par logiciel » (software-defined networking). Que signifie cette expression ?

A) Le cloud supprime tous les concepts réseau et les remplace par de l'intelligence artificielle

B) Les câbles, switchs et routeurs physiques disparaissent, mais les concepts réseau (adressage, routage, pare-feu) restent les mêmes — tout est configuré via des interfaces ou du code

C) Le cloud utilise des protocoles réseau incompatibles avec ceux des datacenters physiques

D) Dans le cloud, le réseau est entièrement automatique et ne nécessite aucune intervention humaine

---

**Question 16.** Les couches Session (L5) et Présentation (L6) du modèle OSI sont rarement mentionnées par les administrateurs cloud. Pourquoi ?

A) Dans le modèle TCP/IP utilisé en pratique, ces deux couches sont fusionnées avec la couche Application — elles n'existent pas en tant que couches séparées

B) Elles ont été conçues uniquement pour les réseaux téléphoniques et ne concernent pas les réseaux informatiques

C) Elles sont automatiquement gérées par le matériel réseau et l'administrateur n'y a jamais accès

D) Elles ont été supprimées dans la version IPv6 du protocole Internet

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

**Question 17.** Dans la console AWS, un sous-réseau (subnet) est marqué « public ». Qu'est-ce que cela signifie concrètement ?

A) Toutes les instances EC2 de ce sous-réseau reçoivent automatiquement une adresse IP publique

B) La table de routage (route table) du sous-réseau possède une route par défaut `0.0.0.0/0` qui pointe vers une Internet Gateway — les instances avec une IP publique sont joignables depuis Internet

C) Ce sous-réseau utilise exclusivement des adresses IPv6

D) Aucun Security Group n'est nécessaire sur ce sous-réseau

---

**Question 18.** Tu actives le HTTPS sur un Application Load Balancer (ALB) AWS en attachant un certificat TLS. Dans le modèle TCP/IP, à quelle couche le chiffrement TLS est-il rattaché ?

A) Couche Transport — car TLS se place techniquement au-dessus de TCP

B) Couche Internet — car il chiffre les paquets IP

C) Couche Accès réseau — car le chiffrement s'effectue avant l'envoi sur le support physique

D) Couche Application — bien que situé entre L4 et L7, TLS est géré par des bibliothèques logicielles intégrées aux applications et aux ALB (qui sont des équipements L7)

---

**Question 19.** Dans AWS, qu'est-ce qui détermine fondamentalement si un sous-réseau est public ou privé ?

A) Le type d'adresses IP utilisées dans le sous-réseau (publiques ou privées)

B) Le nombre d'instances EC2 hébergées dans le sous-réseau

C) La table de routage associée au sous-réseau : si elle contient une route `0.0.0.0/0` vers une Internet Gateway, le sous-réseau est public ; sinon, il est privé

D) La présence ou l'absence d'un Security Group attaché au sous-réseau

---

**Question 20.** Tu crées un VPC AWS avec la plage d'adresses `10.0.0.0/16`. Pourquoi utilise-t-on une plage qui commence par `10.x.x.x` plutôt qu'une plage d'adresses publiques ?

A) AWS impose la plage `10.0.0.0/16` pour tous les VPC sans exception

B) Les plages publiques ne permettent pas de découper des sous-réseaux, contrairement aux plages privées

C) Les adresses en `10.x.x.x` sont traitées en priorité par les routeurs AWS, ce qui améliore les performances réseau

D) Les adresses `10.x.x.x` sont des adresses privées (RFC 1918) — elles ne sont jamais routées sur Internet. On peut donc les réutiliser dans chaque VPC, sans conflit avec le monde extérieur

---

**Question 21.** Dans un VPC AWS, le bloc CIDR `10.0.0.0/16` est choisi. Que signifie concrètement le `/16` ?

A) Le VPC est limité à 16 machines virtuelles au total

B) Les 16 premiers bits (`10.0`) identifient le réseau ; les 16 bits restants servent pour les machines et les sous-réseaux — soit 2^16 = 65 536 adresses disponibles dans le VPC

C) Le VPC peut contenir exactement 16 sous-réseaux, ni plus ni moins

D) Le `/16` bloque définitivement le masque de sous-réseau à `255.255.0.0` : il est impossible de créer des sous-réseaux plus petits qu'un `/16`

---

**Question 22.** Dans la suite de ta formation, quand utiliseras-tu concrètement les notions de couches OSI et TCP/IP dans les modules AWS ?

A) Jamais : ces notions servent uniquement à réussir le QCM de la première semaine de cours

B) Uniquement pour les modules Linux et scripting, pas pour les services AWS eux-mêmes

C) Pour comprendre ce que signifient « L4 » ou « L7 » dans la configuration d'un Load Balancer ou d'un Security Group — les couches OSI sont le vocabulaire commun de tous les services cloud

D) Pour calculer le coût mensuel des services AWS en fonction de leur couche réseau d'appartenance

---

**Question 23.** Laquelle de ces situations illustre le mieux pourquoi la compréhension du réseau est une compétence qui différencie un bon administrateur cloud d'un débutant ?

A) Réussir un QCM de 25 questions sur les modèles OSI et TCP/IP

B) Savoir choisir une plage d'adresses, la découper en sous-réseaux adaptés à l'application, et expliquer pourquoi ces choix sont pertinents — plutôt que de copier un exemple trouvé en ligne sans le comprendre

C) Connaître par cœur les 7 couches du modèle OSI dans l'ordre, de la couche 1 à la couche 7

D) Savoir configurer un réseau Wi-Fi domestique sans assistance

---

**Question 24.** Un collègue te dit : « Ce Load Balancer travaille en couche 7. » Concrètement, quel avantage cela apporte-t-il par rapport à un Load Balancer couche 4 ?

A) Il peut lire le chemin de l'URL dans la requête HTTP et router `/images` vers un groupe de serveurs et `/api` vers un autre groupe — c'est le routage basé sur le contenu (content-based routing)

B) Il supporte un plus grand nombre de connexions simultanées, car la couche 7 est la plus rapide du modèle

C) Il remplace complètement le Security Group : plus besoin de configurer des règles de pare-feu

D) Il fonctionne sans adresse IP, car la couche 7 utilise directement les noms de domaine (DNS)

---

**Question 25.** Tu déploies une application web dans AWS avec l'architecture suivante : un VPC, deux sous-réseaux publics, deux sous-réseaux privés, un Application Load Balancer placé dans les sous-réseaux publics, et les serveurs applicatifs placés dans les sous-réseaux privés. Pourquoi les serveurs applicatifs sont-ils placés dans des sous-réseaux privés ?

A) Parce que les sous-réseaux privés offrent de meilleures performances réseau que les sous-réseaux publics

B) Parce que les sous-réseaux privés sont gratuits, contrairement aux sous-réseaux publics qui sont facturés par AWS

C) Parce qu'ils n'ont pas besoin d'être joignables directement depuis Internet — seul le Load Balancer, exposé dans le sous-réseau public, reçoit les requêtes entrantes et les transmet aux serveurs en privé

D) Parce que les sous-réseaux privés activent automatiquement un chiffrement des données entre toutes les instances
