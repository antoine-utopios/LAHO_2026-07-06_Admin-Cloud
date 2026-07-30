# Solution — Exercice 2-2 : Diagnostiquer avec dig : cinq tickets DNS

## Approche pédagogique

La partie 1 ancre les réflexes de lecture ; la partie 2 est un entraînement au format professionnel « symptôme → hypothèse → preuve → correctif ». Noter la **démarche** autant que la cause trouvée : un diagnostic juste mais non argumenté vaut moins qu'un diagnostic argumenté.

## Solution détaillée

### Partie 1 — Manipulations réelles

**Question 1.** `resolvectl status` montre : le résolveur local (`127.0.0.53`, systemd-resolved) et le(s) serveur(s) amont sur la ligne `DNS Servers` (reçus par DHCP). Deux étages de cache possibles : local + amont.

**Question 2.** Le second `dig` montre un **TTL diminué** (~15 s de moins) et un `Query time` proche de 0 ms → la réponse vient **du cache**, qui décompte le TTL. Si le TTL est revenu à sa valeur nominale : le cache a expiré entre les deux — les deux observations sont exploitables.

**Question 3.** L'ANSWER SECTION contient une ligne `www.wikipedia.org. IN CNAME ...` suivie de la résolution A du nom cible : dig affiche **toute la chaîne** alias → adresse.

**Question 4.** Le nombre devant chaque MX est la **priorité** : plus petit = serveur préféré ; les valeurs plus grandes sont des secours.

**Question 5.** Oui, légitimement : caches distincts (TTL décalés), géo-DNS/CDN (réponse selon la localisation du résolveur), round robin. Deux réponses différentes ne signifient pas une panne.

### Partie 2 — Les cinq tickets

**Ticket A — NXDOMAIN sur wwww.**

1. **Lecture** : `status: NXDOMAIN` = ce nom **n'existe pas** ; la SOA de la zone en AUTHORITY confirme que la zone, elle, répond normalement.
2. **Cause** : faute de frappe — `wwww` (4 w) au lieu de `www`. Le DNS a parfaitement fonctionné : il a répondu « inconnu » à une question erronée.
3. **Correctif** : corriger le nom (côté client/lien/monitoring qui a généré la requête).
4. **Vérification** : `dig www.stockline-corp.example` → NOERROR avec un A.

Morale à faire verbaliser : *toujours relire le nom exactement demandé dans la QUESTION SECTION avant toute autre hypothèse.*

**Ticket B — migration et TTL.**

1. **Lecture** : le résolveur local répond l'**ancienne** IP (198.51.100.14) avec TTL **81523** en cours de décompte ; le serveur **autoritaire** (flag `aa`, TTL nominal 86400) répond déjà la **nouvelle** (203.0.113.80).
2. **Cause** : la zone est correcte, mais l'enregistrement avait un TTL de 86400 s (24 h) au moment de la migration : les caches du monde entier ont le droit de servir l'ancienne IP jusqu'à expiration. Ici il reste 81523 s ≈ **22 h 39** sur ce résolveur.
3. **Correctif immédiat** : aucun côté DNS (on ne purge pas les caches d'Internet) ; palliatif : maintenir l'ancien serveur en proxy vers le nouveau jusqu'à expiration. **Leçon** : plusieurs jours avant une migration, **baisser le TTL** (ex. 300 s), migrer, puis remonter le TTL.
4. **Vérification** : `dig @ns1... www...` = nouvelle IP (déjà OK) ; surveiller le TTL local décroître jusqu'à bascule.

**Ticket C — CNAME cassé.**

1. **Lecture** : la réponse contient le CNAME (`boutique → shop.ancien-hebergeur.example`) mais le statut global est **NXDOMAIN** et l'AUTHORITY renvoie la SOA d'`ancien-hebergeur.example` : c'est la **cible du CNAME** qui n'existe plus, pas le nom demandé.
2. **Cause** : alias pointant vers un nom supprimé chez l'ancien hébergeur (résiliation, ménage de zone).
3. **Correctif** : mettre à jour l'enregistrement `boutique` — CNAME vers le nouveau nom d'hébergement, ou enregistrement A direct.
4. **Vérification** : `dig boutique.stockline-corp.example` → NOERROR, chaîne complète CNAME → A.

**Ticket D — SERVFAIL pour une seule machine.**

1. **Lecture** : même question, deux réponses : Léa obtient `SERVFAIL` de **10.3.3.53** ; le serveur de build obtient NOERROR de **10.3.3.10**. La ligne `SERVER:` diffère : elles n'interrogent pas le même résolveur.
2. **Cause** : le résolveur configuré sur le poste de Léa (10.3.3.53) est en panne ou défaillant (service arrêté, forwarder cassé, filtrage). La zone et le réseau vont bien — preuve : le build.
3. **Correctif** : depuis le poste de Léa, confirmer avec `dig @10.3.3.10 stockline-corp.example` (si NOERROR : le problème est bien 10.3.3.53) ; corriger la configuration DNS du poste (DHCP/`resolvectl`) ou réparer 10.3.3.53.
4. **Vérification** : `resolvectl status` sur le poste + `dig` sans `@` → NOERROR.

**Ticket E — délégation incohérente.**

1. **Lecture** : la délégation NS liste **un serveur de l'ancien prestataire et un du nouveau** ; interrogés directement, ils répondent des données **différentes** (ancienne vs nouvelle IP). Un résolveur choisit l'un des NS déclarés au hasard → « une fois sur deux ».
2. **Cause** : migration de prestataire DNS inachevée : la délégation (chez le registrar) n'a pas été mise à jour de façon cohérente, et l'ancienne zone n'est plus maintenue mais répond toujours.
3. **Correctif** : chez le **registrar**, faire pointer la délégation uniquement vers les NS du nouveau prestataire (ns1/ns2.nouveau-presta) ; puis décommissionner la zone chez l'ancien.
4. **Vérification** : `dig stockline-corp.example NS +short` (via résolveur **et** `+trace`) ne liste plus que le nouveau ; réponses identiques depuis tous les NS.

## Variantes acceptables

1. **Ticket B — palliatif « changer les /etc/hosts des clients »** : acceptable comme dépannage ultra-ciblé (postes internes), à requalifier : ça ne règle rien pour le public.
2. **Ticket D — hypothèse « pare-feu bloque le port 53 du poste »** : recevable si l'apprenant propose le test qui départage (`dig @10.3.3.10` depuis le poste : s'il répond, le port 53 sortant n'est pas bloqué globalement).

## Bonus

**Bonus 1 — plan de migration DNS :**

```text
J-7  : TTL de www abaissé de 86400 à 300 (attendre 24 h que l'ancien TTL expire partout)
J-1  : vérifier le nouveau serveur en direct (curl --resolve www...:443:203.0.113.80 https://www...)
J    : changer l'enregistrement A -> 203.0.113.80 ; bascule effective en <= 300 s
J    : surveiller (dig, logs des deux serveurs), garder l'ancien serveur en proxy 24 h
J+7  : remonter le TTL à 86400
```

**Bonus 2.** Dans `+trace` : bloc 1 = NS de la racine (`.`), bloc 2 = enregistrements **NS du TLD** fournis par la racine, bloc 3 = **NS du domaine** fournis par le TLD, bloc final = la réponse A par l'autoritaire. Chaque remise de relais = une ligne NS : la délégation matérialisée.

**Bonus 3.** La résolution inverse interroge `8.8.8.8.in-addr.arpa` et renvoie un enregistrement **PTR** (`dns.google.`) : IP → nom. Utile pour les logs, l'anti-spam ; jamais garanti cohérent avec le sens direct.
