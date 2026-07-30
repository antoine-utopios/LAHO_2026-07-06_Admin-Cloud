# Solution — Exercice 3-2 : Audit disque et réseau d'un serveur

## Approche pédagogique

Exercice de méthode plus que de technique : chaque commande a été vue en cours, l'enjeu est de les **enchaîner** dans un ordre logique (du général au particulier pour le disque, de l'interface au service pour le réseau) et de **restituer** dans un rapport. Insistez sur le réflexe « on documente avant de nettoyer » : en entreprise, supprimer 1,5 Go non identifié sans trace écrite est une faute. Le rapport texte dans nano rebute parfois : rappelez qu'un ticket d'incident ou un runbook cloud, c'est exactement ce format. Chronométrage : 15 min partie 1, 5 min partie 2, 10 min partie 3, 15 min partie 4.

## Solution détaillée

### Partie 1 — Le disque se remplit : enquête

Raisonnement : `df` répond à « le disque est-il plein ? » (vue systèmes de fichiers), `du` répond à « qu'est-ce qui le remplit ? » (vue arborescence). On descend niveau par niveau en suivant le plus gros sous-répertoire.

```bash
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        19G  3.9G   15G  21% /
# (avant la mise en place, / était autour de 2,4G/13% : +1,5 Go)

sudo du -h --max-depth=1 /var 2>/dev/null | sort -h
# 4.0K    /var/mail
# …
# 96M     /var/lib
# 1.5G    /var/tmp
# 1.7G    /var

sudo du -h --max-depth=1 /var/tmp 2>/dev/null | sort -h
# 1.5G    /var/tmp/cache-app
# 1.5G    /var/tmp

ls -lh /var/tmp/cache-app
# -rw-r--r-- 1 root root 500M Jul  2 14:00 cache-01.bin
# -rw-r--r-- 1 root root 500M Jul  2 14:00 cache-02.bin
# -rw-r--r-- 1 root root 500M Jul  2 14:00 cache-03.bin

sudo du -sh /var/tmp/cache-app
# 1.5G    /var/tmp/cache-app
```

Coupable : `/var/tmp/cache-app`, 3 fichiers de 500 Mo, 1,5 Go au total, propriétaire root, extension `.bin` non identifiée → recommandation type : « fichiers de cache probables, non référencés par un service connu ; à confirmer avec l'équipe applicative avant suppression ». On ne supprime pas encore (partie du contrat de l'énoncé).

- `2>/dev/null` masque les `Permission denied` résiduels ; `sort -h` trie les tailles humaines (le coupable est en bas).
- Les pourcentages exacts de `df` varient selon l'image 24.04 et la taille de disque choisie : seul l'écart de ~1,5 Go compte.

### Partie 2 — Topologie du stockage

```bash
lsblk
# NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda       8:0    0 19.1G  0 disk
# ├─sda1    8:1    0   19G  0 part /
# ├─sda14   8:14   0    4M  0 part
# ├─sda15   8:15   0  106M  0 part /boot/efi
# └─sda16   8:16   0  913M  0 part /boot

cat /etc/fstab
# LABEL=cloudimg-rootfs   /        ext4   discard,commit=30,errors=remount-ro   0 1
# LABEL=BOOT      /boot   ext4    defaults        0 2
# LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
```

(Selon l'hyperviseur, le disque peut s'appeler `vda` ; sur certaines images, la racine est désignée par `UUID=…` plutôt que `LABEL=…` — les deux réponses sont bonnes.)

Réponse attendue à la question : la racine est désignée par un **LABEL** (ou UUID), pas par `/dev/sda1`, parce que le nom de périphérique peut changer (ordre de détection, ajout d'un disque, migration de la VM) alors que le LABEL/UUID est inscrit dans le système de fichiers lui-même : le montage reste stable. Sur le cloud c'est vital : un volume EBS détaché/rattaché peut changer de nom de device.

Relevé : périphérique `sda1` (19 Go) → `/`, système de fichiers `ext4`.

### Partie 3 — Relevé réseau

```bash
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> … inet 127.0.0.1/8 …
# 2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> …
#     inet 10.204.28.15/24 metric 100 brd 10.204.28.255 scope global dynamic ens3
```
→ interface `ens3` (parfois `enp0s1`/`enp0s2` selon l'hyperviseur), IPv4 `10.204.28.15` (chaque apprenant a la sienne : c'est l'IP donnée par `multipass info srv-linux`).

```bash
ip r
# default via 10.204.28.1 dev ens3 proto dhcp src 10.204.28.15 metric 100
# 10.204.28.0/24 dev ens3 proto kernel scope link src 10.204.28.15 metric 100
```
→ passerelle par défaut `10.204.28.1` (le .1 du réseau Multipass).

```bash
sudo ss -tlnp
# State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
# LISTEN 0      4096      127.0.0.54:53         0.0.0.0:*    users:(("systemd-resolve",…))
# LISTEN 0      4096   127.0.0.53%lo:53         0.0.0.0:*    users:(("systemd-resolve",…))
# LISTEN 0      4096         0.0.0.0:22         0.0.0.0:*    users:(("sshd",…))
# LISTEN 0      4096            [::]:22            [::]:*    users:(("sshd",…))
```
→ port 53 local = résolveur DNS `systemd-resolved` (uniquement sur 127.0.0.x, donc pas exposé) ; port 22 = `sshd`, exposé sur toutes les interfaces (`0.0.0.0`). Sur l'image Multipass, sshd est présent par défaut.

```bash
curl -I http://ubuntu.com
# HTTP/1.1 301 Moved Permanently
# Location: https://ubuntu.com/
# …
```
→ code `301` : redirection permanente vers HTTPS. Preuve que DNS + sortie port 80 fonctionnent.

```bash
dig +short ubuntu.com
# 185.125.190.20
# 185.125.190.21
# 185.125.190.29
```
→ trois adresses IPv4 (les valeurs exactes peuvent varier : n'importe quelles IP publiques cohérentes sont acceptées).

### Partie 4 — Le mini-rapport d'audit

```bash
mkdir -p ~/exploitation/rapports
nano ~/exploitation/rapports/audit.txt
```

Exemple de rapport complet attendu (les valeurs sont celles relevées par l'apprenant) :

```text
RAPPORT D'AUDIT — srv-linux — 2026-07-02 — auteur : Camille Martin

1. DISQUE
   - Occupation de / (df -h) : 21 % sur 19 Go (3,9 Go utilisés)
   - Répertoire anormal identifié : /var/tmp/cache-app — 1,5 Go — 3 fichiers
     (cache-01.bin, cache-02.bin, cache-03.bin, 500 Mo chacun, propriétaire root)
   - Méthode : df -h pour constater l'occupation globale, puis descente avec
     sudo du -h --max-depth=1 (triée avec sort -h) de /var vers /var/tmp
     vers /var/tmp/cache-app, confirmation avec ls -lh et du -sh.
   - Recommandation : fichiers .bin non référencés par un service connu,
     probablement un cache abandonné ; à faire confirmer par l'équipe
     applicative puis à supprimer (gain : 1,5 Go, soit 8 % du disque).

2. STOCKAGE
   - Périphérique portant / (lsblk) : sda1, 19 Go, partition du disque sda
   - Ligne fstab : LABEL=cloudimg-rootfs / ext4 discard,commit=30,errors=remount-ro 0 1
     Désignation par LABEL (identifiant stable, indépendant du nom de device).

3. RÉSEAU
   - Interface et adresse IPv4 : ens3 — 10.204.28.15/24
   - Passerelle par défaut : 10.204.28.1
   - Ports TCP en écoute :
       53/tcp  -> systemd-resolved (127.0.0.53 et 127.0.0.54, local uniquement)
       22/tcp  -> sshd (0.0.0.0 et [::], exposé)
   - Test web sortant : curl -I http://ubuntu.com -> HTTP/1.1 301 Moved Permanently
     (redirection vers https : sortie Internet et DNS opérationnels)
   - Résolution DNS : dig +short ubuntu.com -> 185.125.190.20, .21, .29

4. CONCLUSION
   Serveur sain : disque à 21 % après identification d'1,5 Go de cache à purger,
   un seul service exposé (SSH), sortie Internet et résolution DNS fonctionnelles.
   Prêt pour mise en production après purge du cache et durcissement SSH (J4).
```

Contrôle final : `cat ~/exploitation/rapports/audit.txt`.

## Variantes acceptables

1. `du -sh /var/*` (glob) au lieu de `--max-depth=1` : résultat proche.
   - Avantage : plus court à taper.
   - Inconvénient : n'affiche pas le total du parent et rate les fichiers cachés à la racine du répertoire ; `--max-depth` est la forme canonique.
2. `ncdu` (à installer) pour l'exploration disque : excellent outil interactif — acceptable en bonus, mais l'exercice vise la méthode scriptable (df/du s'utilisent dans des scripts et sur des serveurs minimalistes sans paquet supplémentaire).
3. `resolvectl query ubuntu.com` ou `host ubuntu.com` au lieu de `dig +short` : mêmes informations ; `dig` reste l'outil de référence (revu au bloc CL-RÉSEAU).
4. `ss -tlnp` sans sudo : accepté si l'apprenant explique pourquoi la colonne processus est vide pour sshd/resolved (les sockets appartiennent à root).

## Erreurs classiques à repérer en correction

| Erreur observée | Cause probable | Comment corriger |
|-----------------|----------------|------------------|
| `du` sur /var affiche à peine quelques Mo | `du` lancé sans sudo : répertoires interdits ignorés | `sudo du -h --max-depth=1 /var 2>/dev/null` |
| Le coupable « n'apparaît pas » dans le tri | `sort` sans `-h` : « 1.5G » classé avant « 96M » (tri alphabétique) | `sort -h` (human-numeric) |
| L'apprenant conclut que curl « échoue » sur le 301 | Confusion code de redirection / code d'erreur | 3xx = redirection, le transport a fonctionné ; `curl -IL` pour suivre jusqu'au 200 |
| `dig +short` ne renvoie rien | Faute de frappe sur le domaine, ou `+short` collé au domaine | Réessayer `dig +short ubuntu.com` ; sans réponse, tester `resolvectl status` |
| Fichiers cache supprimés dès la partie 1 | Lecture trop rapide de l'énoncé | Rappeler la règle métier : documenter avant de nettoyer (traçabilité) |
| Rapport avec les commandes mais sans les valeurs | Confusion « journal de commandes » / « rapport » | Un rapport donne les RÉSULTATS ; les commandes n'y figurent qu'en justification de méthode |
| IP de `lo` (127.0.0.1) relevée comme IP du serveur | Lecture partielle de `ip a` | Faire repérer `scope global` vs `scope host` |

## Bonus

### Bonus 1 — Nettoyage documenté

```bash
sudo rm -r /var/tmp/cache-app
df -h
# /dev/sda1        19G  2.4G   16G  14% /     ← retour à l'occupation initiale
```

Section à ajouter au rapport :

```text
5. NETTOYAGE EFFECTUÉ
   2026-07-02 15h10 : suppression de /var/tmp/cache-app (sudo rm -r) après
   validation. Occupation de / : 21 % -> 14 % (gain 1,5 Go). Vérifié par df -h.
```

### Bonus 2 — Script de relevé automatique

`~/exploitation/scripts/releve-audit.sh` :

```bash
#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/exploitation/rapports/releve-$(date +%Y%m%d).txt"
{
  echo "=== Relevé du $(date '+%Y-%m-%d %H:%M:%S') sur $(hostname) ==="
  echo "--- df -h ---";        df -h
  echo "--- lsblk ---";        lsblk
  echo "--- ip a ---";         ip a
  echo "--- ip r ---";         ip r
  echo "--- ss -tlnp ---";     sudo ss -tlnp
} > "$DEST"
echo "Relevé écrit dans $DEST"
```

```bash
chmod +x ~/exploitation/scripts/releve-audit.sh
~/exploitation/scripts/releve-audit.sh
# Relevé écrit dans /home/ubuntu/exploitation/rapports/releve-20260702.txt
less ~/exploitation/rapports/releve-20260702.txt
```

Le bloc `{ …; } > "$DEST"` regroupe toutes les sorties dans une seule redirection — plus propre que six `>>`. Faire le pont : planifié avec le timer de l'exercice 3-1, ce script devient une supervision minimale ; CloudWatch fera la même chose en dashboard au bloc CL-AWS.
