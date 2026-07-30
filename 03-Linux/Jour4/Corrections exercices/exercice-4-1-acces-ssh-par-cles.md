# Solution — Exercice 4-1 : Accès SSH par clés et config client

> Document formateur — Ne pas distribuer avant la fin de l'exercice ou du TP.
> Module : 03 — CL-LINUX Linux pour l'admin cloud

## Approche pédagogique

Le cœur de l'exercice est l'installation **manuelle** de la clé publique : `ssh-copy-id` sera montré en variante, mais l'apprenant doit avoir fait une fois à la main le triptyque `mkdir ~/.ssh` / `authorized_keys` / `chmod 700-600` + `chown`, car c'est ce qui démystifie 90 % des « Permission denied (publickey) » qu'il rencontrera en carrière — et c'est exactement ce que fait AWS avec la key pair à la création d'une instance EC2. Deuxième enjeu : la bascule mentale poste hôte = client / VM = serveur distant ; beaucoup d'apprenants tapent les commandes dans le mauvais terminal. Conseillez deux terminaux côte à côte étiquetés HÔTE et VM. Chronométrage : 5 min parties 0-1, 5 min partie 2, 15 min partie 3, 5 min partie 4, 15 min partie 5.

## Solution détaillée

L'IP utilisée ci-dessous est `10.204.28.15` : chaque apprenant remplace par la sienne (`multipass info srv-linux`).

### Partie 0 — Relever l'adresse IP (poste hôte)

```bash
multipass info srv-linux
# Name:           srv-linux
# State:          Running
# Snapshots:      0
# IPv4:           10.204.28.15
# Release:        Ubuntu 24.04.2 LTS
# …
```

### Partie 1 — Générer la paire de clés (poste hôte)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/formation_ed25519 -C "formation-admin-cloud"
# Generating public/private ed25519 key pair.
# Enter passphrase (empty for no passphrase):
# Enter same passphrase again:
# Your identification has been saved in /Users/camille/.ssh/formation_ed25519
# Your public key has been saved in /Users/camille/.ssh/formation_ed25519.pub

ls -l ~/.ssh/formation_ed25519*
# -rw-------  1 camille  staff  444 Jul  2 15:00 /Users/camille/.ssh/formation_ed25519
# -rw-r--r--  1 camille  staff  103 Jul  2 15:00 /Users/camille/.ssh/formation_ed25519.pub

cat ~/.ssh/formation_ed25519.pub
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2m3xkQ7vJc9tR0aBdEfGhIjKlMnOpQrStUvWxYz012 formation-admin-cloud
```

- `-t ed25519` : algorithme moderne, clés courtes, rapide — le standard actuel (RSA 4096 reste accepté pour du legacy).
- `-f` : fichier dédié, pour ne pas écraser une éventuelle `id_ed25519` existante — TOUJOURS vérifier ce point avec les apprenants qui ont déjà des clés (GitHub…).
- `-C` : simple commentaire d'identification, recopié en fin de clé publique.
- Réponses aux questions : `formation_ed25519` = clé **privée** (mode 600, ne quitte JAMAIS le poste) ; `formation_ed25519.pub` = clé **publique** (diffusable sans risque, c'est elle qu'on installe sur les serveurs).
- Sous Windows/PowerShell : mêmes commandes, chemin `C:\Users\camille\.ssh\` ; `cat` et `ls` existent en alias PowerShell.

### Partie 2 — Créer l'utilisateur deploy (sur la VM)

```bash
multipass shell srv-linux
sudo adduser deploy
# info: Adding user `deploy' ...
# New password:
# Retype new password:
# passwd: password updated successfully
# Changing the user information for deploy
#         Full Name []:            ← Entrée pour tout
# …
# Is the information correct? [Y/n] Y

id deploy
# uid=1001(deploy) gid=1001(deploy) groups=1001(deploy),100(users)
```

`adduser` (l'outil convivial Debian/Ubuntu) crée le home `/home/deploy`, le groupe, et demande le mot de passe — mot de passe « de secours » qui sera d'ailleurs neutralisé côté SSH à l'exercice 4-2.

### Partie 3 — Installer la clé publique à la main (VM, puis test depuis l'hôte)

Sur la VM :

```bash
sudo mkdir -p /home/deploy/.ssh
sudo touch /home/deploy/.ssh/authorized_keys
sudo nano /home/deploy/.ssh/authorized_keys
# → coller la ligne ssh-ed25519 … formation-admin-cloud (une seule ligne), Ctrl+O, Entrée, Ctrl+X
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh

sudo ls -la /home/deploy/.ssh
# drwx------ 2 deploy deploy 4096 Jul  2 15:05 .
# drwxr-x--- 3 deploy deploy 4096 Jul  2 15:03 ..
# -rw------- 1 deploy deploy  103 Jul  2 15:05 authorized_keys
```

Pourquoi ces droits : sshd applique un « StrictModes » par défaut — si `~/.ssh` ou `authorized_keys` sont lisibles/modifiables par d'autres, la clé est **ignorée** (un tiers pourrait sinon y injecter sa propre clé). Le `chown -R deploy:deploy` est indispensable : tout a été créé par root via sudo.

Depuis le poste hôte :

```bash
ssh -i ~/.ssh/formation_ed25519 deploy@10.204.28.15
# The authenticity of host '10.204.28.15 (10.204.28.15)' can't be established.
# ED25519 key fingerprint is SHA256:kT9qWmBv…
# Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
# Warning: Permanently added '10.204.28.15' (ED25519) to the list of known hosts.
# Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-59-generic x86_64)
# …
deploy@srv-linux:~$ exit
```

Le `yes` alimente `~/.ssh/known_hosts` : c'est le serveur qui prouve son identité au client (protection contre l'usurpation) — sens inverse de la clé de l'utilisateur. Bonne question à poser à la cantonade.

### Partie 4 — ~/.ssh/config (poste hôte)

```bash
nano ~/.ssh/config
```

```text
Host srv-linux
    HostName 10.204.28.15
    User deploy
    IdentityFile ~/.ssh/formation_ed25519
```

(Si le fichier `config` vient d'être créé sur macOS/Linux, un `chmod 600 ~/.ssh/config` est une bonne hygiène ; OpenSSH ne l'exige que pour la clé privée.)

```bash
ssh srv-linux
# deploy@srv-linux:~$          ← connexion directe
ssh srv-linux hostname
# srv-linux                    ← exécution de commande à distance sans session interactive
```

`ssh srv-linux hostname` est le prototype de toute l'automatisation à venir : scripts de déploiement, Ansible, pipelines — une commande, un résultat, pas d'interaction.

### Partie 5 — scp puis rsync (poste hôte)

```bash
mkdir -p ~/transfert-demo
echo "script un" > ~/transfert-demo/script1.sh
echo "script deux" > ~/transfert-demo/script2.sh
echo "lisez-moi" > ~/transfert-demo/LISEZMOI.txt

scp -r ~/transfert-demo srv-linux:~/transfert-scp
# LISEZMOI.txt                                  100%   10     8.3KB/s   00:00
# script1.sh                                    100%   10     9.1KB/s   00:00
# script2.sh                                    100%   11    10.2KB/s   00:00

rsync -av ~/transfert-demo/ srv-linux:~/transfert-rsync/
# sending incremental file list
# created directory ./transfert-rsync
# ./
# LISEZMOI.txt
# script1.sh
# script2.sh
# sent 391 bytes  received 112 bytes  335.33 bytes/sec
# total size is 31  speedup is 0.06
```

Deuxième passage après modification :

```bash
echo "v2" >> ~/transfert-demo/script1.sh

scp -r ~/transfert-demo srv-linux:~/transfert-scp
# LISEZMOI.txt                                  100%   10     …
# script1.sh                                    100%   13     …
# script2.sh                                    100%   11     …
#   → scp retransfère TOUT (les 3 fichiers), à chaque fois.

rsync -av ~/transfert-demo/ srv-linux:~/transfert-rsync/
# sending incremental file list
# script1.sh
# sent 246 bytes  received 47 bytes  …
#   → rsync ne transfère QUE script1.sh (le seul modifié).

ssh srv-linux ls -l transfert-scp transfert-rsync
# transfert-rsync:
# -rw-r--r-- 1 deploy deploy 10 Jul  2 15:10 LISEZMOI.txt
# -rw-r--r-- 1 deploy deploy 13 Jul  2 15:14 script1.sh
# -rw-r--r-- 1 deploy deploy 11 Jul  2 15:10 script2.sh
# transfert-scp:
# … (mêmes 3 fichiers)
```

Comparatif attendu (`~/transfert-demo/comparatif.txt`) :

```text
scp recopie l'intégralité du dossier à chaque exécution ; rsync compare
source et destination et ne transfère que les différences (ici 1 fichier
sur 3). Pour un déploiement répété, rsync est le bon choix : plus rapide,
reprend un transfert interrompu, et --delete peut refléter les
suppressions. Les deux passent par SSH, donc par la même clé.
```

Détail des options : `-a` (archive) = récursif + préservation droits/dates/liens ; `-v` = liste des fichiers transférés. Le `/` final sur la source signifie « le contenu du dossier » (sans lui : le dossier lui-même dans la destination).

## Variantes acceptables

1. `ssh-copy-id -i ~/.ssh/formation_ed25519.pub deploy@10.204.28.15` au lieu de l'installation manuelle :
   - Avantage : une commande, droits posés correctement automatiquement — c'est l'outil du quotidien.
   - Inconvénient : exige que `deploy` puisse déjà s'authentifier par mot de passe (OK ici, impossible après le durcissement 4-2) ; et surtout il court-circuite l'objectif pédagogique. À montrer en débriefing, pas en remplacement.
2. Pipe direct depuis l'hôte : `cat ~/.ssh/formation_ed25519.pub | ssh ubuntu@10.204.28.15 "sudo tee -a /home/deploy/.ssh/authorized_keys"` (en supposant un accès ubuntu) — élégant, mais suppose les droits déjà posés ; acceptable si l'apprenant maîtrise ce qu'il fait.
3. `multipass transfer` pour amener la `.pub` sur la VM plutôt qu'un copier-coller : parfaitement valable (transfert vers `/home/ubuntu`, puis `sudo install -m 600 -o deploy -g deploy`), montre une bonne compréhension de l'outillage.
4. `rsync -avz` : `-z` compresse pendant le transfert — utile sur un vrai lien WAN, invisible en local ; accepté.

## Erreurs classiques à repérer en correction

| Erreur observée | Cause probable | Comment corriger |
|-----------------|----------------|------------------|
| `Permission denied (publickey)` au test | `authorized_keys` en 644, ou `.ssh`/fichier restés à root (chown oublié) | `chmod 700 ~/.ssh`, `chmod 600 authorized_keys`, `chown -R deploy:deploy` ; diagnostic dans `sudo journalctl -u ssh` (« Authentication refused: bad ownership or modes ») |
| Clé publique coupée en deux lignes dans authorized_keys | Collage depuis un terminal étroit avec retour à la ligne | La ligne doit être UNIQUE : `wc -l` = 1 ; recoller proprement |
| La clé PRIVÉE collée dans authorized_keys | Confusion .pub / privée | Reprendre partie 1 : seule la ligne `ssh-ed25519 …` de la `.pub` s'installe ; signaler que la privée est maintenant compromise → régénérer |
| Mot de passe demandé au test de la partie 3 | Mauvaise clé proposée (`-i` oublié) ou authorized_keys non lu → repli sur password | `ssh -v` pour voir les clés offertes ; vérifier droits/propriétaire côté serveur |
| Commandes tapées dans le mauvais terminal (ssh-keygen sur la VM…) | Confusion client/serveur | Deux terminaux étiquetés HÔTE / VM ; règle : la clé naît côté client |
| `ssh srv-linux` répond « Could not resolve hostname » | Bloc écrit dans un mauvais fichier (`~/.ssh/config.txt`, extension ajoutée par l'éditeur) ou faute dans `Host` | Le fichier s'appelle exactement `config` ; `ssh -G srv-linux` montre la config résolue |
| rsync crée `transfert-rsync/transfert-demo/…` | `/` final absent sur la source | Rappeler la règle du slash : source avec `/` = le contenu |
| `rsync: command not found` côté VM | rsync absent de l'image minimale | `sudo apt update && sudo apt install -y rsync` sur la VM (présent par défaut sur l'image Multipass 24.04, mais possible sur le plan B VirtualBox) |

## Points à insister en débriefing

- La clé privée ne voyage jamais ; la clé publique voyage librement. Toute la sécurité SSH tient dans cette asymétrie — et dans les droits 700/600 sans lesquels sshd ignore le fichier.
- Vous venez de faire À LA MAIN ce qu'AWS fait à la création d'une instance EC2 : la **key pair** choisie au lancement, c'est une clé publique injectée par cloud-init dans `~/.ssh/authorized_keys` de l'utilisateur `ubuntu`. « Perdre la clé privée d'une key pair = perdre l'accès » prend maintenant tout son sens.
- `~/.ssh/config` est un multiplicateur de productivité : à dix serveurs, il devient l'inventaire de votre parc ; scp, rsync, git et les IDE le lisent aussi (`Host srv-linux` fonctionne partout).
- scp = photocopie intégrale, rsync = différentiel : au mini-TP de cet après-midi, c'est rsync qui poussera le code StockLine sur le serveur, et c'est lui que les scripts de déploiement réutiliseront jusqu'à la fin du cursus.
- Lien avec la suite : exercice 4-2 — maintenant que la clé fonctionne, on peut interdire les mots de passe (`PasswordAuthentication no`) sans se couper l'accès.

## Bonus — ssh-agent

```bash
eval "$(ssh-agent -s)"
# Agent pid 4821
ssh-add ~/.ssh/formation_ed25519
# Enter passphrase for /Users/camille/.ssh/formation_ed25519:
# Identity added: /Users/camille/.ssh/formation_ed25519 (formation-admin-cloud)
ssh-add -l
# 256 SHA256:kT9qWmBv… formation-admin-cloud (ED25519)
ssh srv-linux
# deploy@srv-linux:~$          ← plus aucune saisie
```

- L'agent garde la clé **déchiffrée en mémoire** (jamais sur disque) pour la durée de la session ; au redémarrage du poste, tout est perdu et la passphrase sera redemandée au premier `ssh-add` — c'est le compromis sécurité/confort recherché.
- macOS : l'agent système tourne déjà ; `ssh-add --apple-use-keychain` mémorise la passphrase dans le trousseau. Windows : service « OpenSSH Authentication Agent » à passer en démarrage automatique (`Set-Service ssh-agent -StartupType Automatic` puis `Start-Service ssh-agent`). Linux desktop : l'agent est généralement lancé par la session.
- Ouverture pour les curieux : `ForwardAgent yes` dans `~/.ssh/config` permet de rebondir de serveur en serveur sans copier la clé privée nulle part — à n'activer que vers des machines de confiance.
