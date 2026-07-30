# Solution — Exercice 1-2 : Droits d'un répertoire partagé

## Approche pédagogique

Le montage « groupe + setgid + 2770 » est LE cas d'école des permissions Unix,
et il ressert tel quel en production (répertoires d'équipe sur serveur mutualisé,
répertoires de dépôt sur EC2). La difficulté n'est pas dans les commandes mais
dans la **compréhension** : pourquoi le `s`, pourquoi le groupe hérite, ce que
l'umask ajoute. Exiger les tests croisés avec `su -` : c'est en se mettant dans
la peau d'alice puis de bruno que les droits deviennent concrets. Les trois
questions (A, B, C) sont le cœur de l'exercice — les faire verbaliser.

## Solution détaillée

Connexion : `multipass shell srv-linux` (utilisateur `ubuntu`).

### Partie 1 — Créer les comptes et le groupe

```bash
sudo adduser --gecos "" alice
# New password: Formation2026!
# Retype new password: Formation2026!

sudo adduser --gecos "" bruno
# New password: Formation2026!
# Retype new password: Formation2026!

sudo addgroup projet
sudo usermod -aG projet alice
sudo usermod -aG projet bruno
```

Explication :

- `adduser` (l'outil convivial de Debian/Ubuntu) crée l'utilisateur, son
  groupe principal éponyme, son répertoire `/home/<nom>` et demande le mot de
  passe ; `--gecos ""` saute les questions « Full Name, Room Number… ».
  Si les mots de passe n'ont pas été saisis à ce moment-là :
  `sudo passwd alice` puis `sudo passwd bruno` (saisir `Formation2026!`).
- `addgroup projet` crée un groupe vide (variante bas niveau : `groupadd`).
- `usermod -aG projet <user>` : `-G` = groupes secondaires, `-a` = **append**.
  Sans `-a`, la liste des groupes secondaires est remplacée — c'est le piège
  n° 1 de la gestion des groupes.

Vérification :

```bash
getent group projet
# projet:x:1003:alice,bruno
id alice
# uid=1001(alice) gid=1001(alice) groups=1001(alice),1003(projet)
id bruno
# uid=1002(bruno) gid=1002(bruno) groups=1002(bruno),1003(projet)
```

(les uid/gid exacts peuvent varier selon l'historique de la VM).

### Partie 2 — Le répertoire partagé en 2770

```bash
sudo mkdir -p /srv/partage
sudo chown root:projet /srv/partage
sudo chmod 2770 /srv/partage
ls -ld /srv/partage
```

Sortie attendue :

```text
drwxrws--- 2 root projet 4096 Jul  6 10:30 /srv/partage
```

Décomposition du mode `2770` :

- `2` (bits spéciaux) : **setgid** — tout fichier ou sous-répertoire créé ici
  héritera du groupe `projet` au lieu du groupe principal du créateur.
- `7` (propriétaire, root) : `rwx`.
- `7` (groupe projet) : `rwx` — lire, écrire, traverser.
- `0` (autres) : aucun droit — c'est la garantie « seul le groupe entre ».

Dans `ls -ld`, le setgid se lit au `s` minuscule à la place du `x` du groupe
(`rws`). Un `S` majuscule signifierait « setgid posé mais x absent » — signe
d'une erreur de mode.

- `chown root:projet` : root reste propriétaire (personne de l'équipe n'a de
  raison de changer les droits du répertoire), le groupe porte l'accès.
- L'ordre chown puis chmod importe peu ici ; certaines versions de chown
  réinitialisant les bits spéciaux, faire le `chmod 2770` **en dernier** est
  la bonne habitude.

### Partie 3 — Tests croisés

Test 1 et 2 — alice crée et observe :

```bash
su - alice          # mot de passe : Formation2026!
cd /srv/partage
echo "pense-bete d'alice" > note-alice.txt
ls -l
# -rw-rw-r-- 1 alice projet 19 Jul  6 10:35 note-alice.txt
umask
# 0002
exit
```

**Question A — réponse** : le fichier appartient au groupe `projet`, pas au
groupe `alice`, à cause du **setgid** posé sur `/srv/partage` : un répertoire
setgid transmet SON groupe à tout ce qui est créé dedans. Sans lui, le fichier
serait `alice:alice` et bruno ne pourrait pas travailler dessus via le groupe.

Test 3 — bruno lit, modifie, crée :

```bash
su - bruno          # mot de passe : Formation2026!
cd /srv/partage
cat note-alice.txt
# pense-bete d'alice
echo "relu par bruno" >> note-alice.txt
echo "note de bruno" > note-bruno.txt
ls -l
# -rw-rw-r-- 1 alice projet 34 Jul  6 10:36 note-alice.txt
# -rw-rw-r-- 1 bruno projet 15 Jul  6 10:36 note-bruno.txt
exit
```

Test 4 — ubuntu (hors groupe) est refusé :

```bash
ls /srv/partage
# ls: cannot open directory '/srv/partage': Permission denied
```

**Question B — réponse** : `ubuntu` n'est ni `root` ni membre de `projet` :
il tombe dans la catégorie « autres », dont les droits sont le **dernier
chiffre `0`** de `2770` — aucun droit, donc ni lecture ni traversée.
(`sudo ls /srv/partage` passerait, évidemment : root contourne les droits —
d'où l'importance de contrôler qui a sudo.)

**Question C — réponse** : `umask` vaut `0002` pour alice (défaut Ubuntu pour
les utilisateurs dont le groupe principal porte leur nom). Un fichier se crée
en `666 − 002 = 664`, soit `rw-rw-r--` : **le groupe a le droit d'écriture**.
Combiné au setgid (groupe = `projet`), bruno — membre de `projet` — peut donc
modifier le fichier d'alice. Deux mécanismes complémentaires : le setgid donne
le *bon groupe*, l'umask donne les *bons droits* à ce groupe. Avec une umask
`022`, le fichier serait `644` et bruno pourrait lire mais pas modifier.

## Variantes acceptables

1. `groupadd projet` au lieu de `addgroup projet` :
   - Avantage : commande bas niveau portable sur toutes les distributions.
   - Inconvénient : aucune ici ; `addgroup` est simplement l'habillage Debian.
2. `sudo adduser alice projet` pour l'ajout au groupe (syntaxe Debian
   `adduser <user> <group>`), équivalente à `usermod -aG` : parfaitement
   acceptable.
3. `chmod g+s /srv/partage` après un `chmod 770` : strictement équivalent à
   `2770`, et pédagogiquement intéressant (notation symbolique vs octale).
4. `sudo -u alice bash` au lieu de `su - alice` : fonctionne, mais `su -`
   charge l'environnement de connexion complet (dont l'umask) — préférable ici.


## Bonus

```bash
sudo usermod -aG sudo alice

su - alice          # mot de passe : Formation2026!
sudo whoami         # mot de passe demandé : Formation2026! (celui d'alice)
# root
exit
```

Sur Ubuntu, l'appartenance au groupe `sudo` suffit : le fichier
`/etc/sudoers` contient `%sudo ALL=(ALL:ALL) ALL`. Aucune édition de sudoers
n'est nécessaire (et on n'édite jamais sudoers sans `visudo`).

Trace d'audit :

```bash
sudo journalctl -t sudo -n 5 --no-pager
```

Sortie attendue (extrait) :

```text
Jul 06 10:52:14 srv-linux sudo[2417]:    alice : TTY=pts/1 ; PWD=/home/alice ;
USER=root ; COMMAND=/usr/bin/whoami
```

(également visible dans `/var/log/auth.log`, lisible par le groupe `adm`).
Message clé : chaque commande sudo est nominative et horodatée — c'est
pourquoi, sur les serveurs cloud, on travaille avec sudo et jamais connecté
en root.
