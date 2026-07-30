# QCM — Jour 1, pages 14 à 39 : Ethernet, ARP, IPv4, CIDR, sous-réseaux et IPv6

> **Niveau 1** (questions 1 à 8) : Comprendre les notions
> **Niveau 2** (questions 9 à 16) : Appliquer sur des cas simples
> **Niveau 3** (questions 17 à 25) : Retrouver les notions dans des situations cloud

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

**Question 1.** Quel est le rôle d'une adresse MAC (Media Access Control) ?

A) Identifier une machine de façon unique sur Internet, comme le fait une adresse IP publique.

B) Identifier une carte réseau pour communiquer avec les autres machines du même réseau local.

C) Chiffrer les données avant leur envoi sur le câble Ethernet.

D) Remplacer l'adresse IP quand le réseau local est saturé.

---

**Question 2.** Une adresse IPv4 est composée de 32 bits. Comment s'écrit-elle pour être lisible par un humain ?

A) En huit groupes de quatre caractères hexadécimaux séparés par des deux-points.

B) En une série de 32 chiffres 0 et 1, sans séparateur.

C) En deux lettres suivies de six chiffres hexadécimaux, comme une adresse MAC.

D) En quatre nombres entre 0 et 255, séparés par des points.

---

**Question 3.** Une adresse IPv6 est codée sur combien de bits ?

A) 32 bits, comme l'IPv4.

B) 64 bits, deux fois plus que l'IPv4.

C) 128 bits, soit quatre fois plus que l'IPv4.

D) 256 bits, pour garantir un nombre d'adresses illimité.

---

**Question 4.** Le masque de sous-réseau (subnet mask) a un seul vrai rôle. Lequel ?

A) Séparer la partie réseau et la partie machine dans une adresse IP : les bits à 1 désignent le réseau, les bits à 0 désignent la machine.

B) Chiffrer l'adresse IP pour la rendre confidentielle sur le réseau.

C) Indiquer le débit maximum autorisé sur la connexion.

D) Définir le nombre maximal de routeurs (hops) que le paquet peut traverser.

---

**Question 5.** Laquelle de ces adresses est une adresse privée au sens de la RFC 1918 ?

A) 192.169.1.1

B) 172.20.8.15

C) 172.32.5.10

D) 8.8.8.8

---

**Question 6.** À quoi sert l'adresse `127.0.0.1` ?

A) C'est l'adresse que le serveur DHCP attribue par défaut au premier client du réseau.

B) C'est l'adresse du premier serveur DNS configuré sur la machine.

C) C'est une adresse multicast utilisée pour découvrir les imprimantes et services sur le réseau local.

D) C'est l'adresse de boucle locale (loopback) : elle désigne la machine elle-même. Un `ping 127.0.0.1` teste la pile réseau sans sortir sur le câble.

---

**Question 7.** Une machine connaît l'adresse IP de sa voisine mais pas son adresse MAC. Comment l'obtient-elle ?

A) Elle envoie une requête en broadcast à tout le réseau local via le protocole ARP (Address Resolution Protocol) : « Qui a cette IP ? »

B) Elle contacte un serveur DNS qui fait la correspondance IP → MAC.

C) Elle attend que la voisine diffuse spontanément son adresse MAC toutes les 30 secondes.

D) Elle teste chaque adresse MAC possible, une par une, jusqu'à trouver la bonne.

---

**Question 8.** Dans un sous-réseau, pourquoi soustrait-on toujours 2 au nombre total d'adresses pour connaître le nombre de machines connectables ?

A) Deux adresses sont réservées au switch et au routeur, qui ne sont pas des machines ordinaires.

B) Deux adresses sont obligatoirement attribuées au fournisseur cloud pour la gestion du VPC.

C) La première adresse identifie le réseau lui-même (tous les bits machine à 0) et la dernière sert au broadcast (tous les bits machine à 1). Aucune des deux ne peut être donnée à une machine.

D) Deux adresses sont gardées en réserve pour une extension future du sous-réseau.

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

**Question 9.** Le masque `255.255.255.192` correspond à quelle notation CIDR ?

A) /24

B) /26

C) /27

D) /25

---

**Question 10.** Quel nombre décimal correspond au binaire `11000000` ?

A) 192

B) 128

C) 224

D) 240

---

**Question 11.** Les valeurs 128, 192, 224, 240, 248, 252, 254 et 255 apparaissent souvent dans les masques de sous-réseau. Pourquoi ces valeurs, et uniquement celles-ci, sont-elles possibles dans un octet de masque ?

A) Ce sont les multiples de 8, car un octet contient 8 bits.

B) Ce sont les seules valeurs autorisées par les protocoles de routage modernes (BGP, OSPF).

C) Ce sont les valeurs héritées du système des classes A, B et C d'avant le CIDR.

D) Un masque est une suite contiguë de bits à 1 suivis de bits à 0. Dans un octet, les seules valeurs possibles sont donc `10000000` (128), `11000000` (192), `11100000` (224), `11110000` (240), `11111000` (248), `11111100` (252), `11111110` (254) et `11111111` (255).

---

**Question 12.** Avant l'invention du CIDR en 1993, le système des classes A, B et C imposait des tailles de réseau fixes. Quel était le problème principal ?

A) Les adresses de classe C ne pouvaient pas être routées au-delà du réseau local.

B) Les classes A et B ne supportaient que le protocole UDP, pas le protocole TCP.

C) Une entreprise ayant besoin de 1 000 adresses devait obligatoirement prendre une classe B (65 534 adresses), gaspillant plus de 60 000 adresses. Aucune taille intermédiaire n'existait.

D) Les adresses IP expiraient toutes les 24 heures et nécessitaient un renouvellement manuel.

---

**Question 13.** On te donne l'adresse `192.168.10.77/26`. Quelle est l'adresse réseau de ce sous-réseau ?

A) 192.168.10.0

B) 192.168.10.64

C) 192.168.10.77

D) 192.168.10.128

---

**Question 14.** Quelle est la règle universelle pour calculer la taille d'un bloc (nombre total d'adresses dans un sous-réseau) ?

A) Bloc = 32 − préfixe.

B) Bloc = préfixe × 8.

C) Bloc = nombre de bits machine × 2.

D) Bloc = 256 − valeur du masque dans l'octet où se trouve la coupure entre partie réseau et partie machine.

---

**Question 15.** Tu as besoin d'un sous-réseau pouvant accueillir 50 machines. Quel préfixe CIDR choisis-tu ?

A) /26

B) /28

C) /25

D) /27

---

**Question 16.** Un collègue allume une machine Linux et voit l'adresse `169.254.37.201` attribuée automatiquement. Qu'en déduis-tu ?

A) La machine a reçu une adresse publique temporaire du fournisseur d'accès.

B) La machine est correctement configurée avec une adresse statique de la plage privée 169.254.0.0/16.

C) La machine n'a pas trouvé de serveur DHCP. Elle s'est auto-attribué une adresse APIPA (Automatic Private IP Addressing). Elle peut communiquer sur le réseau local mais n'a probablement pas accès à Internet.

D) La carte réseau est défectueuse : cette adresse indique une erreur matérielle.

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

**Question 17.** Une machine a l'adresse `10.0.0.130/25` et la passerelle `10.0.0.1`. Tout le trafic extérieur est bloqué. Pourquoi ?

A) Le masque /25 n'est pas supporté dans les VPC cloud.

B) L'adresse 10.0.0.130 est une adresse de broadcast dans ce sous-réseau.

C) Le Security Group bloque par défaut le port 80 en sortie.

D) La passerelle `10.0.0.1` est dans le sous-réseau `10.0.0.0/25`, alors que la machine est dans `10.0.0.128/25`. Elles ne sont pas dans le même sous-réseau : la machine ne peut pas joindre sa passerelle, donc aucun paquet ne sort.

---

**Question 18.** Tu lances `tcpdump` sur une machine Linux pour inspecter le trafic. Que capture réellement cet outil au niveau de la carte réseau ?

A) Les trames Ethernet complètes : en-tête MAC, en-tête IP, en-tête TCP/UDP et données. Il les analyse ensuite couche par couche.

B) Uniquement les adresses IP source et destination, sans le contenu.

C) Uniquement les données utiles de la couche application (HTTP, DNS, SSH...).

D) Les segments TCP bruts, avant qu'ils ne soient encapsulés dans des paquets IP.

---

**Question 19.** Tu actives IPv6 sur ton VPC AWS. Chaque sous-réseau reçoit automatiquement un préfixe `/64`. Dois-tu calculer et découper manuellement les sous-réseaux comme en IPv4 ?

A) Oui, le calcul manuel est indispensable quelle que soit la taille du préfixe.

B) Oui, mais uniquement pour les sous-réseaux exposés sur Internet.

C) Non, le `/64` est la taille standardisée des sous-réseaux IPv6. AWS attribue automatiquement un `/64` à chaque sous-réseau, aucun calcul manuel de dimensionnement n'est nécessaire.

D) Non, car IPv6 n'utilise tout simplement pas de sous-réseaux.

---

**Question 20.** Ton VPC AWS utilise la plage privée `172.16.0.0/12`. Un collègue configure l'adresse `172.32.5.10` sur son serveur. Que lui réponds-tu ?

A) « Parfait, tout ce qui commence par 172 est une adresse privée. »

B) « Attention, la plage privée 172.16.0.0/12 s'étend de 172.16.0.0 à 172.31.255.255. L'adresse 172.32.5.10 dépasse cette plage : c'est une adresse publique, elle n'est pas utilisable dans le VPC. »

C) « AWS n'accepte que les adresses qui commencent par 10, il faut tout refaire. »

D) « Cette adresse est privée, mais il faut activer le routage inter-VPC pour qu'elle fonctionne. »

---

**Question 21.** Quelle est la forme abrégée correcte de l'adresse IPv6 `2001:0db8:0000:0000:0000:0000:0000:0001` ?

A) `2001:db8::1`

B) `2001:0db8::1`

C) `2001:db8::0001`

D) `2001:db8:0:0:0:0:0:1`

---

**Question 22.** Tu découpes le réseau `192.168.1.0/24` en 4 sous-réseaux de taille égale. Tu empruntes 2 bits : le préfixe passe de `/24` à `/26`. Quelle est l'adresse réseau du quatrième sous-réseau ?

A) 192.168.1.0/26

B) 192.168.1.64/26

C) 192.168.1.128/26

D) 192.168.1.192/26

---

**Question 23.** Tu crées un sous-réseau `10.0.1.0/24` dans AWS. Combien d'adresses IP ce sous-réseau contient-il au total, et combien de machines peux-tu y connecter **en théorie** (calcul réseau classique) ?

A) 24 adresses au total, 24 machines connectables.

B) 256 adresses au total, 254 machines connectables : la première adresse (10.0.1.0) identifie le réseau et la dernière (10.0.1.255) est le broadcast. Aucune des deux n'est attribuable.

C) 128 adresses au total, 126 machines connectables.

D) 256 adresses au total, 251 machines connectables car AWS réserve 3 adresses supplémentaires (passerelle VPC, DNS, adresse future).

---

**Question 24.** Tu actives IPv6 en dual-stack sur ton VPC AWS. Tu constates qu'il n'y a pas de NAT (Network Address Translation) en IPv6, contrairement à l'IPv4. Quelle conséquence cela a-t-il pour la sécurité ?

A) Aucune conséquence : le NAT ne servait qu'à économiser les adresses publiques, pas à protéger le réseau.

B) Les adresses IPv6 sont chiffrées de bout en bout par défaut, donc le NAT devient inutile.

C) Chaque machine peut recevoir une adresse IPv6 publique. Si le Security Group autorise un accès entrant, la machine est directement joignable depuis Internet. Le pare-feu (Security Group / NACL) devient la seule protection : il doit être configuré avec rigueur.

D) Il faut installer un antivirus sur chaque machine pour compenser l'absence de NAT.

---

**Question 25.** En IPv6, une adresse qui commence par `fe80` est une adresse :

A) Multicast, utilisée pour la diffusion de flux vidéo en streaming.

B) Publique, routable sur l'ensemble d'Internet.

C) Réservée aux serveurs DNS faisant autorité.

D) Link-local, valable uniquement sur le réseau local. Elle ne traverse jamais un routeur et chaque interface en génère une automatiquement.

