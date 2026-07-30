# Exercice 4-1 — Accès SSH par clés et config client

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 2 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Générer une paire de clés SSH ed25519 et installer manuellement la clé publique sur un serveur
- Simplifier vos connexions avec un fichier `~/.ssh/config`
- Transférer un dossier avec `scp` puis `rsync` et expliquer quand préférer l'un ou l'autre

## Prérequis

- Avoir suivi la partie « SSH en profondeur » du module 03 (jour 4)
- Environnement : votre **poste hôte** (macOS, Windows ou Linux — le client OpenSSH est fourni partout : Terminal, PowerShell ou shell Linux) + la VM Multipass `srv-linux` (Ubuntu Server 24.04 LTS)
- Outils : ssh, ssh-keygen, scp, rsync, multipass

> ⚠️ Tout l'exercice se joue **depuis le poste hôte**, sauf mention explicite « sur la VM ». C'est le scénario réel : votre poste = votre machine de travail, la VM = l'instance cloud distante.

## Contexte

Votre équipe vous confie un serveur sur lequel un compte de déploiement `deploy` doit être créé : c'est ce compte que les scripts et les futurs pipelines utiliseront pour pousser du code. Règle de la maison : **jamais de mot de passe SSH**, uniquement des clés — exactement comme sur EC2, où l'authentification par clé (key pair) est le seul mode de connexion par défaut. Vous allez créer la paire de clés, préparer le compte, installer la clé publique **à la main** (pour comprendre ce que `ssh-copy-id` fait à votre place), puis transférer un premier dossier de scripts.

## Énoncé

### Partie 0 — Relever l'adresse IP de la VM

Sur le poste hôte :

```bash
multipass info srv-linux
```

Notez la ligne `IPv4` (par exemple `10.204.28.15`). Dans toute la suite, remplacez `IP-VM` par cette adresse.

Résultat attendu : vous connaissez l'adresse IPv4 de la VM et `ping IP-VM` (ou un simple `curl`/`ssh` plus tard) confirme qu'elle est joignable.

### Partie 1 — Générer la paire de clés sur le poste hôte

1. Générez une paire ed25519 dans un fichier dédié (ne touchez pas à vos clés existantes) :
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/formation_ed25519 -C "formation-admin-cloud"
   ```
   Choisissez une passphrase (recommandé) ou laissez vide pour l'exercice.
2. Examinez ce qui a été créé : `ls -l ~/.ssh/formation_ed25519*`. Quel fichier est la clé privée ? La clé publique ? Lequel ne doit **jamais** quitter votre poste ?
3. Affichez la clé publique : `cat ~/.ssh/formation_ed25519.pub` — c'est cette ligne unique (commençant par `ssh-ed25519`) que vous installerez sur le serveur.

Résultat attendu : deux fichiers `formation_ed25519` (privée) et `formation_ed25519.pub` (publique) ; vous savez lesquels sont secrets et le contenu de la `.pub` tient sur une ligne.

### Partie 2 — Créer l'utilisateur deploy sur la VM

Ouvrez une session sur la VM avec `multipass shell srv-linux` (c'est notre « accès console », l'équivalent de la console EC2 quand SSH n'est pas encore prêt), puis :

1. Créez l'utilisateur : `sudo adduser deploy` (donnez-lui un mot de passe — il servira de secours pendant l'exercice — et validez les questions avec Entrée).
2. Vérifiez : `id deploy`.

Restez connecté à la VM pour la partie 3.

Résultat attendu : `id deploy` affiche un uid, un gid et le groupe `deploy`.

### Partie 3 — Installer la clé publique À LA MAIN

Toujours sur la VM, préparez le terrain pour `deploy`. La clé publique doit finir dans `/home/deploy/.ssh/authorized_keys`, avec des droits stricts, sinon sshd la refusera :

1. Créez le répertoire et le fichier (en tant qu'administrateur) :
   ```bash
   sudo mkdir -p /home/deploy/.ssh
   sudo touch /home/deploy/.ssh/authorized_keys
   ```
2. Copiez la ligne `ssh-ed25519 …` affichée en partie 1 sur votre poste, puis sur la VM ouvrez le fichier avec `sudo nano /home/deploy/.ssh/authorized_keys` et collez-la (une seule ligne, sans retour à la ligne au milieu).
3. Appliquez les droits exigés par sshd :
   ```bash
   sudo chmod 700 /home/deploy/.ssh
   sudo chmod 600 /home/deploy/.ssh/authorized_keys
   sudo chown -R deploy:deploy /home/deploy/.ssh
   ```
4. Contrôlez : `sudo ls -la /home/deploy/.ssh` doit montrer `drwx------` pour le répertoire et `-rw-------` pour le fichier, propriétaire `deploy`.

Depuis le **poste hôte**, testez :

```bash
ssh -i ~/.ssh/formation_ed25519 deploy@IP-VM
```

À la première connexion, répondez `yes` à la question sur l'empreinte de la clé du serveur. Vous devez arriver sur un prompt `deploy@srv-linux:~$` **sans** saisie de mot de passe (la passphrase de la clé, si vous en avez mis une, peut être demandée : ce n'est pas le mot de passe du compte). Déconnectez-vous avec `exit`.

Résultat attendu : connexion `deploy@srv-linux` réussie par clé, sans mot de passe du compte.

### Partie 4 — Le fichier ~/.ssh/config

Taper `ssh -i … deploy@IP-VM` à chaque fois est pénible. Sur le poste hôte, créez (ou complétez) `~/.ssh/config` avec un bloc :

```text
Host srv-linux
    HostName IP-VM
    User deploy
    IdentityFile ~/.ssh/formation_ed25519
```

(Remplacez `IP-VM` par la vraie adresse.) Puis testez : `ssh srv-linux` doit vous connecter directement en `deploy`.

Résultat attendu : `ssh srv-linux` ouvre une session `deploy@srv-linux` ; `ssh srv-linux hostname` renvoie `srv-linux` sans ouvrir de session interactive.

### Partie 5 — Transférer un dossier : scp puis rsync

Sur le poste hôte, fabriquez un petit dossier de travail :

```bash
mkdir -p ~/transfert-demo
echo "script un" > ~/transfert-demo/script1.sh
echo "script deux" > ~/transfert-demo/script2.sh
echo "lisez-moi" > ~/transfert-demo/LISEZMOI.txt
```

1. **scp** : copiez le dossier complet vers le serveur :
   ```bash
   scp -r ~/transfert-demo srv-linux:~/transfert-scp
   ```
2. **rsync** : copiez le même dossier avec :
   ```bash
   rsync -av ~/transfert-demo/ srv-linux:~/transfert-rsync/
   ```
   (Notez les `/` finals : avec rsync ils comptent.)
3. **Comparez** : modifiez UN fichier (`echo "v2" >> ~/transfert-demo/script1.sh`) puis relancez les deux commandes ci-dessus. Observez la sortie de rsync : que transfère-t-il ? Et scp ? Vérifiez sur le serveur (`ssh srv-linux ls -l transfert-scp transfert-rsync`).
4. Rédigez en 2-3 phrases (dans `~/transfert-demo/comparatif.txt` sur le poste) : lequel choisir pour un déploiement répété, et pourquoi.

Résultat attendu : les deux dossiers existent sur la VM avec les 3 fichiers ; au second passage, la sortie de rsync ne liste que `script1.sh` (seul fichier modifié) alors que scp recopie tout ; votre comparatif conclut en faveur de rsync pour les déploiements répétés.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — « Permission denied (publickey) » au test de la partie 3</summary>

Dans 90 % des cas c'est un problème de droits ou de propriétaire : `~/.ssh` doit être en `700`, `authorized_keys` en `600`, et les DEUX doivent appartenir à `deploy` (pas à root — c'est l'oubli du `chown -R deploy:deploy`). Vérifiez aussi que la ligne collée est complète et unique : `sudo cat /home/deploy/.ssh/authorized_keys | wc -l` doit renvoyer 1. Côté serveur, les refus se lisent dans `sudo journalctl -u ssh -n 20`.

</details>

<details>
<summary>Indice 2 — ssh srv-linux demande encore un mot de passe</summary>

Vérifiez le fichier `~/.ssh/config` du poste : les directives sont sensibles à l'indentation zéro près mais pas à la casse ; le piège classique est un `Host srv-linux` correct mais un `HostName` resté sur `IP-VM` littéral, ou un chemin `IdentityFile` erroné. Testez en mode bavard : `ssh -v srv-linux 2>&1 | grep -i identity` montre quelles clés sont proposées.

</details>

<details>
<summary>Indice 3 — rsync : le rôle des / finals</summary>

`rsync -av ~/transfert-demo/ srv-linux:~/transfert-rsync/` copie le **contenu** du dossier source dans la destination. Sans le `/` final sur la source, rsync créerait `~/transfert-rsync/transfert-demo/…` (le dossier lui-même dedans). Règle mnémotechnique : « slash final = le contenu, pas la boîte ».

</details>

## Pour aller plus loin (bonus)

Si vous avez protégé votre clé par une passphrase, elle est demandée à chaque connexion. Mettez en place `ssh-agent` :

1. Démarrez l'agent si nécessaire : `eval "$(ssh-agent -s)"` (sur macOS et la plupart des Linux de bureau, il tourne déjà ; sous Windows, activez le service « OpenSSH Authentication Agent »).
2. Chargez la clé : `ssh-add ~/.ssh/formation_ed25519` (la passphrase est demandée une seule fois).
3. Vérifiez : `ssh-add -l` liste l'empreinte de la clé, puis `ssh srv-linux` se connecte sans rien demander.
4. Question de réflexion : où la passphrase est-elle conservée, et que se passe-t-il au redémarrage du poste ?
