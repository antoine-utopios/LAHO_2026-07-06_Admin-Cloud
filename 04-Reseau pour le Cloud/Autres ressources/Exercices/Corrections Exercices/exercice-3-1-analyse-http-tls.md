# Solution — Exercice 3-1 : Analyser un échange HTTP/TLS complet

## Approche pédagogique

L'exercice transforme la sortie `curl -v` — que beaucoup subissent — en document structuré : trois phases, un certificat, un dialogue. Objectif : que chaque apprenant sache dire « où on en est » à n'importe quelle ligne d'une trace. Les questions 5, 6 et 10 sont les plus discriminantes.

## Solution détaillée

### Partie 1 — Les phases

**Question 1.**

| Phase | Lignes |
|---|---|
| Résolution DNS | L01-L02 |
| Connexion TCP | L03-L04 |
| Handshake TLS | L05-L18 (L05 : annonce ALPN incluse dans le ClientHello) |
| Échange HTTP | L19/L20-L32 |

Entre L03 (« Trying ») et L04 (« Connected ») s'est déroulé, invisible, le **handshake TCP SYN / SYN-ACK / ACK**. curl ne montre que son résultat.

**Question 2.** **ALPN** (Application-Layer Protocol Negotiation) : le client annonce dans le **ClientHello** les protocoles applicatifs qu'il sait parler (`h2,http/1.1`, L05) ; le serveur choisit dans sa réponse (`server accepted h2`, L11). La négociation a donc lieu **pendant le handshake TLS**, avant tout octet HTTP — d'où L19 « using HTTP/2 » et la requête `GET /produits HTTP/2` (L20).

### Partie 2 — Le certificat

**Question 3.** **TLS 1.3** — visible en L06/L07 (`TLSv1.3 (OUT/IN)`) et en L10 (`SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384`).

**Question 4.** Émetteur : **Let's Encrypt** (issuer `O=Let's Encrypt; CN=R11`, L17 — R11 est une CA intermédiaire). Validité : du 2 juin au 31 août 2026 = **90 jours**. Cette durée courte est la signature de Let's Encrypt : elle n'est tenable qu'avec un **renouvellement automatisé** (protocole ACME/certbot) — personne ne renouvelle à la main tous les 3 mois.

**Question 5.** L16 vérifie que le **nom demandé** par le client figure dans le **SAN** (Subject Alternative Names) du certificat. Si le client demandait `stockline-corp.example` et que le SAN ne contient que `www.stockline-corp.example` : échec de la vérification de nom (« hostname mismatch »), curl abandonne **avant toute requête HTTP** avec une erreur du type `SSL: no alternative certificate subject name matches target host name`. Correctif type : certificat avec les deux noms dans le SAN.

**Question 6.** L18 (`SSL certificate verify ok`) résume la validation du certificat : (1) la **chaîne** remonte jusqu'à une CA racine du magasin de confiance (via l'intermédiaire R11), (2) les **dates** de validité encadrent l'instant présent, (3) le **nom** demandé correspond au SAN (vérification détaillée en L16). Les trois doivent passer ; une seule qui échoue = connexion refusée.

### Partie 3 — Le dialogue HTTP

**Question 7.** Méthode **GET**, chemin **/produits**, protocole HTTP/2 → réponse **301** (redirection permanente). Le serveur demande au client de refaire sa requête vers **`/produits/`** (slash final), via l'en-tête **`location`** (L25). Comportement typique de nginx sur un répertoire/route.

**Question 8.** Code **200**, `content-type: application/json` → c'est l'endpoint **`GET /produits`** de l'API StockLine (CL-PYTHON) : la liste des produits en JSON, servie derrière nginx.

**Question 9.**

- **`HttpOnly`** : le cookie est inaccessible au JavaScript de la page → un script injecté (XSS) ne peut pas le voler.
- **`Secure`** : le cookie n'est envoyé que sur HTTPS → jamais en clair sur le réseau.
- **`SameSite=Lax`** : le cookie n'accompagne pas la plupart des requêtes initiées depuis d'autres sites → atténue les attaques CSRF (détail en CL-SECU).

**Question 10.** Le 301 est une **réponse HTTP**, construite après lecture de la **requête HTTP**.

- Un LB **L4** ne voit que des segments TCP chiffrés (il ne termine pas le TLS) : il ne peut ni lire la requête ni fabriquer une réponse → **non**.
- Un LB **L7** termine le TLS, lit `GET /produits`, et peut répondre lui-même un 301 (les ALB AWS ont une action « redirect » exactement pour ça) → **oui**.

### Partie 4 — Vérifications sur la VM

**Question 11.** Réponses dépendantes du site au jour J — attendu (exemple utopios.net) : TLS 1.3, issuer Let's Encrypt (ou autre CA publique), dates ~90 jours si Let's Encrypt, éventuel 301 http→https puis 200. Valider la **méthode de lecture**, pas des valeurs figées.

**Question 12.** Ligne attendue : `curl: (60) SSL certificate problem: certificate has expired`. C'est la vérification **des dates** (question 6, point 2) qui échoue : `notAfter` est dépassé. Correctif côté serveur : renouveler le certificat — et surtout réparer l'automatisation qui a permis l'expiration (`certbot renew` en timer systemd + supervision de l'échéance).

## Variantes acceptables

1. **Q1 : placer L05 dans la phase TCP** — discutable mais défendable (curl l'affiche avant le ClientHello) ; l'important est que l'apprenant sache que l'ALPN se **négocie** dans le TLS.
2. **Q6 : citer la révocation (OCSP/CRL)** comme quatrième vérification : bonus, pas exigé.
3. **Q10 : « un L4 peut rediriger au niveau TCP »** — non : il peut *réorienter des connexions* vers un autre backend, mais pas émettre un 301 ; si l'apprenant fait cette distinction proprement, valoriser.

## Bonus

**Bonus 1.** Dans la sortie `x509 -text` : le SAN est dans `X509v3 extensions → Subject Alternative Name` ; l'issuer en tête (`Issuer:`). Faire remarquer `Public Key` et `Signature` : la matière première de la chaîne de confiance.

**Bonus 2.** `--http1.1` force curl à ne proposer que `http/1.1` en ALPN : L19-L20 deviennent `using HTTP/1.1` et `GET / HTTP/1.1`. Le contenu de la réponse est identique — la sémantique HTTP ne change pas, seul le transport.

**Bonus 3.** `--resolve nom:port:IP` court-circuite le DNS : curl se connecte à l'IP donnée **tout en présentant le bon SNI et le bon Host**. On teste ainsi le nouveau serveur (certificat compris) **avant** de changer l'enregistrement A — exactement ce qui aurait dû être fait à J-1 dans le ticket B de l'exercice 2-2.
