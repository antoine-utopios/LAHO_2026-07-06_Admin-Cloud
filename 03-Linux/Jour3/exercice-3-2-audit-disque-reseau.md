# Exercice 3-2 — Audit disque et réseau d'un serveur

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 2 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Diagnostiquer un disque qui se remplit avec `df`, `du`, `lsblk` et la lecture de `/etc/fstab`
- Relever la configuration réseau d'un serveur : adresses, routes, ports en écoute, résolution DNS
- Rédiger un mini-rapport d'audit exploitable par un collègue

## Prérequis

- Avoir suivi les parties « Disques » et « Outils réseau locaux » du module 03 (jour 3)
- Environnement : VM Multipass `srv-linux` (Ubuntu Server 24.04 LTS), utilisateur `ubuntu` — connexion : `multipass shell srv-linux`
- Outils : df, du, lsblk, ip, ss, curl, dig, nano

## Contexte

Vous reprenez l'exploitation d'un serveur qu'un prestataire vient de vous livrer. Avant de le mettre en production, votre responsable vous demande un état des lieux : « le disque se remplit anormalement vite, trouvez pourquoi, et faites-moi un relevé complet du réseau ». C'est exactement l'audit que vous ferez sur chaque instance EC2 ou VM Azure dont vous héritez : mêmes commandes, même méthode. Le livrable est un rapport texte — sur un serveur, pas de traitement de texte : le rapport se rédige dans nano.

## Mise en place (copier-coller tel quel)

Connectez-vous à la VM puis copiez-collez ce bloc en une seule fois. Il joue le rôle du « prestataire » qui a laissé traîner des fichiers :

```bash
sudo mkdir -p /var/tmp/cache-app
sudo fallocate -l 500M /var/tmp/cache-app/cache-01.bin
sudo fallocate -l 500M /var/tmp/cache-app/cache-02.bin
sudo fallocate -l 500M /var/tmp/cache-app/cache-03.bin
echo "Mise en place terminée."
```

Résultat attendu : le message `Mise en place terminée.` s'affiche, sans erreur. Ne regardez pas le contenu du bloc de trop près : c'est justement ce que vous allez devoir retrouver.

## Énoncé

### Partie 1 — Le disque se remplit : enquête

Menez l'enquête avec la méthode vue en cours, du général au particulier :

1. `df -h` : notez le pourcentage d'utilisation du système de fichiers racine (`/`) et sa taille.
2. Descendez dans l'arborescence avec `du` pour trouver le répertoire coupable. Méthode imposée : partez de `sudo du -h --max-depth=1 /var 2>/dev/null | sort -h`, puis répétez sur le sous-répertoire le plus gros, jusqu'à identifier le répertoire précis et les fichiers en cause avec `ls -lh`.
3. Notez : chemin du répertoire coupable, nombre de fichiers, taille totale (`sudo du -sh` sur ce répertoire).
4. **Ne supprimez rien pour l'instant** : dans la vraie vie, on documente avant de nettoyer.

Résultat attendu : vous avez identifié `/var/tmp/cache-app` (1,5 Go, 3 fichiers de 500 Mo) et vous savez reconstituer le cheminement `df -h` → `du --max-depth` → `ls -lh`.

### Partie 2 — Lire la topologie du stockage

1. `lsblk` : identifiez le disque et la partition qui portent la racine `/`. Notez le nom du périphérique (sur une VM Multipass : `sda` ou `vda`) et sa taille.
2. `cat /etc/fstab` : identifiez la ligne qui monte la racine. Par quoi le périphérique est-il désigné (nom de device, UUID, LABEL) ? Pourquoi ce choix plutôt que `/dev/sda1` en dur ?
3. Complétez votre relevé : périphérique, point de montage, type de système de fichiers.

Résultat attendu : vous savez dire quel périphérique bloc porte `/`, quel est son système de fichiers (ext4), et expliquer en une phrase l'intérêt d'un identifiant stable (UUID/LABEL) dans `/etc/fstab`.

### Partie 3 — Relevé réseau

Relevez, dans l'ordre, en notant chaque fois la commande ET l'information extraite :

1. `ip a` : l'adresse IPv4 de l'interface principale (celle qui n'est pas `lo`) et son nom d'interface.
2. `ip r` : la passerelle par défaut (ligne `default via …`).
3. `ss -tlnp` (avec `sudo` pour voir les noms de processus) : la liste des ports TCP en écoute et le processus derrière chacun.
4. `curl -I http://ubuntu.com` : le code de réponse HTTP de la première ligne (que signifie-t-il ?).
5. `dig +short ubuntu.com` : la ou les adresses IPv4 renvoyées.

Résultat attendu : cinq relevés exploitables — IP de la VM, passerelle, tableau des ports en écoute (au minimum le port 53 de `systemd-resolved` sur 127.0.0.54, et le port 22 si le serveur SSH est installé), un code HTTP `301` pour ubuntu.com, et au moins une adresse IP publique renvoyée par dig.

### Partie 4 — Le mini-rapport d'audit

Rédigez le rapport `~/exploitation/rapports/audit.txt` avec nano (créez le répertoire si besoin : `mkdir -p ~/exploitation/rapports`). Plan imposé :

```text
RAPPORT D'AUDIT — srv-linux — 2026-07-02 — auteur : <votre nom>

1. DISQUE
   - Occupation de / (df -h) : … % sur … Go
   - Répertoire anormal identifié : chemin, taille, nombre de fichiers
   - Méthode utilisée (2-3 lignes)
   - Recommandation (garder / supprimer / investiguer, et pourquoi)

2. STOCKAGE
   - Périphérique portant / (lsblk) : …
   - Ligne fstab correspondante et mode de désignation : …

3. RÉSEAU
   - Interface et adresse IPv4 : …
   - Passerelle par défaut : …
   - Ports TCP en écoute (port -> processus) : …
   - Test web sortant (curl -I http://ubuntu.com) : code HTTP …
   - Résolution DNS (dig +short ubuntu.com) : …

4. CONCLUSION (3 lignes max)
```

Remplacez chaque `…` par vos relevés réels. Terminez par un contrôle : `cat ~/exploitation/rapports/audit.txt`.

Résultat attendu : un fichier texte complet suivant le plan, sans rubrique vide, lisible par quelqu'un qui n'a pas accès au serveur.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — du ne montre pas le coupable ?</summary>

Sans `sudo`, `du` ne peut pas entrer dans certains répertoires et sous-estime les tailles (d'où le `2>/dev/null` pour masquer les « Permission denied »). Pensez aussi que `sort -h` trie les tailles « humaines » (500M après 3,4M) : le coupable est en bas de la liste. Enchaînement type : `/var` → `/var/tmp` → `/var/tmp/cache-app`.

</details>

<details>
<summary>Indice 2 — Lire ss -tlnp</summary>

`t` = TCP, `l` = listening (en écoute), `n` = numérique (pas de résolution de noms), `p` = processus. La colonne `Local Address:Port` donne le port ; `127.0.0.1:x` ou `127.0.0.54:x` = accessible seulement en local, `0.0.0.0:x` ou `*:x` = accessible depuis le réseau. Lancez-la avec `sudo` sinon la colonne processus reste vide pour les services système.

</details>

<details>
<summary>Indice 3 — curl -I renvoie 301, est-ce une erreur ?</summary>

Non : `301 Moved Permanently` est une redirection (ici de `http://` vers `https://`). Pour l'audit, cela prouve deux choses : la résolution DNS fonctionne ET le trafic sortant vers le port 80 passe. Vous pouvez suivre la redirection avec `curl -IL http://ubuntu.com` pour voir le `200` final.

</details>

## Pour aller plus loin (bonus)

1. Appliquez votre recommandation : supprimez les fichiers de cache (`sudo rm -r /var/tmp/cache-app`) puis prouvez le gain avec un nouveau `df -h` comparé au relevé du rapport — ajoutez une section « 5. NETTOYAGE EFFECTUÉ » au rapport.
2. Automatisez le relevé : écrivez `~/exploitation/scripts/releve-audit.sh` qui enchaîne `date`, `df -h`, `lsblk`, `ip a`, `ip r`, `sudo ss -tlnp` et redirige le tout dans `~/exploitation/rapports/releve-$(date +%Y%m%d).txt`. Vous venez d'écrire votre premier script de supervision — au bloc CL-AWS, CloudWatch fera ce travail en dashboard.
