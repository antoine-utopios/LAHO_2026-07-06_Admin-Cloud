# QCM — Jour 2, pages 16 à 35 : DHCP et DNS

> **Niveau 1** (questions 1 à 8) : Comprendre les notions
> **Niveau 2** (questions 9 à 16) : Appliquer sur des cas simples
> **Niveau 3** (questions 17 à 25) : Retrouver les notions dans des situations cloud

---

## Niveau 1 — Comprendre les notions (questions 1 à 8)

---

**Question 1.** Dans le cycle DORA (Discover, Offer, Request, Acknowledge) de DHCP, que fait le client pendant la première étape « Discover » ?

A) Il envoie une requête directe à l'adresse IP du serveur DHCP qu'il a mémorisée lors d'une connexion précédente.

B) Il télécharge depuis Internet la liste des serveurs DHCP disponibles sur le réseau local.

C) Il attend qu'un serveur DHCP le contacte spontanément pour lui proposer une adresse.

D) Il diffuse un message en broadcast (vers `255.255.255.255`) sur le réseau local pour demander « Y a-t-il un serveur DHCP ici ? ».

---

**Question 2.** Dans la hiérarchie DNS, quel est l'ordre de résolution d'un nom de domaine, du plus haut niveau jusqu'au plus précis ?

A) Serveur TLD → Serveur autoritaire → Serveur racine

B) Serveur racine → Serveur TLD → Serveur autoritaire

C) Serveur autoritaire → Serveur racine → Serveur TLD

D) Serveur TLD → Serveur racine → Serveur autoritaire

---

**Question 3.** Un enregistrement DNS de type A (Address) contient quoi exactement ?

A) Une correspondance entre un nom de domaine (ex. `www.exemple.fr`) et une adresse IPv4 (ex. `93.184.216.34`).

B) Un alias qui redirige un nom de domaine vers un autre nom de domaine.

C) Le nom du serveur de messagerie qui reçoit les emails du domaine.

D) Une chaîne de texte libre utilisée pour la vérification de propriété du domaine.

---

**Question 4.** Une machine Linux affiche l'adresse IP `169.254.12.77` avec la commande `ip addr`. Que signifie cette adresse ?

A) C'est une adresse IP publique attribuée par le fournisseur d'accès à Internet (FAI).

B) C'est l'adresse de loopback utilisée exclusivement pour tester la pile réseau locale.

C) La machine n'a pas trouvé de serveur DHCP. Elle s'est auto-attribué une adresse APIPA (Automatic Private IP Addressing). Elle peut communiquer sur le réseau local uniquement, sans accès à Internet.

D) Le serveur DHCP a volontairement attribué cette adresse car elle fait partie d'une plage privée standard (RFC 1918).

---

**Question 5.** Dans le cycle DORA, que se passe-t-il pendant l'étape « Offer » ?

A) Le client déclare officiellement qu'il accepte l'adresse IP proposée.

B) Le routeur du réseau accuse réception du message Discover envoyé par le client.

C) Le serveur DHCP libère une adresse IP qui était déjà attribuée à un autre client.

D) Le serveur DHCP répond au client avec une proposition contenant : une adresse IP, la durée du bail (lease), le masque de sous-réseau, la passerelle par défaut (default gateway) et les serveurs DNS.

---

**Question 6.** Un enregistrement CNAME (Canonical Name) sert à quoi ?

A) Créer un alias : faire pointer un nom de domaine vers un autre nom de domaine (ex. `www.exemple.fr CNAME exemple.fr`).

B) Associer directement un nom de domaine à une adresse IPv4.

C) Déclarer les serveurs de noms (name servers) qui font autorité sur la zone DNS.

D) Stocker le numéro de série (serial) de la zone pour permettre la synchronisation entre serveurs DNS.

---

**Question 7.** Qu'est-ce que le bail DHCP (lease) ?

A) Un fichier de configuration qui liste les adresses MAC des machines autorisées sur le réseau.

B) La durée pendant laquelle l'adresse IP est attribuée au client. À expiration, le client doit renouveler ou libérer l'adresse.

C) Le nom du réseau Wi-Fi (SSID) diffusé par le point d'accès.

D) Une copie de sauvegarde automatique de la configuration du serveur DHCP.

---

**Question 8.** Quel est le rôle d'un résolveur DNS récursif (recursive resolver) ?

A) Héberger les zones DNS de tous les domaines enregistrés dans le monde.

B) Traduire les adresses IP en adresses MAC pour la communication sur le réseau local.

C) Parcourir la hiérarchie DNS — racine, TLD, autoritaire — à la place du client et lui retourner uniquement la réponse finale.

D) Générer et attribuer les adresses IP aux machines qui se connectent au réseau.

---

## Niveau 2 — Appliquer sur des cas simples (questions 9 à 16)

---

**Question 9.** Un client DHCP reçoit un bail de 8 heures. Au bout de combien de temps tente-t-il de renouveler ce bail pour la première fois ?

A) Au bout de 4 heures, soit à 50 % de la durée du bail (timer T1).

B) Au bout de 30 minutes, quel que soit le bail attribué.

C) Au bout de 7 heures, soit à 87,5 % de la durée du bail (timer T2).

D) À la dernière minute de la 8ᵉ heure, juste avant l'expiration du bail.

---

**Question 10.** Le champ TTL (Time To Live) d'un enregistrement DNS indique :

A) Le nombre maximal de sauts (hops) qu'un paquet IP peut traverser avant d'être détruit.

B) La date d'expiration du nom de domaine chez le bureau d'enregistrement (registrar).

C) Le délai avant qu'une adresse IP attribuée par DHCP soit automatiquement libérée.

D) La durée, en secondes, pendant laquelle un résolveur DNS peut conserver l'enregistrement dans son cache avant de le redemander au serveur autoritaire.

---

**Question 11.** L'enregistrement SOA (Start of Authority) d'une zone DNS contient notamment :

A) La liste de toutes les adresses IPv4 et IPv6 associées au domaine.

B) Les règles de redirection HTTP (codes 301/302) configurées pour le site web.

C) Le numéro de série (serial) de la zone, qui permet aux serveurs DNS secondaires de détecter qu'une mise à jour a eu lieu.

D) Le nom public et l'adresse postale du propriétaire du domaine.

---

**Question 12.** On entend souvent qu'« il faut 24 à 48 heures pour qu'un changement DNS se propage ». Pourquoi cette idée de « propagation » est-elle trompeuse ?

A) Parce que les modifications DNS sont toujours instantanées sur tous les serveurs du monde.

B) Parce qu'il n'y a pas de « push » d'un serveur à l'autre : chaque résolveur a son propre cache qui expire selon le TTL de l'enregistrement. Le délai vient de l'expiration progressive de tous ces caches.

C) Parce que le DNS est un système centralisé où un seul serveur détient toutes les données.

D) Parce que les changements DNS ne concernent que le réseau local et n'affectent pas Internet.

---

**Question 13.** Tu exécutes `dig exemple.fr MX` et tu obtiens des réponses avec des nombres comme `10 mail1.exemple.fr`, `20 mail2.exemple.fr`. Que signifient ces nombres ?

A) La priorité du serveur de messagerie : plus le nombre est petit, plus le serveur est prioritaire. L'expéditeur tente d'abord le serveur de priorité 10, puis 20 en cas d'échec.

B) Le port TCP sur lequel chaque serveur de messagerie écoute les connexions SMTP.

C) Le nombre de sauts réseau (hops) nécessaires pour atteindre chaque serveur de messagerie.

D) Le TTL en secondes avant que l'enregistrement MX ne soit automatiquement supprimé.

---

**Question 14.** Tu exécutes `dig +trace monsite.fr` sur une machine Linux. Que vois-tu apparaître dans la sortie ?

A) La liste de toutes les adresses MAC des équipements réseau traversés pendant la résolution.

B) Uniquement l'adresse IP finale de `monsite.fr`, sans les étapes intermédiaires.

C) Les logs de sécurité et d'authentification du serveur DNS de `monsite.fr`.

D) Le parcours complet de résolution : d'abord les serveurs racine, puis les serveurs TLD de `.fr`, puis les serveurs autoritaires de `monsite.fr`, qui donnent la réponse finale.

---

**Question 15.** Pour configurer des emails professionnels (Google Workspace ou Microsoft 365), le fournisseur te demande d'ajouter un enregistrement TXT contenant une chaîne comme `MS=ms12345678`. À quoi sert concrètement cet enregistrement TXT ?

A) À rediriger le trafic web du domaine vers le serveur de messagerie.

B) À prouver que tu es bien le propriétaire du domaine : le fournisseur vérifie la présence de la chaîne unique dans le DNS pour valider le domaine.

C) À accélérer la livraison des emails sortants vers les destinataires.

D) À attribuer une adresse IP publique fixe à ton serveur de messagerie.

---

**Question 16.** Tu exécutes `ip addr` sur une machine Linux et tu vois `inet 169.254.201.45/16`. Tu exécutes `ip route` et tu ne vois aucune passerelle par défaut (`default via`). Que conclus-tu ?

A) La carte réseau est physiquement défaillante et doit être remplacée immédiatement.

B) La machine est correctement configurée : `169.254.x.x` est une plage publique parfaitement routable sur Internet.

C) La machine n'a pas réussi à joindre de serveur DHCP. Elle a une adresse APIPA et ne peut communiquer qu'avec les machines du même segment réseau, également en APIPA. Aucun accès à Internet n'est possible.

D) Le serveur DHCP a délibérément attribué cette configuration pour isoler la machine d'Internet.

---

## Niveau 3 — Retrouver les notions dans des situations cloud (questions 17 à 25)

---

**Question 17.** Tu déploies une nouvelle instance EC2 dans un sous-réseau privé de ton VPC AWS. Par défaut, comment cette instance obtient-elle son adresse IP privée ?

A) L'instance démarre avec une adresse APIPA (`169.254.x.x`) que tu dois remplacer manuellement.

B) Tu dois obligatoirement te connecter en SSH et configurer une IP statique dans le fichier `/etc/netplan/`.

C) L'instance envoie une requête au service AWS Route 53 pour obtenir une adresse IP disponible.

D) Le service DHCP intégré à chaque VPC AWS lui attribue automatiquement une adresse IP dans la plage CIDR du sous-réseau, sans aucune intervention.

---

**Question 18.** Tu as déployé une application web sur une instance EC2 avec une IP élastique (Elastic IP) `3.120.45.10`. Tu veux que `www.monsite.fr` pointe vers cette IP. Quel type d'enregistrement DNS dois-tu créer ?

A) Un enregistrement A, car il fait la correspondance directe entre un nom de domaine et une adresse IPv4.

B) Un enregistrement CNAME, car toute résolution DNS doit obligatoirement passer par un alias intermédiaire.

C) Un enregistrement TXT, car il faut d'abord prouver la propriété du domaine avant de le faire pointer vers une IP.

D) Un enregistrement MX, car c'est le seul type d'enregistrement qui accepte une adresse IP publique.

---

**Question 19.** Un collègue modifie un enregistrement DNS et t'appelle deux minutes plus tard : « Ça ne marche pas, le changement n'apparaît pas chez moi ! » Tu vérifies sur le serveur autoritaire : la modification est bien enregistrée. Quelle est l'explication la plus probable ?

A) Le serveur autoritaire doit être redémarré manuellement pour que la modification prenne effet.

B) Le résolveur DNS de ton collègue (FAI, box, ou navigateur) a encore l'ancienne valeur en cache. Il doit attendre l'expiration du TTL ou vider son cache local (`ipconfig /flushdns` ou `sudo resolvectl flush-caches`).

C) Le registrar a automatiquement bloqué la modification pour des raisons de sécurité.

D) Les modifications DNS ne prennent effet que lors de la fenêtre de maintenance hebdomadaire, le dimanche à minuit UTC.

---

**Question 20.** Dans un VPC AWS, tu peux personnaliser les paramètres réseau distribués aux instances EC2 en utilisant un DHCP Option Set. Lequel de ces paramètres est configurable dans un DHCP Option Set AWS ?

A) La plage d'adresses IP (CIDR block) attribuée au sous-réseau.

B) Le type d'instance EC2 (`t3.micro`, `m5.large`) attribué par défaut aux nouvelles instances.

C) Les serveurs DNS (domain-name-servers) que les instances utiliseront pour la résolution de noms.

D) Le nombre maximal d'instances EC2 autorisées à se connecter simultanément au VPC.

---

**Question 21.** Tu déploies une application derrière un Application Load Balancer (ALB) AWS. L'ALB a un nom DNS public (`monapp-123456789.eu-west-1.elb.amazonaws.com`) mais pas d'adresse IP fixe garantie. Tu veux que `app.monsite.fr` pointe vers cet ALB. Quel enregistrement utilises-tu ?

A) Un enregistrement CNAME, car il permet de faire pointer un nom de domaine vers un autre nom de domaine (le nom DNS de l'ALB).

B) Un enregistrement A, car il faut toujours renseigner une adresse IP, même si elle risque de changer.

C) Un enregistrement NS, car l'ALB fait autorité sur la zone DNS du sous-domaine.

D) Un enregistrement MX, car l'ALB utilise le protocole SMTP pour router le trafic.

---

**Question 22.** Tu exécutes `dig exemple.fr NS` et tu obtiens `ns1.dns-hebergeur.com`, `ns2.dns-hebergeur.com`. Que représentent ces serveurs listés ?

A) Ce sont les serveurs de messagerie qui reçoivent et traitent les emails pour `exemple.fr`.

B) Ce sont les serveurs racine du DNS qui gèrent l'intégralité du TLD `.fr`.

C) Ce sont les résolveurs récursifs que les clients finaux utilisent pour naviguer sur Internet.

D) Ce sont les serveurs de noms (name servers) autoritaires : ils détiennent la version officielle de la zone DNS `exemple.fr`. Toute modification d'enregistrement doit être faite via ces serveurs.

---

**Question 23.** Un collègue crée un CNAME à la racine du domaine : `monsite.fr CNAME www.monsite.fr`. Pourquoi est-ce une erreur ?

A) Un enregistrement CNAME ne fonctionne qu'avec le protocole IPv6, pas avec IPv4.

B) Un CNAME ne peut pas coexister avec les enregistrements obligatoires présents à la racine (SOA et NS). La RFC l'interdit et cela peut casser la résolution DNS de tout le domaine.

C) Un CNAME ne peut pointer que vers une adresse IP, jamais vers un autre nom de domaine.

D) Les CNAME sont techniquement interdits pour les domaines en `.fr`.

---

**Question 24.** Tu crées une nouvelle zone DNS hébergée (hosted zone) `monsite.fr` sur AWS Route 53. Dès la création, quel(s) enregistrement(s) est/sont automatiquement présents avant même que tu n'ajoutes quoi que ce soit ?

A) Un enregistrement A pointant vers l'adresse IP par défaut fournie par AWS.

B) Un enregistrement MX préconfiguré pour recevoir les emails sur le domaine.

C) Un enregistrement SOA (Start of Authority) contenant le numéro de série initial, et des enregistrements NS listant les serveurs de noms délégués par Route 53.

D) Un enregistrement CNAME redirigeant automatiquement le domaine nu vers le sous-domaine `www`.

---

**Question 25.** Le bail DHCP (lease) de ton instance EC2 arrive à expiration dans un VPC AWS. Que se passe-t-il concrètement ?

A) Le service DHCP intégré au VPC AWS renouvelle automatiquement le bail. L'instance conserve la même adresse IP privée sans interruption ni redémarrage — c'est totalement transparent.

B) L'instance reçoit une adresse APIPA (`169.254.x.x`) en attendant que le bail soit renouvelé manuellement par l'administrateur.

C) L'instance EC2 est automatiquement arrêtée (stopped) par AWS car elle n'a plus d'adresse IP valide.

D) L'instance redémarre automatiquement pour demander un nouveau bail avec une nouvelle adresse IP.
