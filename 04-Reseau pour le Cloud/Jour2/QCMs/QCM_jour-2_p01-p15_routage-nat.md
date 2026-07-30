# QCM — Jour 2, pages 1 à 15 : Routage et NAT

> **Niveau 1** (questions 1 à 8) : Comprendre les notions
> **Niveau 2** (questions 9 à 16) : Appliquer sur des cas simples
> **Niveau 3** (questions 17 à 25) : Retrouver les notions dans des situations cloud

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

**Question 1.** Quel est le rôle principal d'un routeur (router) ?

A) Transmettre des paquets d'un réseau vers un autre en consultant sa table de routage (routing table).

B) Connecter plusieurs machines entre elles sur un même réseau local — c'est le rôle d'un switch (commutateur).

C) Traduire des noms de domaine en adresses IP — c'est le rôle d'un serveur DNS.

D) Chiffrer les données qui transitent entre deux machines pour les protéger.

---

**Question 2.** Qu'est-ce qu'une table de routage (routing table) ?

A) La liste complète des noms de domaine que le routeur connaît et peut résoudre.

B) La liste de toutes les adresses MAC des machines du réseau local.

C) Un ensemble de règles qui associent des réseaux de destination à une interface de sortie ou à l'adresse du prochain routeur (next hop). Le routeur la consulte pour chaque paquet.

D) L'historique de tous les paquets ayant traversé le routeur depuis son dernier redémarrage.

---

**Question 3.** À quoi sert une passerelle par défaut (default gateway) ?

A) Elle attribue automatiquement des adresses IP à toutes les machines du réseau local.

B) C'est l'adresse du routeur vers lequel une machine envoie les paquets dont la destination ne figure pas dans sa propre table de routage. C'est la "porte de sortie" vers l'inconnu.

C) Elle convertit les adresses IPv4 en adresses IPv6 pour les réseaux modernes.

D) Elle bloque les paquets suspects avant qu'ils ne quittent le réseau local.

---

**Question 4.** Une machine A (192.168.1.10/24) veut contacter une machine B (192.168.1.20/24). Comment A décide-t-elle d'envoyer le paquet directement à B, sans passer par une passerelle ?

A) Elle envoie systématiquement tout le trafic à la passerelle par défaut — c'est la passerelle qui décide de la suite.

B) Elle diffuse un broadcast ARP pour demander à l'ensemble du réseau quel chemin emprunter.

C) Elle interroge le serveur DHCP du réseau pour obtenir l'adresse MAC de B.

D) Elle applique son masque de sous-réseau (subnet mask) /24 à l'adresse de B et constate que les deux machines sont dans le même sous-réseau 192.168.1.0/24. Le paquet est envoyé directement.

---

**Question 5.** Une machine A (192.168.1.10/24) veut contacter l'adresse publique 8.8.8.8 (un serveur DNS de Google). Que se passe-t-il ?

A) A applique son masque /24 à 8.8.8.8, constate que cette adresse n'appartient pas à son sous-réseau local, et envoie le paquet à sa passerelle par défaut en espérant qu'elle saura le router plus loin.

B) A envoie directement une requête ARP sur le réseau local en demandant "Qui possède l'adresse 8.8.8.8 ?".

C) A refuse d'envoyer le paquet, car 8.8.8.8 est une adresse privée réservée aux États-Unis.

D) A remplace automatiquement 8.8.8.8 par l'adresse de sa propre passerelle dans le paquet.

---

**Question 6.** Que signifie le sigle NAT (Network Address Translation) ?

A) C'est un protocole qui compresse les paquets pour réduire la bande passante consommée.

B) C'est un mécanisme de redondance : si un routeur tombe, un routeur NAT prend automatiquement sa place.

C) C'est un algorithme qui accélère la résolution des noms de domaine vers des adresses IP.

D) C'est une technique qui modifie l'adresse IP source ou destination dans l'en-tête des paquets. Elle permet notamment à des machines ayant une adresse privée d'accéder à Internet en passant par une adresse publique partagée.

---

**Question 7.** Pourquoi les adresses privées définies par la RFC 1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) ne sont-elles pas routables sur l'Internet public ?

A) Parce qu'elles sont codées sur 24 bits seulement, contre 32 bits pour les adresses publiques.

B) Par convention, tous les fournisseurs d'accès à Internet (FAI) configurent leurs routeurs pour rejeter ces plages. Des millions de réseaux privés dans le monde utilisent les mêmes adresses ; sans NAT, un paquet avec une adresse privée ne pourrait jamais retrouver le chemin du retour.

C) Parce que ces adresses utilisent une version différente du protocole TCP/IP, incompatible avec Internet.

D) Parce que ces adresses expirent toutes les 24 heures et doivent être renouvelées auprès d'un serveur.

---

**Question 8.** Quelle est la différence principale entre le routage statique (static routing) et le routage dynamique (dynamic routing) ?

A) Le routage statique ne fonctionne qu'en IPv4, le routage dynamique qu'en IPv6.

B) Le routage statique est systématiquement plus rapide que le routage dynamique, quelle que soit la topologie du réseau.

C) Le routage statique est saisi manuellement par l'administrateur et ne change jamais tout seul. Le routage dynamique utilise des protocoles comme OSPF ou BGP qui permettent aux routeurs d'échanger automatiquement leurs tables et de s'adapter aux pannes ou aux changements du réseau.

D) Le routage statique est réservé aux datacenters professionnels, le routage dynamique aux box Internet domestiques.

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

**Question 9.** Sous Linux, quelle commande ajoute une route pour que le réseau 192.168.2.0/24 soit joignable via le routeur 10.0.0.254 ?

A) `ping -R 192.168.2.0/24 via 10.0.0.254`

B) `ip route add 192.168.2.0/24 via 10.0.0.254`

C) `ifconfig eth0 route add 192.168.2.0/24 gateway 10.0.0.254`

D) `traceroute -g 10.0.0.254 192.168.2.0/24`

---

**Question 10.** Tu exécutes `ip route show` sur une machine Linux et tu lis la ligne suivante : `default via 10.0.0.1 dev eth0`. Que signifie-t-elle concrètement ?

A) L'adresse IP de la machine est 10.0.0.1 et elle écoute sur l'interface eth0.

B) L'interface eth0 est désactivée ; tout le trafic est redirigé vers 10.0.0.1.

C) La machine agit elle-même comme passerelle par défaut pour les autres machines du réseau.

D) Tout paquet dont la destination ne correspond à aucune autre route de la table sera envoyé au routeur 10.0.0.1 via l'interface eth0. C'est la route "fourre-tout".

---

**Question 11.** Un paquet part d'une machine A, traverse le routeur R1, puis le routeur R2, et arrive au serveur B. Qu'arrive-t-il aux adresses MAC source et destination à chaque saut ?

A) Les adresses MAC source et destination sont remplacées à chaque saut : la MAC source devient celle de l'interface de sortie du routeur qui émet, la MAC destination devient celle du prochain équipement. En revanche, les adresses IP source et destination restent inchangées — sauf si un NAT intervient.

B) Les adresses MAC source et destination sont définies une seule fois par la machine A et ne changent jamais jusqu'à l'arrivée chez B.

C) Les adresses IP source et destination sont remplacées à chaque saut, mais les adresses MAC restent identiques.

D) Les adresses MAC sont définitivement supprimées de la trame dès que celle-ci traverse le premier routeur.

---

**Question 12.** En réseau, que désigne le terme "masquerading" (ou masquerade) ?

A) Le chiffrement complet du trafic réseau sortant pour masquer les données aux interceptions.

B) Une règle DNAT qui permet de cacher un serveur web interne derrière un proxy inverse.

C) Une forme de SNAT (Source NAT) dynamique : plusieurs machines du réseau privé partagent une même adresse IP publique pour sortir sur Internet. Le routeur remplace l'adresse source privée de chaque paquet par la sienne, "masquant" toutes les machines derrière lui.

D) Un filtrage de contenu qui bloque l'accès à certains sites web pour les utilisateurs du réseau.

---

**Question 13.** Avec le PAT (Port Address Translation), des dizaines de machines partagent une seule adresse IP publique. Comment le routeur NAT différencie-t-il les flux pour renvoyer la bonne réponse à la bonne machine ?

A) Il lit le nom d'utilisateur présent dans l'en-tête HTTP de chaque paquet pour identifier l'émetteur.

B) Il attribue une adresse MAC virtuelle différente à chaque machine du réseau privé.

C) Il utilise le champ TOS (Type of Service) de l'en-tête IP pour identifier la machine d'origine.

D) Il utilise les ports source : chaque connexion sortante reçoit un numéro de port source unique. Le routeur conserve une table de correspondance "IP privée + port ↔ IP publique + port" et lit le port de destination des réponses pour retrouver la machine destinataire.

---

**Question 14.** Tu héberges un serveur web dans ton réseau privé, à l'adresse 10.0.1.50, port 443. Tu souhaites qu'il soit accessible depuis Internet via l'adresse IP publique 203.0.113.10. Quelle technique NAT dois-tu configurer sur le routeur ?

A) Une règle DNAT (Destination NAT), aussi appelée port forwarding (redirection de port) : toute requête entrante sur 203.0.113.10:443 voit son adresse IP de destination traduite en 10.0.1.50 et son port en 443.

B) Une règle SNAT (Source NAT) qui remplace la source de tous les paquets sortants par 203.0.113.10.

C) Une règle de masquerading standard, identique à celle d'une box Internet domestique.

D) Une règle de pare-feu qui ouvre uniquement le port 443 sur le routeur, sans traduction d'adresse.

---

**Question 15.** Tu exécutes `ip route add 192.168.2.0/24 via 10.0.0.254` sur une machine Linux. Que viens-tu de faire ?

A) Tu as changé l'adresse IP de la machine en 192.168.2.0, masque 255.255.255.0.

B) Tu as ajouté une route statique qui dit : "pour joindre n'importe quelle adresse du réseau 192.168.2.0/24, envoie le paquet au routeur 10.0.0.254".

C) Tu as activé le NAT sur l'interface eth0 pour le réseau 192.168.2.0/24.

D) Tu as bloqué tout le trafic sortant à destination du réseau 192.168.2.0/24.

---

**Question 16.** Tu exécutes la commande suivante sur un serveur Linux : `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`. Quel est l'effet produit ?

A) Le serveur bloque immédiatement tout le trafic sortant, jouant le rôle d'un pare-feu.

B) Le serveur se déclare comme routeur OSPF sur le réseau local.

C) Tout le trafic sortant par l'interface eth0 voit son adresse IP source remplacée par l'adresse IP de eth0. C'est le SNAT dynamique classique, utilisé par exemple pour transformer un serveur Linux en "box Internet".

D) Le serveur active le DNAT et devient capable de recevoir des connexions entrantes sur l'interface eth0.

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

**Question 17.** Dans un VPC (Virtual Private Cloud, réseau privé virtuel chez un fournisseur cloud comme AWS), tu as deux sous-réseaux (subnets) : subnet-A (10.0.1.0/24) et subnet-B (10.0.2.0/24). Un routeur les relie. Que dois-tu vérifier pour que les instances de subnet-A puissent communiquer avec celles de subnet-B ?

A) Vérifier que la table de routage de subnet-A contient une route vers 10.0.2.0/24 pointant vers le routeur, que celle de subnet-B contient la route inverse vers 10.0.1.0/24, et que le forwarding IP (ip_forward) est activé sur le routeur.

B) Activer le NAT entre les deux sous-réseaux, car deux plages d'adresses privées différentes ne peuvent pas communiquer directement.

C) Rien à vérifier : les deux sous-réseaux font partie du même /8 (10.0.0.0/8), donc ils se voient automatiquement sans aucune configuration.

D) Fusionner les deux sous-réseaux en un seul /23, car un routeur ne peut pas interconnecter deux sous-réseaux de tailles différentes.

---

**Question 18.** Dans AWS, tu déploies 10 instances EC2 dans un sous-réseau privé et tu les places derrière une NAT Gateway. Ces instances peuvent-elles recevoir une connexion initiée directement depuis Internet ?

A) Oui, une fois la NAT Gateway en place, les instances privées deviennent automatiquement joignables depuis l'extérieur.

B) Oui, mais uniquement sur le port 443 (HTTPS), à condition d'avoir un certificat SSL valide.

C) Oui, sur tous les ports, à condition que le Security Group de l'instance autorise le trafic entrant.

D) Non. La NAT Gateway ne fait que du SNAT : elle permet aux instances privées d'initier des connexions sortantes vers Internet (télécharger des mises à jour, appeler des API externes), mais elle ne laisse passer aucune connexion entrante initiée depuis l'extérieur.

---

**Question 19.** Dans la table de routage d'un sous-réseau public AWS, tu vois la route `0.0.0.0/0 → igw-xxxxxxxx`. Quel est le rôle de cette route ?

A) Elle bloque explicitement tout le trafic qui n'est pas destiné à une adresse interne au VPC.

B) Elle dirige tout le trafic dont la destination n'est pas dans le réseau local du VPC vers l'Internet Gateway (passerelle Internet). C'est cette route qui permet aux ressources ayant une IP publique d'accéder à Internet et d'être joignables depuis Internet — elle définit un sous-réseau comme "public".

C) Elle indique que le sous-réseau utilise une NAT Gateway, car `igw` est le préfixe standard des NAT Gateways AWS.

D) Elle marque le sous-réseau comme privé, car l'Internet Gateway ne sert qu'à filtrer les connexions entrantes.

---

**Question 20.** Une instance EC2 située dans un sous-réseau privé, derrière une NAT Gateway, lance la commande `curl https://api.externe.com`. La réponse du serveur distant revient. Comment la NAT Gateway sait-elle à quelle instance privée renvoyer cette réponse ?

A) Elle lit le corps de la réponse HTTP pour y extraire l'identifiant unique de l'instance émettrice.

B) Elle se base sur la valeur du champ TTL (Time To Live) du paquet IP de retour pour identifier l'instance.

C) Elle consulte sa table de correspondance NAT (NAT table) : au moment de l'établissement de la connexion sortante, elle a enregistré une entrée "IP privée X + port source Y ↔ IP publique + port source Z". La réponse revient sur le port Z, elle retrouve Y et X, et réachemine le paquet.

D) Chaque réponse contient automatiquement, dans un champ dédié de l'en-tête IP, l'adresse privée de l'instance destinataire.

---

**Question 21.** Tu gères un serveur web interne accessible à l'adresse privée 10.0.1.50 sur le port 80. Tu disposes d'une adresse IP publique 203.0.113.10 attribuée à ton routeur. Tu veux que des utilisateurs sur Internet puissent accéder à ce serveur. Quelle règle configurer sur le routeur ?

A) Une règle SNAT (Source NAT) qui traduit la source de toutes les requêtes entrantes en 10.0.1.50.

B) Du masquerading classique, comme sur une box Internet domestique.

C) Un Security Group qui ouvre le port 80 en entrée, sans autre modification réseau.

D) Une règle DNAT (Destination NAT) / port forwarding : toute requête arrivant sur 203.0.113.10:80 voit sa destination réécrite en 10.0.1.50:80.

---

**Question 22.** Dans AWS, ta NAT Gateway est déployée dans une seule zone de disponibilité (Availability Zone, AZ). Cette AZ subit une panne majeure. Quelle est la conséquence directe pour les instances des sous-réseaux privés qui dépendent de cette NAT Gateway ?

A) Elles perdent toute connectivité sortante vers Internet. Leurs appels d'API, leurs téléchargements de mises à jour et toute communication initiée vers l'extérieur échouent jusqu'à ce que l'AZ — ou la NAT Gateway — redevienne opérationnelle.

B) Le trafic est automatiquement redirigé vers une NAT Gateway saine située dans une autre AZ, sans interruption.

C) AWS leur attribue automatiquement des adresses IP publiques de secours pour maintenir la connectivité sortante.

D) AWS migre les instances EC2 affectées vers une autre zone de disponibilité, sans coupure.

---

**Question 23.** Dans la table de routage d'un sous-réseau AWS, tu vois la ligne `10.0.0.0/16 → local`. Un paquet arrive avec comme destination 10.0.5.12. Comment le routeur traite-t-il ce paquet ?

A) Il le transmet à l'Internet Gateway, car 10.0.5.12 n'est pas explicitement déclaré comme un sous-réseau distinct.

B) Il bloque le paquet, car toute adresse en 10.x.x.x doit rester strictement interne et ne peut pas être routée.

C) Il reconnaît que 10.0.5.12 appartient au réseau local 10.0.0.0/16 directement connecté au VPC. Il délivre le paquet directement, sans passer par un autre routeur.

D) Il applique automatiquement un DNAT pour traduire 10.0.5.12 en une adresse IP publique.

---

**Question 24.** Une machine Linux possède la table de routage simplifiée suivante :

```
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.15
192.168.0.0/16 via 10.0.0.254 dev eth0
192.168.5.0/24 via 10.0.0.253 dev eth0
```

Un paquet doit être envoyé à l'adresse 192.168.5.20. Quel chemin va-t-il emprunter, et pourquoi ?

A) Il passera par la route par défaut `default via 10.0.0.1`, car c'est la route la plus générale et donc la plus sûre.

B) Il empruntera la route `192.168.5.0/24 via 10.0.0.253` car, parmi toutes les routes qui couvrent cette destination, c'est celle dont le préfixe est le plus long (/24 contre /16 contre /0). C'est la règle du longest prefix match (préfixe le plus long) : la route la plus spécifique l'emporte.

C) Il empruntera la route `192.168.0.0/16 via 10.0.0.254`, car cette route couvre également 192.168.5.20 et elle est listée en premier.

D) Le paquet sera rejeté, car plusieurs routes correspondent à la même destination et le système ne peut pas choisir.

---

**Question 25.** Dans une architecture cloud professionnelle, on sépare généralement les ressources en sous-réseaux publics et privés. Où place-t-on un serveur web et une base de données, et pourquoi ?

A) Les deux dans le même sous-réseau public pour simplifier l'administration réseau.

B) Les deux dans un sous-réseau privé, avec un VPN obligatoire pour tout accès, y compris celui des visiteurs du site web.

C) La base de données dans le sous-réseau public pour qu'elle soit accessible depuis partout, et le serveur web dans le sous-réseau privé par sécurité.

D) Le serveur web dans un sous-réseau public (ou derrière un Load Balancer public), afin d'être joignable depuis Internet. La base de données dans un sous-réseau privé, sans accès entrant direct depuis Internet. Seul le serveur web peut lui parler. La base de données peut éventuellement utiliser une NAT Gateway pour ses propres requêtes sortantes (mises à jour, appels d'API).
