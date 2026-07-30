# Corrigé détaillé — QCM Jour 2, pages 1 à 15 : Routage et NAT

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

**Question 1.** Quel est le rôle principal d'un routeur (router) ?

**Réponse : A** — Transmettre des paquets d'un réseau vers un autre en consultant sa table de routage.

> ❌ B — Connecter des machines sur un même réseau local est le rôle d'un switch (commutateur), qui travaille au niveau 2 avec les adresses MAC.
> ❌ C — Traduire des noms de domaine en adresses IP est la mission d'un serveur DNS, pas d'un routeur.
> ❌ D — Chiffrer les données relève de protocoles comme TLS ou IPsec ; le routeur route, il ne chiffre pas par défaut.
> 💡 **À retenir** : Un routeur est un équipement de niveau 3 (couche réseau du modèle OSI). Il lit l'adresse IP de destination, consulte sa table de routage, et décide vers quelle interface ou quel prochain routeur transmettre le paquet.

---

**Question 2.** Qu'est-ce qu'une table de routage (routing table) ?

**Réponse : C** — Un ensemble de règles qui associent des réseaux de destination à une interface de sortie ou à l'adresse du prochain routeur (next hop).

> ❌ A — La table de routage manipule des adresses IP, pas des noms de domaine. La résolution DNS est un service distinct.
> ❌ B — Les adresses MAC sont stockées dans la table ARP de la machine (ou la table CAM d'un switch), pas dans la table de routage.
> ❌ D — La table de routage n'est pas un historique ; elle contient des règles actives. Le volume de trafic rendrait un historique impossible à stocker.
> 💡 **À retenir** : Chaque ligne d'une table de routage dit : "pour atteindre le réseau X, passe par l'interface Y ou envoie au routeur Z". C'est une carte simplifiée que le routeur consulte en permanence.

---

**Question 3.** À quoi sert une passerelle par défaut (default gateway) ?

**Réponse : B** — C'est l'adresse du routeur vers lequel une machine envoie les paquets dont la destination ne figure pas dans sa propre table de routage.

> ❌ A — L'attribution automatique d'adresses IP est le rôle d'un serveur DHCP, pas de la passerelle par défaut.
> ❌ C — La conversion IPv4/IPv6 nécessite des mécanismes dédiés comme NAT64 ; la passerelle par défaut ne fait pas cette conversion.
> ❌ D — Bloquer des paquets suspects est le rôle d'un pare-feu (firewall), pas de la passerelle par défaut.
> 💡 **À retenir** : La passerelle par défaut est la "porte de sortie" d'une machine. Quand la destination d'un paquet est inconnue (hors du réseau local), la machine l'envoie à cette adresse en espérant que le routeur saura le router plus loin.

---

**Question 4.** Une machine A (192.168.1.10/24) veut contacter une machine B (192.168.1.20/24). Comment A décide-t-elle d'envoyer le paquet directement à B, sans passer par une passerelle ?

**Réponse : D** — Elle applique son masque de sous-réseau (subnet mask) /24 à l'adresse de B et constate qu'elles sont dans le même sous-réseau 192.168.1.0/24.

> ❌ A — Une machine ne transmet pas systématiquement tout à la passerelle. Elle commence par vérifier si la destination est dans son propre sous-réseau.
> ❌ B — Le broadcast ARP sert à résoudre une IP en adresse MAC une fois la décision de routage prise, pas à décider du chemin.
> ❌ C — Le serveur DHCP attribue des adresses IP au démarrage ; il ne fournit pas l'adresse MAC d'une autre machine à la volée.
> 💡 **À retenir** : Pour deux IP, appliquer le masque donne leur partie réseau. Si la partie réseau est identique → même sous-réseau → communication directe. Si elle diffère → il faut une passerelle.

---

**Question 5.** Une machine A (192.168.1.10/24) veut contacter l'adresse publique 8.8.8.8 (un serveur DNS de Google). Que se passe-t-il ?

**Réponse : A** — A applique son masque /24 à 8.8.8.8, constate que l'adresse n'est pas locale, et envoie le paquet à sa passerelle par défaut.

> ❌ B — ARP ne fonctionne qu'à l'intérieur d'un même réseau local (domaine de broadcast). 8.8.8.8 n'étant pas dans le réseau 192.168.1.0/24, aucune machine locale ne répondra à cette requête ARP.
> ❌ C — 8.8.8.8 est une adresse IP publique (serveur DNS de Google), pas une adresse privée. La machine ne refuse pas le paquet pour cette raison.
> ❌ D — Il n'existe aucun mécanisme automatique de traduction d'adresse à ce niveau ; seul un NAT configuré explicitement peut modifier les adresses.
> 💡 **À retenir** : La décision "local ou distant" se fait en comparant la partie réseau de la source et de la destination via le masque de sous-réseau. Si les parties réseau diffèrent → passerelle.

---

**Question 6.** Que signifie le sigle NAT (Network Address Translation) ?

**Réponse : D** — Le NAT (Network Address Translation) modifie l'adresse IP source ou destination dans l'en-tête des paquets pour permettre à des machines en adressage privé d'accéder à Internet via une adresse publique partagée.

> ❌ A — Le NAT ne compresse aucun paquet ; la compression éventuelle est gérée par d'autres mécanismes (ex. en-tête HTTP `Content-Encoding`).
> ❌ B — La redondance de routeurs est assurée par des protocoles comme HSRP, VRRP ou CARP, qui n'ont rien à voir avec le NAT.
> ❌ C — L'accélération de la résolution DNS est le rôle de services comme un cache DNS local, pas du NAT.
> 💡 **À retenir** : Le NAT est le mécanisme qui permet à des millions de foyers et d'entreprises d'utiliser Internet avec une seule adresse IP publique. Sans lui, on aurait épuisé les adresses IPv4 bien plus tôt.

---

**Question 7.** Pourquoi les adresses privées définies par la RFC 1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) ne sont-elles pas routables sur l'Internet public ?

**Réponse : B** — Par convention, tous les FAI rejettent ces plages, car des millions de réseaux utilisent les mêmes adresses privées.

> ❌ A — Les adresses privées RFC 1918 sont codées sur 32 bits, comme toutes les adresses IPv4. 10.0.0.0/8 signifie que seuls les 8 premiers bits sont fixes, les 24 restants sont libres.
> ❌ C — Les adresses privées utilisent exactement le même protocole TCP/IP que les adresses publiques. Aucune différence technique au niveau du protocole.
> ❌ D — Les adresses privées n'expirent pas. L'expiration (bail) concerne les adresses attribuées par DHCP, pas la nature privée ou publique d'une adresse.
> 💡 **Piège classique** : Une adresse privée et une adresse publique ont la même structure technique (32 bits, même protocole). La seule différence est une convention humaine : les FAI ont décidé de ne pas les router sur Internet.

---

**Question 8.** Quelle est la différence principale entre le routage statique (static routing) et le routage dynamique (dynamic routing) ?

**Réponse : C** — Le routage statique est configuré manuellement ; le routage dynamique utilise des protocoles d'échange automatique (OSPF, BGP).

> ❌ A — Les deux types de routage fonctionnent aussi bien en IPv4 qu'en IPv6. OSPFv3 et BGP-4+ gèrent l'IPv6 en routage dynamique.
> ❌ B — Le routage statique n'est pas "toujours plus rapide". Dans un grand réseau, un protocole dynamique peut découvrir un chemin plus court qu'une route statique mal configurée.
> ❌ D — C'est l'inverse : le routage statique est courant sur les petites box domestiques (peu de réseaux à gérer), tandis que le routage dynamique est massivement utilisé dans les datacenters pour s'adapter aux pannes.
> 💡 **À retenir** : Statique = tu écris les routes à la main, rien ne bouge sans toi. Dynamique = les routeurs se parlent automatiquement, le réseau s'adapte seul aux pannes. En pratique, on combine souvent les deux.

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

**Question 9.** Sous Linux, quelle commande ajoute une route pour que le réseau 192.168.2.0/24 soit joignable via le routeur 10.0.0.254 ?

**Réponse : B** — `ip route add 192.168.2.0/24 via 10.0.0.254`

> ❌ A — `ping -R` sert à enregistrer le chemin emprunté par les paquets ICMP (option Record Route), pas à ajouter une route.
> ❌ C — `ifconfig` est l'ancien outil de configuration des interfaces réseau. La syntaxe proposée n'existe pas. L'ancienne commande pour ajouter une route était `route add`.
> ❌ D — `traceroute -g` permet de spécifier une passerelle pour le traceroute, mais n'ajoute aucune route permanente dans la table.
> 💡 **Lien avec Linux** : La commande `ip` du paquet iproute2 est le standard moderne pour gérer les routes sous Linux. La syntaxe se lit : `ip route add <réseau_destination> via <adresse_prochain_routeur>`.

---

**Question 10.** Tu exécutes `ip route show` sur une machine Linux et tu lis la ligne suivante : `default via 10.0.0.1 dev eth0`. Que signifie-t-elle concrètement ?

**Réponse : D** — Tout paquet sans route spécifique sera envoyé au routeur 10.0.0.1 via eth0. C'est la route "fourre-tout".

> ❌ A — L'adresse 10.0.0.1 est celle du prochain routeur (next hop), pas l'adresse IP de la machine elle-même (qui serait affichée avec `src` dans une autre ligne).
> ❌ B — L'interface eth0 n'est pas désactivée ; au contraire, c'est par elle que le trafic de cette route est émis.
> ❌ C — La machine utilise la passerelle, elle ne se comporte pas elle-même comme passerelle pour d'autres machines. Pour cela, il faudrait activer le forwarding IP.
> 💡 **Lien avec Linux** : La route par défaut (`default` ou `0.0.0.0/0`) est toujours consultée en dernier recours. Si aucune autre route ne correspond à la destination, le paquet est envoyé vers cette passerelle.

---

**Question 11.** Un paquet part d'une machine A, traverse le routeur R1, puis le routeur R2, et arrive au serveur B. Qu'arrive-t-il aux adresses MAC source et destination à chaque saut ?

**Réponse : A** — Les MAC source/destination changent à chaque saut ; les IP source/destination restent inchangées (sauf NAT).

> ❌ B — Les adresses MAC sont locales à chaque lien physique (tronçon entre deux équipements). Elles doivent être mises à jour à chaque saut, sinon la trame ne pourrait pas être acheminée sur le tronçon suivant.
> ❌ C — C'est précisément l'inverse : les adresses IP restent inchangées de bout en bout (elles identifient la source et la destination finales), tandis que les adresses MAC sont locales à chaque saut.
> ❌ D — Les adresses MAC ne sont pas supprimées ; elles sont remplacées à chaque saut par les adresses MAC du tronçon suivant.
> 💡 **À retenir** : IP = adresse logique de bout en bout (ne change pas). MAC = adresse physique de saut en saut (change à chaque routeur). C'est comme une lettre postale : l'adresse du destinataire (IP) reste la même, mais le camion qui la transporte (MAC) change à chaque dépôt.

---

**Question 12.** En réseau, que désigne le terme "masquerading" (ou masquerade) ?

**Réponse : C** — Le masquerading est un SNAT dynamique : plusieurs machines partagent une IP publique, "masquées" derrière le routeur.

> ❌ A — Le chiffrement du trafic (via VPN, TLS, IPsec) n'a rien à voir avec le masquerading, qui est une technique de traduction d'adresse source.
> ❌ B — Cacher un serveur derrière un proxy inverse est une fonction de proxy (niveau applicatif), pas du masquerading (niveau réseau).
> ❌ D — Le filtrage de contenu web est une fonction de proxy ou de pare-feu applicatif, sans rapport avec la traduction d'adresses source.
> 💡 **Lien avec Linux** : Sous Linux, le masquerading se configure avec iptables : `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`. C'est exactement ce que fait une box Internet domestique.

---

**Question 13.** Avec le PAT (Port Address Translation), des dizaines de machines partagent une seule adresse IP publique. Comment le routeur NAT différencie-t-il les flux pour renvoyer la bonne réponse à la bonne machine ?

**Réponse : D** — Il utilise les ports source et une table de correspondance (IP privée + port ↔ IP publique + port).

> ❌ A — Le routeur NAT travaille au niveau 3 (IP) et 4 (TCP/UDP). Il n'inspecte pas le contenu HTTP (niveau 7) et ne peut pas lire un nom d'utilisateur dans les paquets.
> ❌ B — Le NAT n'attribue pas d'adresses MAC virtuelles. Les adresses MAC ne traversent d'ailleurs pas les routeurs : elles sont remplacées à chaque saut.
> ❌ C — Le champ TOS (Type of Service), devenu DSCP, sert à la qualité de service (QoS) pour prioriser certains paquets, pas à identifier une machine source.
> 💡 **À retenir** : PAT = NAT + multiplexage par ports. Sans les ports, une seule machine pourrait utiliser l'IP publique à la fois. Grâce aux ports, des dizaines de machines peuvent partager la même IP simultanément.

---

**Question 14.** Tu héberges un serveur web dans ton réseau privé, à l'adresse 10.0.1.50, port 443. Tu souhaites qu'il soit accessible depuis Internet via l'adresse IP publique 203.0.113.10. Quelle technique NAT dois-tu configurer sur le routeur ?

**Réponse : A** — Une règle DNAT (Destination NAT), aussi appelée port forwarding (redirection de port).

> ❌ B — Le SNAT modifie l'adresse source des paquets sortants, pas la destination des paquets entrants. Il sert à faire sortir des machines, pas à en exposer une.
> ❌ C — Le masquerading est un SNAT dynamique pour les connexions sortantes. Il ne permet pas de recevoir des connexions entrantes initiées depuis Internet.
> ❌ D — Un pare-feu peut autoriser ou bloquer le trafic sur un port, mais il ne traduit pas les adresses. Sans DNAT, le paquet arrivant sur l'IP publique ne saurait pas qu'il doit être redirigé vers 10.0.1.50.
> 💡 **À retenir** : SNAT = sorties (source modifiée). DNAT = entrées (destination modifiée). Pour exposer un service interne sur Internet, il faut du DNAT/port forwarding.

---

**Question 15.** Tu exécutes `ip route add 192.168.2.0/24 via 10.0.0.254` sur une machine Linux. Que viens-tu de faire ?

**Réponse : B** — Tu as ajouté une route statique : "pour joindre 192.168.2.0/24, passe par le routeur 10.0.0.254".

> ❌ A — Cette commande ne modifie pas l'adresse IP de la machine. Pour changer l'IP, on utilise `ip addr add` ou `ip addr change`.
> ❌ C — L'activation du NAT se fait avec des règles iptables (table nat), pas avec la commande `ip route` qui gère uniquement la table de routage.
> ❌ D — La commande ajoute une route (elle indique un chemin), elle ne bloque rien. Bloquer du trafic nécessiterait des règles de pare-feu (iptables, nftables).
> 💡 **Lien avec Linux** : La commande `ip route` est le couteau suisse du routage sous Linux. `ip route add` pour ajouter, `ip route del` pour supprimer, `ip route show` pour afficher. La route statique survit jusqu'au prochain redémarrage (sauf si ajoutée dans un fichier de configuration).

---

**Question 16.** Tu exécutes la commande suivante sur un serveur Linux : `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`. Quel est l'effet produit ?

**Réponse : C** — Le trafic sortant par eth0 voit son IP source remplacée par celle de eth0 : SNAT dynamique / masquerading.

> ❌ A — La règle ne bloque rien. POSTROUTING + MASQUERADE = traduction d'adresse source, pas filtrage. Pour bloquer, on utiliserait la table `filter` et les chaînes `INPUT` ou `FORWARD`.
> ❌ B — Cette règle ne déclenche aucun protocole de routage dynamique. OSPF se configure via des démons comme `ospfd` ou `bird`, pas via iptables.
> ❌ D — POSTROUTING + MASQUERADE = SNAT (traduction de la source). Le DNAT (traduction de la destination) se configure dans la chaîne PREROUTING avec l'action DNAT.
> 💡 **Lien avec Linux** : Cette unique ligne `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE` transforme n'importe quel serveur Linux en "box Internet". C'est la magie du noyau Linux : tout est intégré.

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

**Question 17.** Dans un VPC (Virtual Private Cloud, réseau privé virtuel chez un fournisseur cloud comme AWS), tu as deux sous-réseaux (subnets) : subnet-A (10.0.1.0/24) et subnet-B (10.0.2.0/24). Un routeur les relie. Que dois-tu vérifier pour que les instances de subnet-A puissent communiquer avec celles de subnet-B ?

**Réponse : A** — Vérifier les routes dans les deux sens et le forwarding IP activé sur le routeur.

> ❌ B — Le NAT n'est pas nécessaire entre deux sous-réseaux privés d'un même VPC. Le routage simple suffit : les adresses privées de part et d'autre sont connues et locales.
> ❌ C — Appartenir au même /8 (10.0.0.0/8) ne signifie pas que les sous-réseaux se voient automatiquement. Chaque /24 est un réseau distinct. Sans route, le trafic ne circule pas entre eux.
> ❌ D — Un routeur est précisément conçu pour interconnecter des réseaux distincts. Il n'est pas nécessaire de les fusionner en un /23. Au contraire, la segmentation en petits sous-réseaux est une bonne pratique de sécurité.
> 💡 **Lien avec AWS** : Dans AWS, les tables de routage sont associées aux sous-réseaux. Chaque sous-réseau a sa propre table. Pour que deux sous-réseaux communiquent, leurs tables respectives doivent contenir une route pointant vers la cible (target) appropriée, et le routage local (local) est automatique au sein du VPC.

---

**Question 18.** Dans AWS, tu déploies 10 instances EC2 dans un sous-réseau privé et tu les places derrière une NAT Gateway. Ces instances peuvent-elles recevoir une connexion initiée directement depuis Internet ?

**Réponse : D** — Non. La NAT Gateway ne fait que du SNAT sortant.

> ❌ A — La NAT Gateway ne rend pas les instances joignables depuis l'extérieur. Pour qu'une instance reçoive du trafic entrant, il faut la placer dans un sous-réseau public avec une Internet Gateway.
> ❌ B — Aucun port entrant n'est ouvert par une NAT Gateway, pas même le 443. Elle est strictement unidirectionnelle en entrée.
> ❌ C — Même avec un Security Group permissif, le trafic entrant ne peut pas atteindre l'instance car la NAT Gateway bloque toute connexion initiée depuis Internet au niveau réseau.
> 💡 **Lien avec AWS** : Internet Gateway = trafic entrant + sortant (sous-réseau public). NAT Gateway = trafic sortant uniquement (sous-réseau privé). C'est la différence fondamentale entre ces deux services.

---

**Question 19.** Dans la table de routage d'un sous-réseau public AWS, tu vois la route `0.0.0.0/0 → igw-xxxxxxxx`. Quel est le rôle de cette route ?

**Réponse : B** — Elle dirige le trafic non local vers l'Internet Gateway, rendant le sous-réseau public.

> ❌ A — Cette route ne bloque rien ; au contraire, elle achemine le trafic non local vers l'extérieur. Bloquer se ferait via des Network ACLs ou des Security Groups.
> ❌ C — `igw-xxxxxxxx` désigne une Internet Gateway (IGW). Une NAT Gateway est identifiée par le préfixe `nat-`. Ce sont deux services AWS différents.
> ❌ D — Un sous-réseau avec une route pointant vers une Internet Gateway est un sous-réseau **public** par définition. Un sous-réseau privé utilise une NAT Gateway (nat-) ou aucune passerelle vers Internet.
> 💡 **Lien avec AWS** : `0.0.0.0/0` signifie "toutes les adresses IP" (le monde entier moins le réseau local). Associé à un IGW, cela signifie : "tout ce qui n'est pas dans mon VPC, envoie-le sur Internet".

---

**Question 20.** Une instance EC2 située dans un sous-réseau privé, derrière une NAT Gateway, lance la commande `curl https://api.externe.com`. La réponse du serveur distant revient. Comment la NAT Gateway sait-elle à quelle instance privée renvoyer cette réponse ?

**Réponse : C** — Elle consulte sa table de correspondance NAT enregistrée lors de la connexion sortante.

> ❌ A — La NAT Gateway fonctionne au niveau 3 (IP) et 4 (TCP/UDP). Elle n'inspecte pas le contenu des paquets au niveau applicatif (HTTP). Elle ne peut pas lire le corps des réponses.
> ❌ B — Le TTL (Time To Live) est un compteur qui diminue à chaque routeur pour éviter les boucles infinies. Il n'a aucun rapport avec l'identification de la machine source.
> ❌ D — Il n'existe pas de champ dédié dans l'en-tête IP standard pour stocker l'adresse privée du destinataire. La correspondance est entièrement gérée par la table NAT locale du routeur.
> 💡 **À retenir** : Le mécanisme est exactement le même que le PAT étudié au niveau 2. NAT Gateway AWS = PAT à l'échelle du cloud. La table de correspondance est la pièce maîtresse qui fait tout fonctionner.

---

**Question 21.** Tu gères un serveur web interne accessible à l'adresse privée 10.0.1.50 sur le port 80. Tu disposes d'une adresse IP publique 203.0.113.10 attribuée à ton routeur. Tu veux que des utilisateurs sur Internet puissent accéder à ce serveur. Quelle règle configurer sur le routeur ?

**Réponse : D** — Une règle DNAT (Destination NAT) / port forwarding.

> ❌ A — Le SNAT modifie la source des paquets sortants, pas la destination des paquets entrants. Pour recevoir une connexion, c'est la destination qu'il faut traduire.
> ❌ B — Le masquerading est du SNAT sortant. Une box domestique fait du masquerading pour permettre aux machines du foyer de sortir sur Internet. Exposer un serveur web nécessite du DNAT en plus (souvent appelé "redirection de port" sur les box).
> ❌ C — Un Security Group peut autoriser le trafic sur le port 80, mais sans règle NAT, le paquet entrant ne saurait pas vers quelle adresse privée interne être acheminé. Security Group ≠ NAT.
> 💡 **Piège classique** : Beaucoup confondent "ouvrir un port dans le pare-feu" et "faire du port forwarding". Le pare-feu autorise le passage, le NAT traduit la destination. Les deux sont nécessaires pour exposer un service interne.

---

**Question 22.** Dans AWS, ta NAT Gateway est déployée dans une seule zone de disponibilité (Availability Zone, AZ). Cette AZ subit une panne majeure. Quelle est la conséquence directe pour les instances des sous-réseaux privés qui dépendent de cette NAT Gateway ?

**Réponse : A** — Elles perdent toute connectivité sortante vers Internet.

> ❌ B — Il n'y a pas de basculement automatique vers une NAT Gateway d'une autre AZ. Pour être résilient, il faut déployer une NAT Gateway par AZ et configurer les tables de routage en conséquence.
> ❌ C — AWS n'attribue pas automatiquement d'IP publiques de secours aux instances d'un sous-réseau privé en cas de panne de la NAT Gateway.
> ❌ D — AWS ne migre pas automatiquement les instances EC2 vers une autre AZ. La migration est une opération manuelle (ou scriptée) impliquant la création d'AMIs ou de snapshots.
> 💡 **Piège classique** : La NAT Gateway est un service zonal (attaché à une AZ). Une bonne architecture cloud prévoit une NAT Gateway par AZ pour éviter un point de défaillance unique (single point of failure). C'est une question récurrente aux certifications AWS.

---

**Question 23.** Dans la table de routage d'un sous-réseau AWS, tu vois la ligne `10.0.0.0/16 → local`. Un paquet arrive avec comme destination 10.0.5.12. Comment le routeur traite-t-il ce paquet ?

**Réponse : C** — Il reconnaît que 10.0.5.12 appartient au réseau local 10.0.0.0/16 et délivre le paquet directement.

> ❌ A — Le routeur n'envoie pas le paquet à l'Internet Gateway, car 10.0.5.12 fait partie du CIDR local 10.0.0.0/16. L'IGW n'est sollicitée que pour les destinations extérieures au VPC.
> ❌ B — Le trafic interne au VPC (entre deux adresses du même 10.0.0.0/16) est parfaitement autorisé par défaut. Le routeur ne le bloque pas.
> ❌ D — Aucun DNAT n'est nécessaire pour du trafic entre deux adresses privées d'un même VPC. Le DNAT intervient uniquement quand une adresse publique doit être traduite en adresse privée.
> 💡 **Lien avec AWS** : Dans un VPC, la route `local` est automatique et ne peut pas être supprimée. Elle couvre tout le CIDR du VPC et garantit que toutes les ressources internes peuvent se parler sans configuration supplémentaire.

---

**Question 24.** Une machine Linux possède la table de routage simplifiée suivante :

```
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.15
192.168.0.0/16 via 10.0.0.254 dev eth0
192.168.5.0/24 via 10.0.0.253 dev eth0
```

Un paquet doit être envoyé à l'adresse 192.168.5.20. Quel chemin va-t-il emprunter, et pourquoi ?

**Réponse : B** — La route la plus spécifique `/24` l'emporte : longest prefix match (préfixe le plus long).

> ❌ A — La route par défaut (0.0.0.0/0, préfixe de 0 bit) n'est utilisée qu'en dernier recours, si aucune autre route plus spécifique ne correspond à la destination.
> ❌ C — La route 192.168.0.0/16 couvre bien 192.168.5.20, mais elle est moins spécifique (préfixe de 16 bits) que la route 192.168.5.0/24 (préfixe de 24 bits). Le routeur choisit toujours la plus spécifique.
> ❌ D — Avoir plusieurs routes qui couvrent la même destination n'est pas une erreur ; c'est une situation normale. Le routeur applique la règle du préfixe le plus long pour choisir sans ambiguïté.
> 💡 **À retenir** : `192.168.5.0/24` (24 bits de masque) est plus spécifique que `192.168.0.0/16` (16 bits), qui est elle-même plus spécifique que `0.0.0.0/0` (0 bit). La route la plus précise gagne toujours. C'est le fondement du routage IP.

---

**Question 25.** Dans une architecture cloud professionnelle, on sépare généralement les ressources en sous-réseaux publics et privés. Où place-t-on un serveur web et une base de données, et pourquoi ?

**Réponse : D** — Web en sous-réseau public (ou derrière un Load Balancer public), base de données en sous-réseau privé.

> ❌ A — Placer la base de données dans un sous-réseau public l'expose directement à Internet. C'est une faille de sécurité majeure : toute personne pourrait tenter de s'y connecter sans passer par l'application.
> ❌ B — Si tout est en privé sans exposition publique, les utilisateurs d'Internet ne peuvent tout simplement pas accéder au site web. Le serveur web doit être joignable depuis l'extérieur.
> ❌ C — Exposer la base de données publiquement et cacher le serveur web est l'inverse de la bonne pratique. La base de données contient les données sensibles, elle doit être la plus protégée.
> 💡 **À retenir** : Dans le cloud, on applique le principe de défense en profondeur (defense in depth) : les ressources sensibles (bases de données, caches, files de messages) restent en sous-réseau privé. Seules les ressources qui doivent impérativement être joignables depuis Internet (serveurs web, Load Balancers) sont exposées, et uniquement sur les ports nécessaires.
