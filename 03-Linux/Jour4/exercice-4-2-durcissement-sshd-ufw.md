# Exercice 4-2 — Durcissement sshd et pare-feu ufw

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 3 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Durcir la configuration du serveur SSH via un drop-in dans `/etc/ssh/sshd_config.d/` et la valider avec `sshd -t` avant tout redémarrage
- Prouver qu'une politique de sécurité est effective (tester le refus, pas seulement l'acceptation)
- Activer ufw sans vous couper l'accès, en autorisant SSH avant l'activation

## Prérequis

- Avoir terminé l'exercice 4-1 (utilisateur `deploy` avec accès par clé + `~/.ssh/config` sur le poste hôte)
- Environnement : VM Multipass `srv-linux` (Ubuntu Server 24.04 LTS) + poste hôte ; IP de la VM : `multipass info srv-linux`
- Outils : sshd, ufw, nano, ssh (côté hôte)

> ⚠️ **Règle de la « corde de rappel »** : pendant TOUTE la durée de l'exercice, gardez ouverte une session `multipass shell srv-linux` dans un terminal dédié, et n'y touchez pas. Si une manipulation SSH ou pare-feu tourne mal, cette session console vous permet de réparer. Sur EC2 vous n'aurez pas toujours ce luxe : une erreur = instance injoignable. On apprend le réflexe ici, sans risque.

## Contexte

Le serveur du 4-1 va être exposé à Internet pour héberger StockLine. L'équipe sécurité impose sa checklist avant mise en production : connexion root interdite, mot de passe SSH interdit (clés uniquement), nombre d'essais limité, et pare-feu activé n'ouvrant que SSH et HTTP. C'est mot pour mot ce qu'on configure sur une instance cloud — sshd d'un côté, security group de l'autre. Et la règle d'or du métier s'applique : **on ne redémarre jamais un sshd sans avoir validé sa configuration**, et **on n'active jamais un pare-feu sans avoir autorisé le port par lequel on est connecté**.

## Énoncé

### Partie 1 — Le drop-in de durcissement

Sur la VM (session « corde de rappel » via `multipass shell srv-linux`) :

1. Regardez comment Ubuntu 24.04 organise la configuration : `ls /etc/ssh/sshd_config.d/` et la ligne `Include` en tête de `/etc/ssh/sshd_config` (`head -5 /etc/ssh/sshd_config`). Pourquoi créer un fichier séparé plutôt que modifier `sshd_config` directement ?
2. Créez le drop-in `/etc/ssh/sshd_config.d/90-durcissement.conf` (avec `sudo nano`) contenant exactement :
   ```text
   PermitRootLogin no
   PasswordAuthentication no
   MaxAuthTries 3
   ```
3. **AVANT tout redémarrage**, validez la syntaxe :
   ```bash
   sudo sshd -t
   ```
   Silence = configuration valide. Pour vérifier les valeurs réellement prises en compte : `sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|maxauthtries'`.
4. Seulement maintenant : `sudo systemctl restart ssh`, puis `systemctl status ssh` (doit être `active (running)`).

Résultat attendu : `sudo sshd -t` ne renvoie rien, `sudo sshd -T` montre les trois directives aux bonnes valeurs, le service `ssh` est actif après restart, et votre session corde de rappel est toujours vivante.

### Partie 2 — Prouver que le mot de passe est refusé

Une politique de sécurité ne se déclare pas, elle se **teste**. Depuis le **poste hôte** :

1. La connexion par clé fonctionne toujours : `ssh srv-linux hostname` (doit répondre `srv-linux`).
2. Forcez une tentative par mot de passe, qui doit échouer :
   ```bash
   ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password deploy@IP-VM
   ```
   (Remplacez `IP-VM` par l'adresse de `multipass info srv-linux`.)
3. Notez le message obtenu. Sur la VM, retrouvez la trace de ce refus dans les journaux : `sudo journalctl -u ssh -n 20`.

Résultat attendu : la connexion par clé passe ; la tentative par mot de passe est rejetée immédiatement avec `Permission denied (publickey).` — le serveur ne demande même plus de mot de passe ; le journal montre la connexion refusée.

### Partie 3 — Activer ufw dans le bon ordre

Toujours en gardant la corde de rappel ouverte. Sur la VM :

1. État des lieux : `sudo ufw status` (doit répondre `Status: inactive` — ufw est installé mais inactif par défaut sur Ubuntu Server).
2. **AVANT d'activer**, autorisez ce qui doit rester ouvert :
   ```bash
   sudo ufw allow OpenSSH
   sudo ufw allow 80/tcp
   ```
   Question : que désigne le profil `OpenSSH` et où est-il défini ? (Piste : `sudo ufw app list` et `sudo ufw app info OpenSSH`.)
3. Activez : `sudo ufw enable` (confirmez par `y` : l'avertissement sur les connexions SSH existantes est justement la raison de l'étape 2).
4. Contrôlez : `sudo ufw status verbose`. Relevez la politique par défaut en entrée et en sortie, et les règles listées.
5. Contre-épreuve depuis le poste hôte : `ssh srv-linux hostname` fonctionne toujours (le port 22 est passé), et depuis la VM `curl -I http://ubuntu.com` fonctionne toujours (le trafic sortant n'est pas bloqué).

Résultat attendu : `sudo ufw status verbose` affiche `Status: active`, politique par défaut `deny (incoming), allow (outgoing)`, et les règles `OpenSSH ALLOW` et `80/tcp ALLOW` (en IPv4 et IPv6) ; la connexion SSH depuis l'hôte fonctionne toujours.

### Partie 4 — Bilan sécurité

Dans `~/exploitation/rapports/durcissement.txt` sur la VM, consignez en quelques lignes : les trois directives sshd appliquées et leur effet, le test de refus réalisé (commande + message), les règles ufw actives, et une phrase de correspondance cloud : à quoi correspondent respectivement le drop-in sshd et ufw sur une instance EC2 ?

Résultat attendu : un fichier de synthèse complet ; pour la correspondance : le durcissement sshd se retrouve tel quel sur l'instance, ufw a pour cousin le security group (filtrage en amont de la VM).

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — sshd -t signale une erreur</summary>

Le message donne le fichier et la ligne, par exemple `/etc/ssh/sshd_config.d/90-durcissement.conf: line 2: Bad configuration option`. Causes fréquentes : faute de frappe dans le nom de directive (`PasswordAuthentification` à la française au lieu de `PasswordAuthentication`), guillemets copiés depuis un traitement de texte. Corrigez, relancez `sudo sshd -t` jusqu'au silence complet. Tant que `sshd -t` râle, ne faites PAS le restart : c'est tout l'intérêt de la commande.

</details>

<details>
<summary>Indice 2 — La directive semble ignorée par sshd -T</summary>

Dans sshd, **la première occurrence d'une directive gagne**. Si un autre fichier de `/etc/ssh/sshd_config.d/` (par exemple `50-cloud-init.conf`, présent sur les images cloud) définit déjà `PasswordAuthentication`, il est lu avant ou après le vôtre selon l'ordre alphabétique des noms de fichiers. Vérifiez avec `grep -r PasswordAuthentication /etc/ssh/sshd_config.d/` ; c'est précisément pour passer en premier que notre fichier pourrait s'appeler `10-…` — vérifiez ce que donne `sudo sshd -T` et, si besoin, renommez le fichier avec un préfixe plus petit que celui du fichier concurrent.

</details>

<details>
<summary>Indice 3 — Peur de perdre la main avec ufw ?</summary>

C'est le but de la corde de rappel : la session `multipass shell` ne passe PAS par le réseau SSH classique, elle survivra à une erreur de pare-feu. En cas de blocage : dans cette session, `sudo ufw disable` remet tout à plat, puis reprenez à l'étape 2 (allow AVANT enable). Sur une vraie instance cloud, l'équivalent de cette corde est la console série / EC2 Instance Connect… quand elle existe.

</details>

## Pour aller plus loin (bonus)

### Bonus 1 — Changer le port SSH (2222)

1. Ajoutez `Port 2222` dans `90-durcissement.conf`, validez avec `sudo sshd -t`, puis **avant** de redémarrer, ouvrez le nouveau port : `sudo ufw allow 2222/tcp`. Redémarrez : `sudo systemctl restart ssh` (sur Ubuntu 24.04, le socket systemd suit la directive Port du fichier de configuration ; vérifiez avec `sudo ss -tlnp | grep ssh`).
2. Depuis l'hôte : `ssh -p 2222 deploy@IP-VM hostname`, puis mettez à jour le bloc `Host srv-linux` de `~/.ssh/config` avec `Port 2222`.
3. Listez TOUTES les conséquences d'un changement de port (règle ufw, config client, scripts rsync/scp existants, supervision) — c'est pour cela que beaucoup d'équipes gardent le 22 et misent sur clés + fail2ban.
4. Nettoyage conseillé : retirez `Port 2222` et la ligne de `~/.ssh/config`, `sudo sshd -t`, restart, `sudo ufw delete allow 2222/tcp` — le TP du jour suppose le port 22.

### Bonus 2 — fail2ban en lecture

1. Installez : `sudo apt update && sudo apt install -y fail2ban`.
2. Sur Ubuntu 24.04, activez la prison sshd (le paquet la fournit prête à l'emploi) : `sudo systemctl enable --now fail2ban`, puis observez :
   ```bash
   sudo fail2ban-client status
   sudo fail2ban-client status sshd
   ```
3. Lisez les compteurs (`Currently failed`, `Total banned`) : que ferait fail2ban si une IP enchaînait les `Permission denied` de la partie 2 ? Où fail2ban lit-il les échecs, et avec quoi bannit-il ? (Réponses attendues : journaux d'authentification ; règles de pare-feu temporaires.)
