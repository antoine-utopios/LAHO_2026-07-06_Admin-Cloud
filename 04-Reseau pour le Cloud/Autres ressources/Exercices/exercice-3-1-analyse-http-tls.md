# Exercice 3-1 — Analyser un échange HTTP/TLS complet

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 3)
> Durée estimée : 40 min
> Difficulté : 3 / 5
> Type : Exercice d'application — analyse sur dossier + vérifications sur la VM

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Découper une sortie `curl -v` en ses trois phases : TCP, TLS, HTTP.
- Extraire d'un handshake TLS : la version, l'émetteur du certificat, les noms couverts (SAN), les dates de validité.
- Lire une requête et une réponse HTTP : méthode, chemin, code, en-têtes significatifs (redirection, cookie, type de contenu).
- Diagnostiquer une erreur de certificat à partir du message de curl.

## Prérequis

- Avoir suivi les parties « HTTP » et « TLS » du module 04 (jour 3) et la démo 3-1.
- Environnement : papier/éditeur pour la partie 1, VM Ubuntu avec Internet pour la partie 3.
- Outils : `curl`, `openssl`.

## Contexte

Vous auditez l'accès au site de **StockLine Corp** (domaine fictif, adresses de documentation). On vous fournit la trace `curl -v` complète d'un client qui demande `https://www.stockline-corp.example/produits`. Les numéros de lignes `[Lxx]` servent uniquement à vos réponses.

```text
[L01] * Host www.stockline-corp.example:443 was resolved.
[L02] * IPv4: 203.0.113.80
[L03] *   Trying 203.0.113.80:443...
[L04] * Connected to www.stockline-corp.example (203.0.113.80) port 443
[L05] * ALPN: curl offers h2,http/1.1
[L06] * TLSv1.3 (OUT), TLS handshake, Client hello (1):
[L07] * TLSv1.3 (IN), TLS handshake, Server hello (2):
[L08] * TLSv1.3 (IN), TLS handshake, Certificate (11):
[L09] * TLSv1.3 (IN), TLS handshake, Finished (20):
[L10] * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
[L11] * ALPN: server accepted h2
[L12] * Server certificate:
[L13] *  subject: CN=www.stockline-corp.example
[L14] *  start date: Jun  2 09:14:11 2026 GMT
[L15] *  expire date: Aug 31 09:14:10 2026 GMT
[L16] *  subjectAltName: host "www.stockline-corp.example" matched cert's "www.stockline-corp.example"
[L17] *  issuer: C=US; O=Let's Encrypt; CN=R11
[L18] *  SSL certificate verify ok.
[L19] * using HTTP/2
[L20] > GET /produits HTTP/2
[L21] > Host: www.stockline-corp.example
[L22] > User-Agent: curl/8.5.0
[L23] > Accept: */*
[L24] < HTTP/2 301
[L25] < location: https://www.stockline-corp.example/produits/
[L26] < server: nginx
[L27] < HTTP/2 200
[L28] < content-type: application/json
[L29] < set-cookie: session=9f3ab2; Path=/; HttpOnly; Secure; SameSite=Lax
[L30] < content-length: 182
[L31] <
[L32] [{"id": 1, "nom": "Clavier mécanique", "stock": 42}, ...]
```

(Note : curl a suivi la redirection car l'option `-L` était active ; les lignes L27+ correspondent à la seconde requête, vers `/produits/`.)

## Énoncé

### Partie 1 — Découper les phases

**Question 1.** Donnez les plages de lignes correspondant à chacune des phases : résolution DNS, connexion TCP, handshake TLS, échange HTTP. Quelle phase invisible s'est produite entre L03 et L04 ?

**Question 2.** L05 et L11 parlent d'ALPN. En vous appuyant sur L19-L20, expliquez ce qui s'est négocié et pendant quelle phase.

### Partie 2 — Le certificat

**Question 3.** Quelle version de TLS est utilisée ? Où le voyez-vous (deux lignes possibles) ?

**Question 4.** Qui a émis le certificat ? Quelle est sa durée de validité totale, et qu'est-ce que cette durée suggère sur la CA et le mode de renouvellement ?

**Question 5.** Que vérifie exactement la ligne L16, et que se passerait-il si le client avait demandé `stockline-corp.example` (sans `www`) alors que le SAN ne contient que `www.stockline-corp.example` ?

**Question 6.** Que signifie L18 ? Citez les trois vérifications qu'elle résume.

### Partie 3 — Le dialogue HTTP

**Question 7.** Première requête (L20-L26) : méthode, chemin, code de réponse ? Que demande le serveur au client, et par quel en-tête ?

**Question 8.** Seconde réponse (L27-L32) : code, type de contenu ? Reliez ce contenu à ce que vous connaissez de l'API StockLine.

**Question 9.** Analysez le cookie de L29 : que garantit chacun des attributs `HttpOnly`, `Secure`, `SameSite=Lax` ?

**Question 10.** Un load balancer L4 placé devant ce serveur pourrait-il effectuer la redirection de L24-L25 à la place du serveur ? Et un L7 ? Justifiez.

### Partie 4 — Vérifications sur la VM

**Question 11.** Reproduisez l'analyse sur un site réel : `curl -vL https://utopios.net -o /dev/null 2>&1 | less`. Retrouvez et notez : version TLS, émetteur, dates, code(s) HTTP.

**Question 12.** `curl -v https://expired.badssl.com/ -o /dev/null` : recopiez la ligne d'erreur, identifiez la vérification de la question 6 qui a échoué, et proposez le correctif côté serveur.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — les phases</summary>

L'ordre est toujours : DNS → TCP (le handshake SYN/SYN-ACK/ACK se cache dans « Trying… / Connected ») → TLS (« Client hello » → « verify ok ») → HTTP (les lignes `>` et `<`). Rien de HTTP ne circule avant la fin du TLS.

</details>

<details>
<summary>Indice 2 — la redirection</summary>

Un 301 sans corps utile + un en-tête `location` = « va voir là-bas ». Comparez les chemins `/produits` et `/produits/` : c'est la redirection « slash final » classique de nginx.

</details>

<details>
<summary>Indice 3 — question 10</summary>

Pour rédiger une réponse HTTP (le 301), il faut… lire la requête HTTP. Qui, du L4 et du L7, voit le HTTP en clair ? Repensez à la terminaison TLS.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** Sur la VM : `openssl s_client -connect utopios.net:443 -servername utopios.net </dev/null 2>/dev/null | openssl x509 -noout -text | less` — retrouvez le SAN et l'issuer dans la sortie brute du certificat.

**Bonus 2.** Que change l'option `--http1.1` de curl dans les lignes L19-L20 ? Testez sur un site réel et comparez.

**Bonus 3.** À l'aide de `curl -v --resolve www.stockline-corp.example:443:203.0.113.80 ...` (syntaxe à expliquer), comment testeriez-vous un serveur **avant** de basculer le DNS vers lui ? Reliez cette technique au ticket B de l'exercice 2-2.
