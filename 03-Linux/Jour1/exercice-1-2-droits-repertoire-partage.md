# Exercice 1-2 — Droits d'un répertoire partagé

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 2 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Créer des utilisateurs et un groupe, et gérer les appartenances
- Attribuer des droits en notation octale, y compris le bit setgid (2770)
- Vérifier une politique de droits en vous mettant à la place de chaque
  utilisateur avec `su -`
- Expliquer l'effet du setgid sur un répertoire et le rôle de l'umask

## Prérequis

- Avoir suivi les parties « Utilisateurs, groupes, sudo » et « Permissions »
  du module 03 (jour 1)
- Environnement : VM `srv-linux` (Ubuntu Server 24.04 LTS sous Multipass) —
  connectez-vous avec `multipass shell srv-linux` depuis le poste hôte
- Outils : `adduser`, `groupadd`/`addgroup`, `usermod`, `chmod`, `chown`, `su`

## Contexte

Deux développeurs, Alice et Bruno, rejoignent le projet StockLine. Ils
travailleront tous les deux sur le serveur `srv-linux` et doivent partager des
fichiers dans un répertoire commun `/srv/partage`. Le responsable sécurité est
formel : **seuls les membres du groupe `projet` doivent pouvoir entrer dans ce
répertoire**, et tout fichier créé dedans doit automatiquement appartenir au
groupe, pour que chacun puisse travailler sur les fichiers de l'autre. Sur une
instance EC2 partagée entre plusieurs intervenants, c'est exactement le même
montage que l'on vous demandera.

## Énoncé

Toutes les commandes s'exécutent dans la VM (`multipass shell srv-linux`),
en tant qu'utilisateur `ubuntu` sauf indication contraire.

### Partie 1 — Créer les comptes et le groupe

1. Créez l'utilisateur `alice`, puis l'utilisateur `bruno`
   (avec `adduser` ; vous pouvez laisser les champs de renseignements vides
   en appuyant sur Entrée).
2. Définissez leurs mots de passe **exactement** comme suit (nécessaire pour
   les tests avec `su -` de la partie 3) :
   - `alice` → mot de passe `Formation2026!`
   - `bruno` → mot de passe `Formation2026!`
   Si `adduser` vous a déjà demandé le mot de passe, c'est fait ; sinon
   utilisez `sudo passwd alice` puis `sudo passwd bruno`.
3. Créez le groupe `projet`.
4. Ajoutez `alice` et `bruno` au groupe `projet` (sans toucher à leur groupe
   principal).

Résultat attendu :

```bash
getent group projet
```

```text
projet:x:1003:alice,bruno
```

(le numéro de groupe peut différer ; l'important est de voir `alice,bruno`).
`id alice` doit mentionner `projet` dans la liste `groups=`.

### Partie 2 — Le répertoire partagé en 2770

1. Créez le répertoire `/srv/partage`.
2. Donnez-le au propriétaire `root` et au groupe `projet`.
3. Appliquez les droits `2770`. Avant de taper la commande, décomposez à voix
   haute (ou sur papier) ce que signifie chaque chiffre : `2`, `7`, `7`, `0`.
4. Vérifiez le résultat avec `ls -ld /srv/partage`.

Résultat attendu :

```bash
ls -ld /srv/partage
```

```text
drwxrws--- 2 root projet 4096 Jul  6 10:30 /srv/partage
```

Notez le `s` à la place du `x` du groupe : c'est le setgid.

### Partie 3 — Tests croisés : mettez-vous à leur place

Pour chaque test, ouvrez une session avec `su - alice` ou `su - bruno`
(mot de passe `Formation2026!`), puis revenez avec `exit`.

1. En tant qu'`alice` : placez-vous dans `/srv/partage` et créez le fichier
   `note-alice.txt` contenant la ligne `pense-bete d'alice` (redirection).
2. Toujours en tant qu'`alice` : affichez le fichier en détail avec `ls -l`.
   **Question A** : à quel groupe appartient le fichier ? Pourquoi n'est-ce
   pas le groupe `alice` ?
3. En tant que `bruno` : lisez `note-alice.txt`, puis ajoutez-y la ligne
   `relu par bruno` (redirection `>>`). Créez ensuite votre propre fichier
   `note-bruno.txt`.
4. De retour en tant qu'`ubuntu` (sans `sudo`) : essayez de lister
   `/srv/partage`. **Question B** : que se passe-t-il, et quel chiffre du
   mode `2770` en est responsable ?
5. **Question C** : en tant qu'`alice`, exécutez la commande `umask`.
   En combinant sa valeur et le setgid, expliquez pourquoi `bruno` a pu
   modifier le fichier d'`alice`.

Résultat attendu :

```bash
sudo ls -l /srv/partage
```

```text
total 8
-rw-rw-r-- 1 alice projet 34 Jul  6 10:35 note-alice.txt
-rw-rw-r-- 1 bruno projet 15 Jul  6 10:36 note-bruno.txt
```

et `cat /srv/partage/note-alice.txt` (en tant qu'alice ou bruno) affiche les
deux lignes. Le `ls` de l'étape 4 en tant qu'`ubuntu` doit être **refusé**
(`Permission denied`).

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — ajouter à un groupe sans casser le reste</summary>

`sudo usermod -aG projet alice` : le `-a` (append) est crucial. Sans lui,
`-G` **remplace** la liste des groupes secondaires. Une session déjà ouverte
ne voit pas le nouveau groupe : refaites `su - alice` après l'ajout.

</details>

<details>
<summary>Indice 2 — lire le mode 2770</summary>

Le premier chiffre porte les bits spéciaux : `4` = setuid, `2` = setgid,
`1` = sticky. Les trois suivants sont les classiques propriétaire / groupe /
autres. `chmod 2770` = setgid + `rwx` pour root, `rwx` pour le groupe
`projet`, rien pour les autres.

</details>

<details>
<summary>Indice 3 — le setgid sur un répertoire</summary>

Sans setgid, un fichier créé prend le **groupe principal** de son créateur
(`alice` pour alice). Avec setgid sur le répertoire, il **hérite du groupe du
répertoire** (`projet`). L'umask, elle, décide des droits `rw` accordés au
groupe sur ce nouveau fichier.

</details>

## Pour aller plus loin (bonus)

Le chef de projet décide qu'Alice devient administratrice déléguée du serveur.

1. Ajoutez `alice` au groupe `sudo`.
2. En tant qu'`alice`, prouvez que ça fonctionne : `sudo whoami` doit répondre
   `root` (mot de passe demandé : celui d'`alice`).
3. Vérifiez dans les journaux que cette élévation de privilèges a laissé une
   trace (`sudo journalctl -t sudo -n 5` en tant qu'`ubuntu`, ou regardez
   `/var/log/auth.log`) : sur un serveur de production, **tout usage de sudo
   est audité** — c'est l'une des raisons de préférer sudo à root.
