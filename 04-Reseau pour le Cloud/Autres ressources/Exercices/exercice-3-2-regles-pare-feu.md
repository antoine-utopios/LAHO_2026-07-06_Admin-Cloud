# Exercice 3-2 — Écrire des règles de pare-feu pour la VM StockLine

> Module : 04 — CL-RÉSEAU — Réseaux pour le cloud (Jour 3)
> Durée estimée : 40 min
> Difficulté : 3 / 5
> Type : Exercice d'application — rédaction de règles + lecture, puis test sur la VM

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Rédiger une politique ufw complète en « défaut fermé », dans un ordre qui ne coupe pas votre propre accès.
- Justifier chaque règle par le triplet « qui, vers quoi, pourquoi ».
- Écrire les règles aller **et** retour d'un flux sur un pare-feu stateless, et mesurer ce que le stateful vous épargne.
- Traduire en français des règles iptables existantes.

## Prérequis

- Avoir suivi la partie « Pare-feu » du module 04 (jour 3).
- Environnement : papier/éditeur pour les parties 1-3 ; VM Ubuntu (snapshot recommandé) pour la partie 4.
- Outils : `ufw`, `ss`, `curl`.

## Contexte

C'est la configuration exacte que vous devrez produire au **TP1** (et l'ancêtre direct de vos security groups du TP2). La VM StockLine héberge :

| Service | Port | Exposition voulue |
|---|---|---|
| nginx (reverse proxy) | 80/tcp et 443/tcp | tout Internet |
| API FastAPI (uvicorn) | 8000/tcp | **uniquement local** (nginx la proxifie) |
| PostgreSQL | 5432/tcp | **uniquement local** |
| SSH | 22/tcp | uniquement le poste d'admin `203.0.113.50` |

Tout le reste doit être refusé en entrée. Les connexions sortantes de la VM (apt, dig…) restent libres.

## Énoncé

### Partie 1 — La politique ufw complète

**Question 1.** Écrivez la suite **ordonnée** de commandes `ufw` qui met en place cette politique, en terminant par l'activation. Une erreur d'ordre qui vous enfermerait dehors est éliminatoire (comme au TP1 !).

**Question 2.** Pour chaque règle, une ligne de justification au format : « autorise [qui] vers [port/service] parce que [raison] ».

**Question 3.** Faut-il une règle ufw pour que nginx (port 443 public) puisse transmettre les requêtes à l'API sur `127.0.0.1:8000` ? Pourquoi ?

**Question 4.** Un collègue propose `sudo ufw allow 5432/tcp` « pour que le client PostgreSQL de son poste fonctionne ». Refusez en deux arguments, et proposez-lui la bonne solution (vue en CL-LINUX J4).

### Partie 2 — La même chose en stateless

**Question 5.** Sur un pare-feu **stateless** (imaginez une NACL), écrivez les règles nécessaires pour le **seul** flux « client Internet → HTTPS de la VM », dans un tableau :

`sens | protocole | IP source | port source | IP dest | port dest | action`

Il faut exactement deux règles : l'aller **et** le retour. Précisez pourquoi le port source du retour et le port destination de l'aller diffèrent des ports « éphémères » de l'autre extrémité.

**Question 6.** Combien de règles stateless faudrait-il au total pour couvrir les 3 flux entrants autorisés (80, 443, SSH restreint) ? Que conclure sur l'intérêt du stateful ?

### Partie 3 — Lire de l'iptables

**Question 7.** Traduisez chacune de ces règles en une phrase française précise :

```text
a) iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
b) iptables -A INPUT -p tcp -s 203.0.113.50 --dport 22 -j ACCEPT
c) iptables -A INPUT -p tcp --dport 8000 ! -i lo -j DROP
d) iptables -P INPUT DROP
```

**Question 8.** Dans quel ordre ces quatre règles doivent-elles être évaluées pour que la politique fonctionne ? Laquelle implémente le comportement « stateful » ?

### Partie 4 — Appliquer et prouver (sur la VM)

**Question 9.** Appliquez votre politique de la question 1 sur la VM (snapshot d'abord !). Prouvez ensuite, commandes et sorties à l'appui, que :

- `sudo ufw status verbose` reflète bien la politique ;
- le port 22 répond toujours (vous êtes encore connecté !) ;
- un port non autorisé (ex. 8000 depuis l'extérieur de la VM) ne répond pas.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — l'ordre qui sauve</summary>

Les défauts d'abord (`default deny incoming`, `default allow outgoing`), puis **la règle SSH avant tout le reste**, puis 80/443, et `enable` en dernier. ufw n'applique rien avant `enable` — c'est votre filet de sécurité.

</details>

<details>
<summary>Indice 2 — la règle avec source restreinte</summary>

La syntaxe complète est `ufw allow from <IP> to any port <port> proto tcp`. `ufw allow 22/tcp` ouvrirait à tout Internet.

</details>

<details>
<summary>Indice 3 — le retour stateless</summary>

Le client contacte le port 443 **depuis** un port éphémère (≈ 1024-65535). Le paquet de retour a donc pour source le port 443 de la VM et pour destination **le port éphémère du client** : la règle de retour doit autoriser `dport 1024-65535`.

</details>

## Pour aller plus loin (bonus)

**Bonus 1.** `sudo ufw limit 22/tcp` : que fait `limit` de plus que `allow`, et contre quel type d'attaque ?

**Bonus 2.** Récrivez la politique complète de la question 1 en syntaxe **nftables** (table `inet filter`, chaîne `input`) — en lecture commentée, sans l'appliquer.

**Bonus 3.** Traduisez votre politique en trois règles de security group AWS « entrantes » (port, protocole, source). Qu'est-ce qui disparaît par rapport à ufw, et pourquoi (pensez au défaut du SG) ?
