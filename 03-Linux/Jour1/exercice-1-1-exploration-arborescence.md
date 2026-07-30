# Exercice 1-1 — Exploration et manipulation de l'arborescence

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 1 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Vous déplacer dans l'arborescence d'un serveur Linux avec `pwd`, `cd` et `ls`
- Créer, copier, déplacer, renommer et supprimer fichiers et répertoires
- Lire un fichier de journal avec `less`, `head` et `tail`
- Trouver une option de commande par vous-même avec `man`

## Prérequis

- Avoir suivi la partie « Naviguer et manipuler » du module 03 (jour 1)
- Environnement : VM `srv-linux` (Ubuntu Server 24.04 LTS sous Multipass) —
  connectez-vous avec `multipass shell srv-linux` depuis le poste hôte
- Outils : le terminal, rien d'autre — tout est déjà présent sur la VM

## Contexte

Vous venez d'arriver dans l'équipe infrastructure. On vous confie votre premier
serveur, `srv-linux`, et une consigne simple : « organisez votre espace de
travail comme tout le monde ici ». La convention de l'équipe : chaque
administrateur dispose dans son répertoire personnel d'un dossier `exploitation`
contenant trois sous-dossiers — `scripts` (vos futurs scripts), `rapports`
(les relevés que vous produisez) et `archives` (les anciens rapports).
Pas d'interface graphique, pas de souris : sur un serveur cloud, tout se fait
au clavier — exactement comme sur une instance EC2.

## Énoncé

Toutes les commandes s'exécutent dans la VM, connecté en tant qu'utilisateur
`ubuntu` :

```bash
multipass shell srv-linux
```

### Partie 1 — Construire l'arborescence de travail

1. Affichez votre répertoire courant et vérifiez que vous êtes bien dans
   `/home/ubuntu`.
2. Créez le répertoire `exploitation` dans votre répertoire personnel, puis
   les trois sous-répertoires `scripts`, `rapports` et `archives`.
   Essayez de le faire en **une seule commande**.
3. Placez-vous dans `~/exploitation` et listez son contenu en affichage
   détaillé (droits, propriétaire, date).

Résultat attendu : la commande `ls -l ~/exploitation` affiche exactement trois
lignes commençant par `d` (des répertoires) : `archives`, `rapports`, `scripts`.

### Partie 2 — Créer, copier, renommer, déplacer

1. Dans `~/exploitation/rapports`, créez un fichier vide nommé `brouillon.txt`.
2. Écrivez la ligne `Relevé initial du serveur srv-linux` dans un fichier
   `releve.txt` du même répertoire (avec une redirection `>`, sans éditeur).
3. Copiez `releve.txt` sous le nom `releve-2026-07-06.txt`, toujours dans
   `rapports/`.
4. L'original ne sert plus : **déplacez** `releve.txt` dans `archives/`.
5. `brouillon.txt` était une erreur : supprimez-le.
6. Copiez le fichier système `/etc/hostname` dans `rapports/` sous le nom
   `identite-machine.txt`, puis affichez son contenu avec `cat`.

Résultat attendu :

```bash
ls ~/exploitation/rapports ~/exploitation/archives
```

```text
/home/ubuntu/exploitation/archives:
releve.txt

/home/ubuntu/exploitation/rapports:
identite-machine.txt  releve-2026-07-06.txt
```

### Partie 3 — Lire les journaux du serveur

Les journaux vivent dans `/var/log`. C'est là que vous irez chercher les
indices le jour où « ça ne marche plus ».

1. Listez le contenu de `/var/log` en affichage détaillé. Repérez
   `dpkg.log` (journal du gestionnaire de paquets) et `cloud-init.log`
   (journal de l'initialisation de la VM).
2. Ouvrez `/var/log/cloud-init.log` avec `less` : descendez d'une page
   (barre d'espace), remontez (`b`), cherchez le mot `finished` (`/finished`
   puis Entrée, `n` pour l'occurrence suivante), puis quittez (`q`).
3. Affichez uniquement les **10 premières lignes** de `/var/log/dpkg.log`,
   puis uniquement ses **5 dernières lignes**.
4. Enregistrez les 5 dernières lignes de `dpkg.log` dans
   `~/exploitation/rapports/dernieres-installations.txt`.

Résultat attendu : `cat ~/exploitation/rapports/dernieres-installations.txt`
affiche 5 lignes horodatées provenant du journal dpkg (`wc -l` sur ce fichier
répond `5`).

### Partie 4 — Se débrouiller avec man

Un bon administrateur ne connaît pas toutes les options par cœur : il sait
les retrouver.

1. Ouvrez le manuel de `ls` et trouvez l'option qui **trie les fichiers par
   date de modification, le plus récent en premier**. Testez-la sur `/var/log`.
2. Ouvrez le manuel de `tail` et trouvez l'option qui **affiche les nouvelles
   lignes au fur et à mesure qu'elles arrivent** (très utilisée sur les
   journaux). Testez-la sur `/var/log/syslog` si le fichier existe, sinon sur
   `/var/log/dpkg.log`, puis interrompez avec `Ctrl+C`.
3. Notez les deux options trouvées (nom et rôle, une ligne chacune) dans
   `~/exploitation/rapports/options-utiles.txt`.

Résultat attendu : `cat ~/exploitation/rapports/options-utiles.txt` affiche
deux lignes, une par option trouvée.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — créer plusieurs répertoires d'un coup</summary>

`mkdir` accepte plusieurs arguments, et l'option `-p` crée les parents
manquants. Regardez aussi du côté des accolades du shell :
`mkdir -p ~/exploitation/{scripts,rapports,archives}`.

</details>

<details>
<summary>Indice 2 — écrire dans un fichier sans éditeur</summary>

`echo "texte" > fichier.txt` crée le fichier et y écrit la ligne.
Attention : `>` écrase le fichier s'il existe déjà, `>>` ajoute à la fin.

</details>

<details>
<summary>Indice 3 — chercher dans une page man</summary>

Dans `man ls`, tapez `/` suivi d'un mot-clé (en anglais : `modification`,
`sort`…) puis Entrée ; `n` saute à l'occurrence suivante, `q` quitte.
Les options de tri de `ls` tiennent en une lettre.

</details>

## Pour aller plus loin (bonus)

1. Installez l'outil `tree` (`sudo apt update && sudo apt install -y tree`)
   et affichez votre arborescence `~/exploitation` sous forme d'arbre.
2. En **une seule commande**, créez dans `archives/` les sous-répertoires
   `2024`, `2025` et `2026` (pensez aux accolades).
3. Avec une option de `ls` trouvée dans `man`, affichez le contenu de
   `/var/log` trié par **taille décroissante**, tailles lisibles par un humain
   (Ko/Mo). C'est le réflexe n° 1 quand un disque se remplit.
