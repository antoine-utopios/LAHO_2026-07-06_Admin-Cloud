# Solution — Exercice 4-2 : Durcissement sshd et pare-feu ufw

> Document formateur — Ne pas distribuer avant la fin de l'exercice ou du TP.
> Module : 03 — CL-LINUX Linux pour l'admin cloud

## Approche pédagogique

Deux réflexes de survie à ancrer, plus importants que les directives elles-mêmes : **`sshd -t` avant tout restart** et **`ufw allow` avant `ufw enable`** — dans les deux cas, l'erreur type coupe l'accès au serveur. La « corde de rappel » (session `multipass shell` ouverte en permanence) doit être vérifiée physiquement en début d'exercice : passez dans les rangs, chaque apprenant doit avoir son terminal console dédié. Ne sauvez pas trop vite un apprenant qui s'est enfermé dehors : le laisser se récupérer par la console (`ufw disable`, correction du drop-in) est la meilleure leçon de l'exercice — c'est un environnement sans conséquence, contrairement à l'EC2 qu'il administrera dans quelques semaines. Deuxième message : une politique de sécurité se **prouve par un test de refus** (partie 2), pas par une déclaration de configuration. Chronométrage : 15 min partie 1, 10 min partie 2, 10 min partie 3, 5 min partie 4, 5 min de marge/bonus.

## Solution détaillée

Prérequis vérifié : l'accès par clé de l'exercice 4-1 fonctionne (`ssh srv-linux hostname` → `srv-linux`). IP d'exemple : `10.204.28.15`.

### Partie 1 — Le drop-in de durcissement

Raisonnement : Ubuntu 24.04 inclut `Include /etc/ssh/sshd_config.d/*.conf` en tête de `sshd_config`. Un drop-in séparé survit aux mises à jour du paquet openssh-server (pas de conflit sur le fichier principal), documente le changement par son nom, et se retire d'un simple `rm`.

Sur la VM (session corde de rappel) :

```bash
ls /etc/ssh/sshd_config.d/
# 50-cloud-init.conf          ← présent sur les images cloud (posé par cloud-init)
head -5 /etc/ssh/sshd_config
# Include /etc/ssh/sshd_config.d/*.conf
# …

sudo nano /etc/ssh/sshd_config.d/90-durcissement.conf
```

Contenu exact :

```text
PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
```

Validation AVANT restart, puis application :

```bash
sudo sshd -t
# (aucune sortie = configuration valide)

sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|maxauthtries'
# permitrootlogin no
# passwordauthentication no
# maxauthtries 3

sudo systemctl restart ssh
systemctl status ssh
# ● ssh.service - OpenBSD Secure Shell server
#      Active: active (running) since Thu 2026-07-02 15:30:12 UTC; 5s ago
```

- `sshd -t` : test de syntaxe uniquement ; `sshd -T` : dump de la configuration **effective** après fusion de tous les fichiers — c'est lui qui fait foi.
- Point de vigilance formateur : sur l'image Multipass, `50-cloud-init.conf` ne contient généralement que `PasswordAuthentication no` (déjà !) — aucune contradiction avec notre drop-in. Si un fichier concurrent définissait une valeur opposée, **la première occurrence lue gagne** (ordre alphabétique des fichiers) : voir l'indice 2 de l'énoncé et l'erreur classique ci-dessous.
- Rappel sémantique : chaque directive — `PermitRootLogin no` (même avec une clé, root ne se connecte pas : on passe par un compte nominatif + sudo, traçable), `PasswordAuthentication no` (clés uniquement : le force brute par mot de passe devient impossible), `MaxAuthTries 3` (3 essais d'authentification par connexion, ralentit les tâtonnements).

### Partie 2 — Prouver que le mot de passe est refusé

Depuis le poste hôte :

```bash
ssh srv-linux hostname
# srv-linux                    ← la clé passe toujours

ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password deploy@10.204.28.15
# deploy@10.204.28.15: Permission denied (publickey).
```

Lecture du message : le serveur annonce dans `(…)` les méthodes qu'il accepte encore — **publickey uniquement**. Il ne demande même plus de mot de passe : la méthode `password` n'est plus proposée du tout, la tentative est close immédiatement. C'est le comportement attendu.

Trace côté serveur (sur la VM) :

```bash
sudo journalctl -u ssh -n 20
# Jul 02 15:33:41 srv-linux sshd[5124]: Connection closed by authenticating user deploy 10.204.28.1 port 52814 [preauth]
```

(La ligne exacte peut varier — `Connection closed … [preauth]` ou `Unable to negotiate` ; l'important est que la tentative apparaisse et qu'aucune ligne `Accepted password` n'existe. Faire remarquer : ces lignes `[preauth]` sont exactement ce que fail2ban comptera au bonus 2.)

### Partie 3 — Activer ufw dans le bon ordre

Sur la VM :

```bash
sudo ufw status
# Status: inactive

sudo ufw allow OpenSSH
# Rules updated
# Rules updated (v6)
sudo ufw allow 80/tcp
# Rules updated
# Rules updated (v6)

sudo ufw enable
# Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
# Firewall is active and enabled on system startup

sudo ufw status verbose
# Status: active
# Logging: on (low)
# Default: deny (incoming), allow (outgoing), disabled (routed)
# New profiles: skip
#
# To                         Action      From
# --                         ------      ----
# OpenSSH                    ALLOW IN    Anywhere
# 80/tcp                     ALLOW IN    Anywhere
# OpenSSH (v6)               ALLOW IN    Anywhere (v6)
# 80/tcp (v6)                ALLOW IN    Anywhere (v6)
```

Réponse à la question sur le profil : `OpenSSH` est un **profil d'application** livré par le paquet openssh-server dans `/etc/ufw/applications.d/` ; il désigne le port 22/tcp :

```bash
sudo ufw app list
# Available applications:
#   OpenSSH
sudo ufw app info OpenSSH
# Profile: OpenSSH
# Title: Secure shell server, an rshd replacement
# …
# Port:
#   22/tcp
```

Intérêt du profil vs `22/tcp` en dur : lisibilité des règles et suivi du paquet (le profil documente QUI a besoin du port).

Contre-épreuves :

```bash
# Depuis le poste hôte :
ssh srv-linux hostname
# srv-linux                    ← le port 22 passe, on ne s'est pas enfermé dehors

# Sur la VM :
curl -I http://ubuntu.com
# HTTP/1.1 301 Moved Permanently
# …                            ← la politique sortante est allow : rien ne change en sortie
```

L'avertissement de `ufw enable` (« may disrupt existing ssh connections ») est le clou du spectacle : c'est PARCE QU'on a fait `allow OpenSSH` avant qu'on peut répondre `y` sereinement. Ordre inverse = session coupée et, sans console, serveur perdu.

### Partie 4 — Bilan sécurité

```bash
mkdir -p ~/exploitation/rapports
nano ~/exploitation/rapports/durcissement.txt
```

Exemple de synthèse attendue :

```text
DURCISSEMENT srv-linux — 2026-07-02

sshd (drop-in /etc/ssh/sshd_config.d/90-durcissement.conf) :
  - PermitRootLogin no        : connexion root interdite, on passe par un
    compte nominatif + sudo (traçable).
  - PasswordAuthentication no : clés uniquement, force brute par mot de
    passe impossible.
  - MaxAuthTries 3            : 3 essais d'authentification par connexion.
  Validation : sudo sshd -t (silencieux) puis sshd -T avant restart.

Test de refus (depuis le poste hôte) :
  ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password deploy@10.204.28.15
  -> Permission denied (publickey). Le serveur ne propose plus la méthode
  password. Trace vérifiée dans journalctl -u ssh.

ufw : Status active. Politique par défaut deny (incoming) / allow (outgoing).
  Règles : OpenSSH (22/tcp) ALLOW, 80/tcp ALLOW (IPv4 + IPv6).
  Ordre respecté : allow AVANT enable (connexion SSH préservée).

Correspondance cloud : le drop-in sshd se configure à l'identique sur une
instance EC2 (durcissement DANS la VM) ; ufw a pour équivalent le security
group (filtrage EN AMONT de la VM) — en pratique on utilise les deux.
```

## Variantes acceptables

1. Modifier directement `/etc/ssh/sshd_config` au lieu d'un drop-in : fonctionne.
   - Avantage : tout au même endroit.
   - Inconvénient : conflits aux mises à jour du paquet (prompt dpkg), changements non isolés ni auto-documentés — le drop-in est la pratique moderne attendue, c'est aussi celle de cloud-init.
2. `sudo ufw allow 22/tcp` au lieu de `allow OpenSSH` : strictement équivalent ici.
   - Avantage : explicite sur le port.
   - Inconvénient : perd la sémantique applicative ; accepté sans pénalité.
3. `sudo ufw limit OpenSSH` au lieu de `allow` : ajoute un rate-limiting (6 connexions/30 s par IP) — variante plus sûre, à valoriser si un apprenant la propose (elle recoupe le rôle de fail2ban).
4. `sudo systemctl reload ssh` au lieu de `restart` : suffit pour une modification de configuration et ne touche pas les sessions établies ; parfaitement acceptable (le restart d'OpenSSH ne coupe de toute façon pas les sessions en cours, bon point de discussion).

## Erreurs classiques à repérer en correction

| Erreur observée | Cause probable | Comment corriger |
|-----------------|----------------|------------------|
| `ufw enable` lancé AVANT les `allow` → session SSH coupée | Ordre des opérations non respecté | Par la corde de rappel (`multipass shell`) : `sudo ufw disable`, puis allow OpenSSH + 80/tcp, puis enable. Débriefer : sur EC2 sans console série, c'était l'instance perdue |
| restart de ssh avec une config invalide → `ssh.service failed`, plus de connexion possible | `sshd -t` sauté, faute de frappe dans le drop-in | Par la console : corriger le drop-in, `sudo sshd -t` jusqu'au silence, `sudo systemctl restart ssh`. Ancrer le réflexe : JAMAIS de restart sans -t |
| `sshd -T` montre `passwordauthentication yes` malgré le drop-in | Fichier concurrent lu avant (première occurrence gagne), ou drop-in nommé sans extension `.conf` (donc ignoré par l'Include) | `grep -r PasswordAuthentication /etc/ssh/sshd_config.d/ /etc/ssh/sshd_config` ; renommer le drop-in avec un préfixe plus petit (ex. `10-`) ou corriger l'extension |
| Le test de la partie 2 demande quand même un mot de passe | restart oublié après l'écriture du drop-in, ou test lancé vers `ubuntu@` (géré par un autre chemin de conf cloud-init) | `sudo systemctl restart ssh` puis retester vers `deploy@` |
| `Bad configuration option: PasswordAuthentification` | Francisation de la directive | Orthographe exacte : `PasswordAuthentication` — c'est `sshd -t` qui l'attrape, montrer le message |
| Règles ufw ajoutées mais `Status: inactive` | `ufw enable` oublié (les allow ne déclenchent rien seuls) | `sudo ufw enable` puis `status verbose` |
| Panique : « j'ai tout cassé, plus aucun terminal ne répond » | La corde de rappel a été fermée ou utilisée pour autre chose | `multipass shell srv-linux` rouvre TOUJOURS une console (ne passe pas par sshd/ufw de la VM) ; en dernier recours `multipass restart srv-linux` |

## Points à insister en débriefing

- Les deux réflexes jumeaux du jour : **valider avant d'appliquer** (`sshd -t` / plus tard `nginx -t`, `visudo`, `terraform plan`…) et **garder une porte ouverte pendant qu'on touche à la porte** (corde de rappel / console série EC2). Toute la fiabilité de l'admin système tient dans ces rituels.
- Une politique de sécurité se prouve par un **test négatif** : « le mot de passe est refusé » vaut plus que « j'ai écrit PasswordAuthentication no ». Même logique plus tard pour les security groups : on teste ce qui doit être bloqué.
- Défense en profondeur : sshd durci (authentification), ufw (filtrage réseau), fail2ban (réaction aux attaques) — trois couches indépendantes. Sur AWS on empile pareil : security group + NACL + durcissement de l'OS ; le security group est le cousin d'ufw mais **en amont** de l'instance, et les deux se configurent (allow 22 d'abord !) avec la même prudence.
- `deny (incoming), allow (outgoing)` par défaut = le modèle de tout pare-feu moderne et des security groups : on n'ouvre que ce qui est justifié, et chaque `allow` doit pouvoir être expliqué dans un audit.
- Lien avec la suite : au mini-TP de cet après-midi, le `allow 80/tcp` posé ici servira immédiatement — nginx va écouter dessus pour publier StockLine ; et au bloc CL-RÉSEAU puis CL-AWS1, la paire ufw/security group reviendra systématiquement.

## Bonus

### Bonus 1 — Port 2222

```bash
# Sur la VM — ajout au drop-in :
sudo nano /etc/ssh/sshd_config.d/90-durcissement.conf
#   → ajouter la ligne :  Port 2222
sudo sshd -t
# (silence)

# OUVRIR le port AVANT le restart (ufw est actif !) :
sudo ufw allow 2222/tcp
sudo systemctl restart ssh
sudo ss -tlnp | grep ssh
# LISTEN 0 4096 0.0.0.0:2222 0.0.0.0:* users:(("sshd",…))
```

Depuis le poste hôte :

```bash
ssh -p 2222 deploy@10.204.28.15 hostname
# srv-linux
```

Mise à jour de `~/.ssh/config` :

```text
Host srv-linux
    HostName 10.204.28.15
    User deploy
    IdentityFile ~/.ssh/formation_ed25519
    Port 2222
```

Conséquences à faire lister (réponse complète) : règle ufw supplémentaire (et suppression du profil OpenSSH devenu inutile à terme), `Port` dans la config client de CHAQUE poste, options `-p`/`-e` à ajuster dans les scripts scp/rsync existants, supervision et fail2ban à reconfigurer, documentation d'équipe à mettre à jour. Bilan honnête : le changement de port est de l'obscurité, pas de la sécurité (un scan le trouve en secondes) — clés + MaxAuthTries + fail2ban protègent réellement ; beaucoup d'équipes gardent le 22.

Nettoyage (le TP suppose le port 22) :

```bash
# VM : retirer la ligne Port 2222 du drop-in
sudo nano /etc/ssh/sshd_config.d/90-durcissement.conf
sudo sshd -t && sudo systemctl restart ssh
sudo ufw delete allow 2222/tcp
# Hôte : retirer la ligne Port 2222 de ~/.ssh/config, puis vérifier :
ssh srv-linux hostname
# srv-linux
```

### Bonus 2 — fail2ban en lecture

```bash
sudo apt update && sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status
# Status
# |- Number of jail:      1
# `- Jail list:   sshd
sudo fail2ban-client status sshd
# Status for the jail: sshd
# |- Filter
# |  |- Currently failed: 0
# |  |- Total failed:     1
# |  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
# `- Actions
#    |- Currently banned: 0
#    |- Total banned:     0
#    `- Banned IP list:
```

(Le `Total failed: 1` provient souvent du test de refus de la partie 2 — joli raccord à faire remarquer. Sur Ubuntu 24.04, le paquet lit directement le journal systemd, d'où la ligne `Journal matches`.)

Réponses attendues aux questions : si une IP enchaînait les échecs (par défaut 5 en 10 minutes), fail2ban la **bannirait** temporairement (10 minutes par défaut) en insérant une règle de pare-feu (nftables) qui rejette tout son trafic ; il **lit** les journaux d'authentification (journal systemd / auth.log) et **agit** via le pare-feu — c'est la couche « réaction » de la défense en profondeur, complémentaire de sshd (authentification) et ufw (filtrage statique).
