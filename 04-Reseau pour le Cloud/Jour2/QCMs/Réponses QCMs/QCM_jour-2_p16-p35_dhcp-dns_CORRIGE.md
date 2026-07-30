# CORRIGÉ — QCM Jour 2, pages 16 à 35 : DHCP et DNS

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

### Question 1

**Question 1.** Dans le cycle DORA (Discover, Offer, Request, Acknowledge) de DHCP, que fait le client pendant la première étape « Discover » ?

A) Il envoie une requête directe à l'adresse IP du serveur DHCP qu'il a mémorisée lors d'une connexion précédente.

B) Il télécharge depuis Internet la liste des serveurs DHCP disponibles sur le réseau local.

C) Il attend qu'un serveur DHCP le contacte spontanément pour lui proposer une adresse.

D) Il diffuse un message en broadcast (vers `255.255.255.255`) sur le réseau local pour demander « Y a-t-il un serveur DHCP ici ? ».

**Réponse : D** — Le client ne connaît aucun serveur DHCP au démarrage : il diffuse donc un message en broadcast (vers `255.255.255.255`) pour demander « Y a-t-il un serveur DHCP ici ? ». C'est le premier pas du dialogue DORA.**

> ❌ A — Le client ne sait pas quelle machine est le serveur DHCP, il ne peut pas lui envoyer de message direct.
> ❌ B — Le protocole DHCP fonctionne uniquement sur le réseau local pour l'étape Discover, jamais via Internet.
> ❌ C — C'est toujours le client qui lance la conversation ; un serveur DHCP ne contacte jamais un client spontanément.
> 💡 **À retenir** : DHCP est un protocole d'**amorçage** (bootstrapping) : le client part de zéro, sans aucune configuration réseau préalable, d'où le broadcast.

---

### Question 2

**Question 2.** Dans la hiérarchie DNS, quel est l'ordre de résolution d'un nom de domaine, du plus haut niveau jusqu'au plus précis ?

A) Serveur TLD → Serveur autoritaire → Serveur racine

B) Serveur racine → Serveur TLD → Serveur autoritaire

C) Serveur autoritaire → Serveur racine → Serveur TLD

D) Serveur TLD → Serveur racine → Serveur autoritaire

**Réponse : B** — La résolution DNS suit une hiérarchie descendante : le résolveur interroge d'abord un serveur racine (`.`), qui le redirige vers le serveur TLD (`.fr`, `.com`…), lequel le redirige enfin vers le serveur autoritaire du domaine recherché.**

> ❌ A — Le TLD ne peut pas être interrogé avant la racine : c'est la racine qui donne l'adresse des serveurs TLD.
> ❌ C — Ordre totalement inversé : le serveur autoritaire est tout en bas de la hiérarchie, pas en haut.
> ❌ D — Le serveur TLD se situe entre la racine et l'autoritaire, pas après l'autoritaire.
> 💡 **À retenir** : Comme un annuaire papier : d'abord le pays (racine), puis la région (TLD), puis l'adresse exacte (autoritaire).

---

### Question 3

**Question 3.** Un enregistrement DNS de type A (Address) contient quoi exactement ?

A) Une correspondance entre un nom de domaine (ex. `www.exemple.fr`) et une adresse IPv4 (ex. `93.184.216.34`).

B) Un alias qui redirige un nom de domaine vers un autre nom de domaine.

C) Le nom du serveur de messagerie qui reçoit les emails du domaine.

D) Une chaîne de texte libre utilisée pour la vérification de propriété du domaine.

**Réponse : A** — Un enregistrement A (Address) est le plus basique du DNS : il associe directement un nom de domaine (ex. `www.exemple.fr`) à une adresse IPv4 (ex. `93.184.216.34`).**

> ❌ B — Un alias d'un nom vers un autre nom, c'est un enregistrement CNAME.
> ❌ C — Le serveur de messagerie est déclaré par un enregistrement MX.
> ❌ D — Une chaîne de texte arbitraire se stocke dans un enregistrement TXT.
> 💡 **Piège classique** : Ne pas confondre A (nom → IPv4), CNAME (nom → nom) et MX (nom → serveur mail). Chaque type a un usage précis.

---

### Question 4

**Question 4.** Une machine Linux affiche l'adresse IP `169.254.12.77` avec la commande `ip addr`. Que signifie cette adresse ?

A) C'est une adresse IP publique attribuée par le fournisseur d'accès à Internet (FAI).

B) C'est l'adresse de loopback utilisée exclusivement pour tester la pile réseau locale.

C) La machine n'a pas trouvé de serveur DHCP. Elle s'est auto-attribué une adresse APIPA (Automatic Private IP Addressing). Elle peut communiquer sur le réseau local uniquement, sans accès à Internet.

D) Le serveur DHCP a volontairement attribué cette adresse car elle fait partie d'une plage privée standard (RFC 1918).

**Réponse : C** — La plage `169.254.0.0/16` est réservée à l'APIPA (Automatic Private IP Addressing). Quand une machine cherche un serveur DHCP et n'en trouve aucun, elle s'attribue elle-même une adresse dans cette plage. Elle peut parler aux autres machines en APIPA sur le même réseau local, mais n'a aucune passerelle donc pas d'accès à Internet.**

> ❌ A — Les adresses publiques sont attribuées par le FAI, jamais en `169.254.x.x`.
> ❌ B — L'adresse de loopback est toujours `127.0.0.1` (ou `::1` en IPv6), pas `169.254.x.x`.
> ❌ D — Un serveur DHCP n'attribue jamais d'adresse `169.254.x.x` ; les plages privées standard (RFC 1918) sont `10.x.x.x`, `172.16-31.x.x` et `192.168.x.x`.
> 💡 **Lien avec Linux** : Une adresse APIPA sur une interface signifie souvent un câble débranché, un VLAN mal configuré ou un serveur DHCP injoignable. Vérifier avec `ip addr` puis `ip route` pour confirmer l'absence de passerelle.

---

### Question 5

**Question 5.** Dans le cycle DORA, que se passe-t-il pendant l'étape « Offer » ?

A) Le client déclare officiellement qu'il accepte l'adresse IP proposée.

B) Le routeur du réseau accuse réception du message Discover envoyé par le client.

C) Le serveur DHCP libère une adresse IP qui était déjà attribuée à un autre client.

D) Le serveur DHCP répond au client avec une proposition contenant : une adresse IP, la durée du bail (lease), le masque de sous-réseau, la passerelle par défaut (default gateway) et les serveurs DNS.

**Réponse : D** — Après avoir reçu le Discover, le serveur DHCP répond par une offre (Offer). Cette offre contient une adresse IP proposée, la durée du bail, le masque de sous-réseau, la passerelle par défaut et les serveurs DNS. Le client n'a encore rien accepté à ce stade.**

> ❌ A — L'acceptation officielle par le client correspond à l'étape Request (le R de DORA).
> ❌ B — Le routeur n'intervient pas directement dans le dialogue DHCP, sauf s'il joue le rôle de relais DHCP (DHCP relay).
> ❌ C — Le serveur ne libère pas d'adresse déjà attribuée pendant l'Offer ; il en propose une parmi son pool d'adresses disponibles.
> 💡 **À retenir** : L'ordre DORA est immuable : Discover (client → broadcast) → Offer (serveur → client) → Request (client → serveur) → Acknowledge (serveur → client).

---

### Question 6

**Question 6.** Un enregistrement CNAME (Canonical Name) sert à quoi ?

A) Créer un alias : faire pointer un nom de domaine vers un autre nom de domaine (ex. `www.exemple.fr CNAME exemple.fr`).

B) Associer directement un nom de domaine à une adresse IPv4.

C) Déclarer les serveurs de noms (name servers) qui font autorité sur la zone DNS.

D) Stocker le numéro de série (serial) de la zone pour permettre la synchronisation entre serveurs DNS.

**Réponse : A** — Un enregistrement CNAME (Canonical Name) crée un alias : il fait pointer un nom de domaine vers un autre nom de domaine. Par exemple, `www.exemple.fr CNAME exemple.fr` signifie que `www.exemple.fr` est un alias de `exemple.fr`.**

> ❌ B — Associer un nom à une adresse IPv4 est le rôle d'un enregistrement A.
> ❌ C — Déclarer les serveurs de noms autoritaires se fait avec des enregistrements NS.
> ❌ D — Le numéro de série est un champ de l'enregistrement SOA.
> 💡 **Piège classique** : Un CNAME ne peut pas coexister avec d'autres enregistrements sur le même nœud (même nom). Si `www` a un CNAME, il ne peut pas avoir d'enregistrement A ou MX en plus.

---

### Question 7

**Question 7.** Qu'est-ce que le bail DHCP (lease) ?

A) Un fichier de configuration qui liste les adresses MAC des machines autorisées sur le réseau.

B) La durée pendant laquelle l'adresse IP est attribuée au client. À expiration, le client doit renouveler ou libérer l'adresse.

C) Le nom du réseau Wi-Fi (SSID) diffusé par le point d'accès.

D) Une copie de sauvegarde automatique de la configuration du serveur DHCP.

**Réponse : B** — Le bail (lease) est la durée pendant laquelle l'adresse IP est prêtée au client par le serveur DHCP. Le client doit renouveler le bail avant son expiration pour garder l'adresse ; sinon, elle retourne dans le pool d'adresses disponibles.**

> ❌ A — Un fichier listant les adresses MAC autorisées serait une forme de filtrage MAC, pas un bail DHCP.
> ❌ C — Le nom du réseau Wi-Fi s'appelle le SSID (Service Set Identifier).
> ❌ D — La sauvegarde de configuration du serveur DHCP n'a aucun rapport avec le concept de bail.
> 💡 **À retenir** : Le bail DHCP, c'est une location temporaire, pas une propriété définitive. L'adresse est « empruntée » pour une durée limitée.

---

### Question 8

**Question 8.** Quel est le rôle d'un résolveur DNS récursif (recursive resolver) ?

A) Héberger les zones DNS de tous les domaines enregistrés dans le monde.

B) Traduire les adresses IP en adresses MAC pour la communication sur le réseau local.

C) Parcourir la hiérarchie DNS — racine, TLD, autoritaire — à la place du client et lui retourner uniquement la réponse finale.

D) Générer et attribuer les adresses IP aux machines qui se connectent au réseau.

**Réponse : C** — Le résolveur DNS récursif (souvent fourni par le FAI ou un service comme `8.8.8.8`) fait tout le travail à la place du client : il interroge la racine, puis le TLD, puis l'autoritaire, et ne retourne au client que la réponse finale.**

> ❌ A — Aucun serveur n'héberge toutes les zones DNS du monde ; le DNS est un système distribué par nature.
> ❌ B — La traduction IP → MAC est le rôle du protocole ARP (Address Resolution Protocol), pas du DNS.
> ❌ D — La génération et l'attribution d'adresses IP est le rôle du serveur DHCP, pas du DNS.
> 💡 **Lien avec Linux** : C'est le fichier `/etc/resolv.conf` qui contient l'adresse du résolveur utilisé par la machine. On peut le tester avec `dig` ou `nslookup`.

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

### Question 9

**Question 9.** Un client DHCP reçoit un bail de 8 heures. Au bout de combien de temps tente-t-il de renouveler ce bail pour la première fois ?

A) Au bout de 4 heures, soit à 50 % de la durée du bail (timer T1).

B) Au bout de 30 minutes, quel que soit le bail attribué.

C) Au bout de 7 heures, soit à 87,5 % de la durée du bail (timer T2).

D) À la dernière minute de la 8ᵉ heure, juste avant l'expiration du bail.

**Réponse : A** — Le client DHCP tente un premier renouvellement à 50 % de la durée du bail (appelé timer T1). Pour un bail de 8 heures, cela donne 4 heures. Si cette tentative échoue, il réessaie à 87,5 % (timer T2), soit environ 7 heures.**

> ❌ B — 30 minutes n'a aucun rapport avec le cycle de renouvellement standard défini par la RFC 2131.
> ❌ C — 87,5 % correspond à la seconde tentative (T2), pas à la première.
> ❌ D — Attendre la dernière minute est trop risqué : si le serveur ne répond pas, l'adresse expire et le client perd sa connectivité.
> 💡 **À retenir** : Deux tentatives de renouvellement : T1 à 50 % (first renewal), T2 à 87,5 % (rebinding). Le client anticipe, il ne joue pas avec le feu.

---

### Question 10

**Question 10.** Le champ TTL (Time To Live) d'un enregistrement DNS indique :

A) Le nombre maximal de sauts (hops) qu'un paquet IP peut traverser avant d'être détruit.

B) La date d'expiration du nom de domaine chez le bureau d'enregistrement (registrar).

C) Le délai avant qu'une adresse IP attribuée par DHCP soit automatiquement libérée.

D) La durée, en secondes, pendant laquelle un résolveur DNS peut conserver l'enregistrement dans son cache avant de le redemander au serveur autoritaire.

**Réponse : D** — Le TTL (Time To Live) DNS est une durée en secondes qui indique combien de temps un résolveur peut conserver l'enregistrement dans son cache avant de devoir le redemander au serveur autoritaire.**

> ❌ A — Le TTL des paquets IP (dans l'en-tête IP) est un compteur de sauts (hops), pas une durée. C'est un abus de langage : le même sigle, deux concepts différents.
> ❌ B — La date d'expiration du domaine chez le registrar est une notion totalement distincte (elle se mesure en années, pas en secondes).
> ❌ C — Le délai avant libération d'une IP DHCP est le bail (lease), pas le TTL.
> 💡 **Piège classique** : TTL signifie deux choses différentes selon le contexte — Time To Live en DNS (durée de cache) vs. Time To Live en IP (nombre de sauts). Ne pas les confondre.

---

### Question 11

**Question 11.** L'enregistrement SOA (Start of Authority) d'une zone DNS contient notamment :

A) La liste de toutes les adresses IPv4 et IPv6 associées au domaine.

B) Les règles de redirection HTTP (codes 301/302) configurées pour le site web.

C) Le numéro de série (serial) de la zone, qui permet aux serveurs DNS secondaires de détecter qu'une mise à jour a eu lieu.

D) Le nom public et l'adresse postale du propriétaire du domaine.

**Réponse : C** — L'enregistrement SOA (Start of Authority) est le premier enregistrement de toute zone DNS. Il contient le numéro de série (serial) — un compteur qui permet aux serveurs DNS secondaires de détecter qu'une mise à jour a eu lieu en comparant leur serial local avec celui du serveur primaire.**

> ❌ A — Les adresses IPv4 se stockent dans des enregistrements A, les adresses IPv6 dans des enregistrements AAAA.
> ❌ B — Les redirections HTTP (301/302) sont gérées par le serveur web (Apache, Nginx), pas par un enregistrement DNS.
> ❌ D — Le SOA contient l'adresse email de l'administrateur de la zone (champ RNAME), pas le nom public du propriétaire.
> 💡 **À retenir** : Le SOA, c'est la « carte d'identité » d'une zone DNS. Il contient : serial, refresh, retry, expire, minimum TTL (SRREM, l'acronyme mnémotechnique).

---

### Question 12

**Question 12.** On entend souvent qu'« il faut 24 à 48 heures pour qu'un changement DNS se propage ». Pourquoi cette idée de « propagation » est-elle trompeuse ?

A) Parce que les modifications DNS sont toujours instantanées sur tous les serveurs du monde.

B) Parce qu'il n'y a pas de « push » d'un serveur à l'autre : chaque résolveur a son propre cache qui expire selon le TTL de l'enregistrement. Le délai vient de l'expiration progressive de tous ces caches.

C) Parce que le DNS est un système centralisé où un seul serveur détient toutes les données.

D) Parce que les changements DNS ne concernent que le réseau local et n'affectent pas Internet.

**Réponse : B** — Il n'y a pas de « push » d'un serveur DNS vers un autre. Chaque résolveur possède son propre cache. Tant que le TTL de l'enregistrement n'a pas expiré dans le cache d'un résolveur donné, ce résolveur continue de servir l'ancienne valeur. Le délai perçu (24-48 h) vient du fait que certains TTL sont longs et que les caches expirent de façon indépendante.**

> ❌ A — Les changements DNS ne sont jamais instantanés partout, précisément à cause des caches.
> ❌ C — Le DNS est par nature distribué (des milliers de serveurs), pas centralisé.
> ❌ D — Le DNS est justement le système qui permet la résolution à l'échelle mondiale, pas seulement locale.
> 💡 **À retenir** : Le terme « propagation DNS » est un abus de langage. On devrait dire « expiration des caches DNS ». La seule certitude est le TTL que vous avez défini.

---

### Question 13

**Question 13.** Tu exécutes `dig exemple.fr MX` et tu obtiens des réponses avec des nombres comme `10 mail1.exemple.fr`, `20 mail2.exemple.fr`. Que signifient ces nombres ?

A) La priorité du serveur de messagerie : plus le nombre est petit, plus le serveur est prioritaire. L'expéditeur tente d'abord le serveur de priorité 10, puis 20 en cas d'échec.

B) Le port TCP sur lequel chaque serveur de messagerie écoute les connexions SMTP.

C) Le nombre de sauts réseau (hops) nécessaires pour atteindre chaque serveur de messagerie.

D) Le TTL en secondes avant que l'enregistrement MX ne soit automatiquement supprimé.

**Réponse : A** — Dans un enregistrement MX, le nombre (10, 20, 30…) indique la priorité. Plus le nombre est petit, plus le serveur est prioritaire. L'expéditeur tente de livrer le mail au serveur de priorité 10 d'abord ; s'il est injoignable, il passe au 20, et ainsi de suite.**

> ❌ B — Le port SMTP standard est le 25 (ou 587 pour la soumission) ; le nombre dans le MX n'est pas un numéro de port.
> ❌ C — Le nombre de sauts (hops) est une notion de routage IP (TTL dans l'en-tête IP), pas de DNS.
> ❌ D — Le TTL est un champ séparé de l'enregistrement MX, ce n'est pas le nombre de priorité.
> 💡 **Lien avec Linux** : `dig exemple.fr MX` affiche les serveurs MX avec leur priorité. Tester avec `swaks` ou `telnet mail.exemple.fr 25` pour vérifier qu'un serveur est joignable.

---

### Question 14

**Question 14.** Tu exécutes `dig +trace monsite.fr` sur une machine Linux. Que vois-tu apparaître dans la sortie ?

A) La liste de toutes les adresses MAC des équipements réseau traversés pendant la résolution.

B) Uniquement l'adresse IP finale de `monsite.fr`, sans les étapes intermédiaires.

C) Les logs de sécurité et d'authentification du serveur DNS de `monsite.fr`.

D) Le parcours complet de résolution : d'abord les serveurs racine, puis les serveurs TLD de `.fr`, puis les serveurs autoritaires de `monsite.fr`, qui donnent la réponse finale.

**Réponse : D** — L'option `+trace` de `dig` désactive la résolution récursive et affiche chaque étape du parcours : le résolveur interroge d'abord les serveurs racine, qui répondent avec les serveurs TLD de `.fr`, puis ces TLD renvoient vers les serveurs autoritaires de `monsite.fr`, qui donnent la réponse finale. C'est un outil de diagnostic très puissant.**

> ❌ A — `dig` est un outil DNS de niveau 7 (application) ; il ne montre pas les adresses MAC (niveau 2).
> ❌ B — Sans `+trace`, `dig` ne montre que la réponse finale. Avec `+trace`, il montre tout le chemin.
> ❌ C — Les logs de sécurité et d'authentification ne font pas partie de la sortie standard de `dig`.
> 💡 **Lien avec Linux** : `dig +trace` est l'équivalent de faire le travail du résolveur récursif à la main. Très utile pour diagnostiquer où une résolution échoue.

---

### Question 15

**Question 15.** Pour configurer des emails professionnels (Google Workspace ou Microsoft 365), le fournisseur te demande d'ajouter un enregistrement TXT contenant une chaîne comme `MS=ms12345678`. À quoi sert concrètement cet enregistrement TXT ?

A) À rediriger le trafic web du domaine vers le serveur de messagerie.

B) À prouver que tu es bien le propriétaire du domaine : le fournisseur vérifie la présence de la chaîne unique dans le DNS pour valider le domaine.

C) À accélérer la livraison des emails sortants vers les destinataires.

D) À attribuer une adresse IP publique fixe à ton serveur de messagerie.

**Réponse : B** — L'enregistrement TXT de vérification permet au fournisseur (Google, Microsoft…) de vérifier que tu es bien le propriétaire du domaine. Comme toi seul peux modifier les enregistrements DNS de ton domaine, la présence du code unique qu'il t'a fourni prouve que tu contrôles bien ce domaine.**

> ❌ A — La redirection du trafic web se fait au niveau HTTP (codes 301/302) ou par CNAME, pas par un TXT de vérification.
> ❌ C — Un TXT de vérification n'a aucun impact sur la vitesse ou la fiabilité de livraison des emails (c'est le rôle de SPF, DKIM et DMARC — d'autres types d'enregistrements TXT).
> ❌ D — Un enregistrement TXT ne contient que du texte ; il ne peut pas attribuer d'adresse IP.
> 💡 **Piège classique** : Les enregistrements TXT servent à tout sauf à la résolution de noms. Leur usage le plus courant : vérification de domaine, SPF (anti-spam), DKIM (signature des emails), DMARC (politique de sécurité email).

---

### Question 16

**Question 16.** Tu exécutes `ip addr` sur une machine Linux et tu vois `inet 169.254.201.45/16`. Tu exécutes `ip route` et tu ne vois aucune passerelle par défaut (`default via`). Que conclus-tu ?

A) La carte réseau est physiquement défaillante et doit être remplacée immédiatement.

B) La machine est correctement configurée : `169.254.x.x` est une plage publique parfaitement routable sur Internet.

C) La machine n'a pas réussi à joindre de serveur DHCP. Elle a une adresse APIPA et ne peut communiquer qu'avec les machines du même segment réseau, également en APIPA. Aucun accès à Internet n'est possible.

D) Le serveur DHCP a délibérément attribué cette configuration pour isoler la machine d'Internet.

**Réponse : C** — L'adresse `169.254.x.x` est une adresse APIPA, auto-attribuée quand aucun serveur DHCP n'est joignable. L'absence de passerelle par défaut dans `ip route` confirme le diagnostic : sans passerelle, la machine ne peut pas sortir du réseau local. Elle peut uniquement communiquer avec d'autres machines du même segment qui sont aussi en APIPA.**

> ❌ A — Une adresse APIPA ne signifie pas que la carte réseau est défaillante ; elle prouve au contraire que la carte fonctionne (elle a pu s'auto-configurer).
> ❌ B — La plage `169.254.0.0/16` est une plage link-local, strictement non routable sur Internet.
> ❌ D — Un serveur DHCP n'attribue jamais d'adresse APIPA volontairement ; c'est un mécanisme de dernier recours du client, pas du serveur.
> 💡 **Lien avec Linux** : Deux commandes pour diagnostiquer : `ip addr` (voir l'IP auto-attribuée) puis `ip route` (vérifier l'absence de `default via`). Si les deux signaux sont présents → problème DHCP quasi certain.

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

### Question 17

**Question 17.** Tu déploies une nouvelle instance EC2 dans un sous-réseau privé de ton VPC AWS. Par défaut, comment cette instance obtient-elle son adresse IP privée ?

A) L'instance démarre avec une adresse APIPA (`169.254.x.x`) que tu dois remplacer manuellement.

B) Tu dois obligatoirement te connecter en SSH et configurer une IP statique dans le fichier `/etc/netplan/`.

C) L'instance envoie une requête au service AWS Route 53 pour obtenir une adresse IP disponible.

D) Le service DHCP intégré à chaque VPC AWS lui attribue automatiquement une adresse IP dans la plage CIDR du sous-réseau, sans aucune intervention.

**Réponse : D** — Chaque VPC AWS intègre un service DHCP natif, invisible mais automatique. Dès qu'une instance EC2 démarre dans un sous-réseau, ce service lui attribue une adresse IP privée dans la plage CIDR du sous-réseau. L'administrateur n'a absolument rien à configurer.**

> ❌ A — Une instance EC2 dans un VPC ne démarre jamais en APIPA, sauf défaillance rarissime du service DHCP du VPC.
> ❌ B — Aucune configuration manuelle dans `/etc/netplan/` n'est nécessaire pour obtenir une IP de base dans un VPC.
> ❌ C — Route 53 est le service DNS d'AWS ; il n'attribue pas d'adresses IP aux instances. DHCP et DNS sont deux services distincts.
> 💡 **Lien avec AWS** : Le DHCP intégré au VPC fonctionne comme le `dhclient` sous Linux, mais il est managé par AWS. L'IP privée attribuée au premier démarrage est généralement conservée jusqu'à la terminaison de l'instance.

---

### Question 18

**Question 18.** Tu as déployé une application web sur une instance EC2 avec une IP élastique (Elastic IP) `3.120.45.10`. Tu veux que `www.monsite.fr` pointe vers cette IP. Quel type d'enregistrement DNS dois-tu créer ?

A) Un enregistrement A, car il fait la correspondance directe entre un nom de domaine et une adresse IPv4.

B) Un enregistrement CNAME, car toute résolution DNS doit obligatoirement passer par un alias intermédiaire.

C) Un enregistrement TXT, car il faut d'abord prouver la propriété du domaine avant de le faire pointer vers une IP.

D) Un enregistrement MX, car c'est le seul type d'enregistrement qui accepte une adresse IP publique.

**Réponse : A** — L'enregistrement A fait la correspondance directe entre un nom de domaine et une adresse IPv4. Puisque tu disposes d'une IP élastique fixe (`3.120.45.10`), c'est l'enregistrement A qu'il faut créer : `www.monsite.fr A 3.120.45.10`.**

> ❌ B — Un CNAME pointe vers un nom de domaine, pas vers une adresse IP. Il faudrait un nom cible, pas une IP.
> ❌ C — Un TXT n'est pas conçu pour la résolution de nom vers IP.
> ❌ D — Un MX est exclusivement dédié à la messagerie (réception d'emails).
> 💡 **Lien avec AWS** : Une Elastic IP est une adresse IPv4 publique statique. C'est l'un des rares cas AWS où un enregistrement A est parfaitement adapté (contrairement à un ALB qui nécessite un CNAME).

---

### Question 19

**Question 19.** Un collègue modifie un enregistrement DNS et t'appelle deux minutes plus tard : « Ça ne marche pas, le changement n'apparaît pas chez moi ! » Tu vérifies sur le serveur autoritaire : la modification est bien enregistrée. Quelle est l'explication la plus probable ?

A) Le serveur autoritaire doit être redémarré manuellement pour que la modification prenne effet.

B) Le résolveur DNS de ton collègue (FAI, box, ou navigateur) a encore l'ancienne valeur en cache. Il doit attendre l'expiration du TTL ou vider son cache local (`ipconfig /flushdns` ou `sudo resolvectl flush-caches`).

C) Le registrar a automatiquement bloqué la modification pour des raisons de sécurité.

D) Les modifications DNS ne prennent effet que lors de la fenêtre de maintenance hebdomadaire, le dimanche à minuit UTC.

**Réponse : B** — Même si la modification est bien enregistrée sur le serveur autoritaire, les résolveurs DNS intermédiaires (FAI, box, navigateur) conservent l'ancienne valeur en cache. Tant que le TTL n'a pas expiré dans leur cache, ils servent cette ancienne valeur.**

> ❌ A — Les serveurs DNS n'ont pas besoin d'être redémarrés pour qu'un changement de zone prenne effet.
> ❌ C — Le registrar ne bloque pas les modifications d'enregistrements DNS une fois le domaine délégué aux serveurs de noms.
> ❌ D — Il n'existe aucune fenêtre de maintenance imposée pour la prise en compte des modifications DNS.
> 💡 **À retenir** : En cas de changement DNS urgent, on peut réduire le TTL à l'avance (ex. 300 secondes = 5 minutes), faire la modification, puis remonter le TTL une fois le changement confirmé.

---

### Question 20

**Question 20.** Dans un VPC AWS, tu peux personnaliser les paramètres réseau distribués aux instances EC2 en utilisant un DHCP Option Set. Lequel de ces paramètres est configurable dans un DHCP Option Set AWS ?

A) La plage d'adresses IP (CIDR block) attribuée au sous-réseau.

B) Le type d'instance EC2 (`t3.micro`, `m5.large`) attribué par défaut aux nouvelles instances.

C) Les serveurs DNS (domain-name-servers) que les instances utiliseront pour la résolution de noms.

D) Le nombre maximal d'instances EC2 autorisées à se connecter simultanément au VPC.

**Réponse : C** — Un DHCP Option Set dans AWS permet de personnaliser les paramètres que le service DHCP distribue aux instances : notamment les serveurs DNS (`domain-name-servers`), le nom de domaine (`domain-name`), les serveurs NTP et les serveurs NetBIOS.**

> ❌ A — La plage CIDR est définie au niveau du sous-réseau (subnet), pas dans le DHCP Option Set.
> ❌ B — Le type d'instance EC2 est choisi au moment du lancement par l'utilisateur, il n'est pas distribué par DHCP.
> ❌ D — Le nombre maximal d'instances est une limite de compte AWS (service quota), pas un paramètre DHCP.
> 💡 **Lien avec AWS** : Par défaut, le DHCP Option Set d'un VPC distribue `AmazonProvidedDNS` (le Route 53 Resolver interne). Si tu as un Active Directory managé (AWS Directory Service), tu modifies le DHCP Option Set pour pointer vers les DNS AD.

---

### Question 21

**Question 21.** Tu déploies une application derrière un Application Load Balancer (ALB) AWS. L'ALB a un nom DNS public (`monapp-123456789.eu-west-1.elb.amazonaws.com`) mais pas d'adresse IP fixe garantie. Tu veux que `app.monsite.fr` pointe vers cet ALB. Quel enregistrement utilises-tu ?

A) Un enregistrement CNAME, car il permet de faire pointer un nom de domaine vers un autre nom de domaine (le nom DNS de l'ALB).

B) Un enregistrement A, car il faut toujours renseigner une adresse IP, même si elle risque de changer.

C) Un enregistrement NS, car l'ALB fait autorité sur la zone DNS du sous-domaine.

D) Un enregistrement MX, car l'ALB utilise le protocole SMTP pour router le trafic.

**Réponse : A** — Un Application Load Balancer (ALB) AWS expose un nom DNS public mais n'a pas d'adresse IP fixe garantie. Pour pointer `app.monsite.fr` vers cet ALB, on utilise un CNAME : `app.monsite.fr CNAME monapp-123456789.eu-west-1.elb.amazonaws.com`.**

> ❌ B — Un A pointe vers une IP ; or l'ALB peut changer d'IP à tout moment (scale-in/out). Un A deviendrait obsolète sans préavis.
> ❌ C — Les enregistrements NS servent à déléguer une zone entière, pas à pointer un sous-domaine vers une ressource.
> ❌ D — MX est réservé à la messagerie (SMTP), pas au routage de trafic web.
> 💡 **Lien avec AWS** : C'est la raison pour laquelle AWS fournit un nom DNS pour l'ALB plutôt qu'une IP. Pour l'apex (`monsite.fr`), où un CNAME est interdit, on utilise un alias Route 53 (ALIAS record) — une extension propriétaire AWS.

---

### Question 22

**Question 22.** Tu exécutes `dig exemple.fr NS` et tu obtiens `ns1.dns-hebergeur.com`, `ns2.dns-hebergeur.com`. Que représentent ces serveurs listés ?

A) Ce sont les serveurs de messagerie qui reçoivent et traitent les emails pour `exemple.fr`.

B) Ce sont les serveurs racine du DNS qui gèrent l'intégralité du TLD `.fr`.

C) Ce sont les résolveurs récursifs que les clients finaux utilisent pour naviguer sur Internet.

D) Ce sont les serveurs de noms (name servers) autoritaires : ils détiennent la version officielle de la zone DNS `exemple.fr`. Toute modification d'enregistrement doit être faite via ces serveurs.

**Réponse : D** — `dig exemple.fr NS` retourne la liste des serveurs de noms (name servers) autoritaires du domaine. Ces serveurs détiennent la version officielle de la zone DNS `exemple.fr`. Toute modification (ajout, suppression d'enregistrement) doit être faite sur ces serveurs, généralement via le registrar ou l'hébergeur DNS.**

> ❌ A — Les serveurs de messagerie sont listés par `dig MX`, pas par `dig NS`.
> ❌ B — Les serveurs racine gèrent le `.` (la racine), pas un TLD spécifique comme `.fr`.
> ❌ C — Les résolveurs récursifs sont les serveurs que les clients interrogent pour naviguer (ex. `8.8.8.8`), pas les serveurs qui font autorité sur une zone.
> 💡 **Piège classique** : Ne pas confondre serveur autoritaire (qui détient la zone) et résolveur récursif (qui interroge pour le compte du client). Un serveur peut être les deux, mais les rôles sont conceptuellement distincts.

---

### Question 23

**Question 23.** Un collègue crée un CNAME à la racine du domaine : `monsite.fr CNAME www.monsite.fr`. Pourquoi est-ce une erreur ?

A) Un enregistrement CNAME ne fonctionne qu'avec le protocole IPv6, pas avec IPv4.

B) Un CNAME ne peut pas coexister avec les enregistrements obligatoires présents à la racine (SOA et NS). La RFC l'interdit et cela peut casser la résolution DNS de tout le domaine.

C) Un CNAME ne peut pointer que vers une adresse IP, jamais vers un autre nom de domaine.

D) Les CNAME sont techniquement interdits pour les domaines en `.fr`.

**Réponse : B** — Un domaine nu (apex) comme `monsite.fr` possède obligatoirement un enregistrement SOA et des enregistrements NS. La RFC 1912 interdit de placer un CNAME à l'apex car un CNAME ne peut pas coexister avec d'autres enregistrements sur le même nœud. Cela peut casser complètement la résolution DNS du domaine.**

> ❌ A — Un CNAME fonctionne parfaitement avec les deux protocoles, IPv4 et IPv6.
> ❌ C — Au contraire : un CNAME pointe toujours vers un nom de domaine, jamais vers une adresse IP.
> ❌ D — Aucune restriction géographique ou de TLD n'existe sur l'usage des CNAME.
> 💡 **Lien avec AWS** : Route 53 contourne cette limitation avec les enregistrements ALIAS (extension propriétaire) qui permettent de pointer l'apex vers un ALB, un CloudFront ou un bucket S3 sans violer la RFC.

---

### Question 24

**Question 24.** Tu crées une nouvelle zone DNS hébergée (hosted zone) `monsite.fr` sur AWS Route 53. Dès la création, quel(s) enregistrement(s) est/sont automatiquement présents avant même que tu n'ajoutes quoi que ce soit ?

A) Un enregistrement A pointant vers l'adresse IP par défaut fournie par AWS.

B) Un enregistrement MX préconfiguré pour recevoir les emails sur le domaine.

C) Un enregistrement SOA (Start of Authority) contenant le numéro de série initial, et des enregistrements NS listant les serveurs de noms délégués par Route 53.

D) Un enregistrement CNAME redirigeant automatiquement le domaine nu vers le sous-domaine `www`.

**Réponse : C** — Dès la création d'une hosted zone sur Route 53, AWS génère automatiquement deux types d'enregistrements obligatoires : un enregistrement SOA (avec le numéro de série initial, les timers refresh/retry/expire et le TTL minimum) et quatre enregistrements NS (les serveurs de noms délégués par AWS pour cette zone). Aucun autre enregistrement n'est créé automatiquement.**

> ❌ A — Aucun enregistrement A n'est créé automatiquement : AWS ne connaît pas l'IP de ton site web.
> ❌ B — Aucun MX n'est créé automatiquement ; la messagerie nécessite une configuration explicite.
> ❌ D — Aucun CNAME vers `www` n'est créé automatiquement à la création de la zone.
> 💡 **Lien avec AWS** : Les 4 serveurs NS fournis par Route 53 sont ceux que tu dois reporter chez ton registrar pour déléguer la zone. Sans cette délégation, ta zone Route 53 ne sera jamais interrogée.

---

### Question 25

**Question 25.** Le bail DHCP (lease) de ton instance EC2 arrive à expiration dans un VPC AWS. Que se passe-t-il concrètement ?

A) Le service DHCP intégré au VPC AWS renouvelle automatiquement le bail. L'instance conserve la même adresse IP privée sans interruption ni redémarrage — c'est totalement transparent.

B) L'instance reçoit une adresse APIPA (`169.254.x.x`) en attendant que le bail soit renouvelé manuellement par l'administrateur.

C) L'instance EC2 est automatiquement arrêtée (stopped) par AWS car elle n'a plus d'adresse IP valide.

D) L'instance redémarre automatiquement pour demander un nouveau bail avec une nouvelle adresse IP.

**Réponse : A** — Le service DHCP intégré au VPC AWS gère le renouvellement des baux de manière totalement automatique et transparente. L'instance EC2 conserve la même adresse IP privée sans interruption, sans redémarrage, et sans aucune intervention de l'administrateur.**

> ❌ B — Une instance EC2 dans un VPC ne tombe jamais en APIPA suite à une expiration de bail normale.
> ❌ C — AWS n'arrête pas une instance pour une simple expiration de bail DHCP.
> ❌ D — L'instance ne redémarre pas ; le renouvellement se fait à chaud, sans coupure réseau.
> 💡 **Lien avec AWS** : L'adresse IP privée attribuée au premier démarrage est conservée pendant toute la durée de vie de l'instance. Elle ne change qu'à la terminaison ou si l'instance est déplacée vers un autre sous-réseau.

---

## Tableau récapitulatif

| Q | Rép. | Q | Rép. | Q | Rép. |
|---|------|---|------|---|------|
| 1 | D | 10 | D | 19 | B |
| 2 | B | 11 | C | 20 | C |
| 3 | A | 12 | B | 21 | A |
| 4 | C | 13 | A | 22 | D |
| 5 | D | 14 | D | 23 | B |
| 6 | A | 15 | B | 24 | C |
| 7 | B | 16 | C | 25 | A |
| 8 | C | 17 | D | | |
| 9 | A | 18 | A | | |
