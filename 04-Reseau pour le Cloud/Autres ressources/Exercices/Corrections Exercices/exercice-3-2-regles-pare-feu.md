# Solution — Exercice 3-2 : Écrire des règles de pare-feu pour la VM StockLine

## Approche pédagogique

Cet exercice est le brouillon noté du TP1 (pare-feu de la VM) et l'ancêtre des security groups du TP2. Deux obsessions à transmettre : l'**ordre** des commandes (SSH avant enable) et la **justification** de chaque règle. La partie stateless (Q5-Q6) fait toucher du doigt ce que le stateful épargne — préparation directe de l'exercice 4-2.

## Solution détaillée

### Partie 1 — La politique ufw

**Question 1.** Suite ordonnée :

```bash
# 1. Les politiques par défaut (rien n'est actif tant que ufw est disabled)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 2. SSH restreint, EN PREMIER — c'est notre porte d'entrée
sudo ufw allow from 203.0.113.50 to any port 22 proto tcp

# 3. Le web public
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 4. Activation, en dernier
sudo ufw enable

# 5. Relecture
sudo ufw status verbose
```

Aucune règle pour 8000 ni 5432 : en « défaut fermé », **ne pas ouvrir suffit**.

**Question 2.** Justifications :

- `default deny incoming` : refuse **qui que ce soit** vers **tout port non ouvert** parce que la surface d'attaque doit être minimale (défaut fermé).
- `default allow outgoing` : autorise **la VM** vers **l'extérieur** parce que apt, DNS et les appels sortants doivent fonctionner (et ufw est stateful : les réponses reviendront).
- règle SSH : autorise **203.0.113.50 uniquement** vers **22/tcp** parce que seul le poste d'admin administre la machine.
- `allow 80/tcp` : autorise **tout Internet** vers **80** parce que nginx doit répondre en HTTP (ne serait-ce que pour rediriger vers HTTPS et pour le défi ACME HTTP-01).
- `allow 443/tcp` : autorise **tout Internet** vers **443** parce que c'est le service public de StockLine.

**Question 3.** **Non.** Le flux nginx → API passe par l'interface **loopback** (`127.0.0.1:8000`), que ufw autorise par défaut (règles implicites sur `lo`). Le port 8000 n'a besoin d'aucune règle — et c'est précisément ce qu'on veut : joignable localement, invisible de l'extérieur.

**Question 4.** Deux arguments de refus : (1) `allow 5432/tcp` ouvrirait PostgreSQL à **tout Internet** — brute force sur les mots de passe, exfiltration, la base est le joyau de StockLine ; (2) aucun besoin fonctionnel : seule l'API locale parle à la base. Bonne solution : **tunnel SSH** (vu en CL-LINUX J4) :

```bash
ssh -L 5432:localhost:5432 admin@vm-stockline
# puis psql -h localhost -p 5432 ... sur le poste
```

L'accès passe alors par le port 22 déjà restreint et chiffré. (Variante recevable : `ufw allow from 203.0.113.50 to any port 5432 proto tcp` — moins bien : un service de plus exposé, même à une seule IP.)

### Partie 2 — En stateless

**Question 5.** Flux « client Internet → HTTPS de la VM » sur un pare-feu sans état :

| Sens | Proto | IP source | Port source | IP dest | Port dest | Action |
|---|---|---|---|---|---|---|
| IN | TCP | 0.0.0.0/0 | 1024-65535 | VM | **443** | ALLOW |
| OUT | TCP | VM | **443** | 0.0.0.0/0 | **1024-65535** | ALLOW |

Explication : le client contacte le port 443 **depuis** un port éphémère (~1024-65535, choisi par son OS). Le paquet de retour est donc émis **du** port 443 de la VM **vers** ce port éphémère — inconnu à l'avance, d'où la plage entière côté retour. Sans la règle OUT, le SYN-ACK ne sort jamais : la connexion n'aboutit pas.

**Question 6.** Trois flux entrants (80, 443, 22 restreint) × 2 sens = **6 règles** minimum — plus les flux **sortants** de la VM (DNS 53, HTTP/HTTPS d'apt…) qui exigeraient chacun leur paire aller/retour. Conclusion : le stateless double mécaniquement le travail et impose d'ouvrir de larges plages éphémères ; le stateful (ufw, security groups) suit les connexions et rend tout le versant « retour » implicite. C'est exactement l'écart SG/NACL de demain.

### Partie 3 — Lire de l'iptables

**Question 7.**

- a) « Accepte tout paquet entrant appartenant à une connexion **déjà établie** (ou liée à une connexion existante). » — le cœur du comportement stateful (conntrack).
- b) « Accepte les connexions TCP entrantes vers le port 22 **si** elles viennent de 203.0.113.50. »
- c) « Jette les connexions TCP entrantes vers le port 8000 qui n'arrivent **pas** par l'interface loopback » (le `!` inverse le test `-i lo`) — protège l'API si la politique par défaut changeait.
- d) « Politique par défaut de la chaîne INPUT : **tout jeter** » — le défaut fermé.

**Question 8.** Ordre d'évaluation efficace : **a** (établies — la majorité du trafic, testée en premier pour la performance), puis **b** (nouvelles connexions SSH), puis **c** (verrou explicite sur 8000) ; **d** n'est pas une règle mais la **politique**, appliquée à tout ce qu'aucune règle n'a accepté — donc « en dernier » par nature. La règle qui implémente le stateful est **a** (`--ctstate ESTABLISHED,RELATED`).

### Partie 4 — Appliquer et prouver

**Question 9.** Preuves attendues :

```bash
$ sudo ufw status verbose
Status: active
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    203.0.113.50
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
```

- SSH toujours vivant : la session courante n'a pas été coupée ; un `sudo ss -tn state established '( sport = :22 )'` montre la connexion.
- Port non autorisé : depuis **une autre machine**, `curl -m 3 http://IP-VM:8000/` → timeout (aucune réponse : DROP silencieux), tandis que depuis la VM `curl http://127.0.0.1:8000/sante` répond — la double preuve « fermé dehors, ouvert dedans ».

## Variantes acceptables

1. **`ufw allow ssh` / `ufw allow 'Nginx Full'`** (profils d'application) : fonctionnels, mais `allow ssh` ouvre le 22 à tous — n'accepter que si la restriction de source est ajoutée ; sinon c'est un écart au cahier des charges.
2. **`ufw limit 22`** au lieu de `allow from` : protection différente (anti brute-force, mais ouvert à tous) ; recevable en complément, pas en remplacement.
3. **Ordre 80/443 avant SSH** : fonctionne (rien n'est actif avant enable), mais la discipline « porte d'entrée d'abord » doit être défendue — elle sauve le jour où on édite un pare-feu **déjà actif**.

## Bonus

**Bonus 1.** `ufw limit 22/tcp` autorise le port mais **ajoute un seuil** : au-delà de 6 nouvelles connexions en 30 secondes depuis une même IP, les suivantes sont refusées temporairement. Protection contre le **brute force SSH** (essais de mots de passe en rafale).

**Bonus 2.** Équivalent nftables (lecture commentée) :

```text
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;          # défaut fermé (d)
    ct state established,related accept                       # stateful (a)
    iif "lo" accept                                            # loopback (Q3)
    tcp dport 22 ip saddr 203.0.113.50 accept                  # SSH restreint
    tcp dport { 80, 443 } accept                               # web public
  }
  chain output { type filter hook output priority 0; policy accept; }
}
```

**Bonus 3.** En security group AWS (règles entrantes) :

| Port | Proto | Source |
|---|---|---|
| 22 | TCP | 203.0.113.50/32 |
| 80 | TCP | 0.0.0.0/0 |
| 443 | TCP | 0.0.0.0/0 |

Disparaissent : les politiques par défaut (**le SG est nativement « deny in / allow out »**), la règle stateful explicite (le SG l'est par construction) et toute mention de 8000/5432 (non ouverts = refusés). Un SG, c'est la partie 1 de cet exercice avec uniquement les lignes « allow » — le reste est le défaut.
