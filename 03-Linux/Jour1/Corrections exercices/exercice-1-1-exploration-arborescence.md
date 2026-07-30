# Solution — Exercice 1-1 : Exploration et manipulation de l'arborescence

## Approche pédagogique

Premier exercice du bloc : l'enjeu n'est pas la difficulté (1/5) mais la
**fluidité au clavier** et l'installation des réflexes (chemins relatifs vs
absolus, `~`, vérifier chaque action avec `ls`). Laisser les apprenants tâtonner
avec `man` en partie 4 : le but est justement qu'ils apprennent à chercher.
Circuler et repérer ceux qui confondent `>` et `>>`, ou `cp` et `mv` — ce sont
les deux confusions à corriger dès aujourd'hui. Marteler le parallèle cloud :
tout ce qui est fait ici se fait à l'identique sur une instance EC2 fraîche.

## Solution détaillée

Connexion préalable depuis le poste hôte :

```bash
multipass shell srv-linux
```

### Partie 1 — Construire l'arborescence de travail

Raisonnement : on part du répertoire personnel (`/home/ubuntu`), on crée tout
en une commande grâce à l'expansion d'accolades, et on vérifie immédiatement.

```bash
pwd
# /home/ubuntu

mkdir -p ~/exploitation/{scripts,rapports,archives}

cd ~/exploitation
ls -l
```

Sortie attendue :

```text
total 12
drwxrwxr-x 2 ubuntu ubuntu 4096 Jul  6 10:12 archives
drwxrwxr-x 2 ubuntu ubuntu 4096 Jul  6 10:12 rapports
drwxrwxr-x 2 ubuntu ubuntu 4096 Jul  6 10:12 scripts
```

Explication :

- `pwd` : affiche le répertoire courant ; à la connexion c'est `$HOME`,
  soit `/home/ubuntu`.
- `mkdir -p ~/exploitation/{scripts,rapports,archives}` : le shell développe
  les accolades en trois chemins ; `-p` crée le parent `exploitation` au
  passage et ne râle pas s'il existe déjà.
- `ls -l` : le `d` en tête de ligne confirme que ce sont des répertoires.

### Partie 2 — Créer, copier, renommer, déplacer

```bash
cd ~/exploitation/rapports

touch brouillon.txt
echo "Relevé initial du serveur srv-linux" > releve.txt
cp releve.txt releve-2026-07-06.txt
mv releve.txt ../archives/
rm brouillon.txt
cp /etc/hostname identite-machine.txt
cat identite-machine.txt
# srv-linux
```

Explication :

- `touch` crée un fichier vide (ou met à jour la date d'un fichier existant).
- `echo "..." > releve.txt` : la redirection `>` crée le fichier et y écrit la
  ligne ; pas besoin d'éditeur. (`>>` aurait ajouté à la fin sans écraser.)
- `cp source destination` copie (l'original reste), `mv` déplace ou renomme
  (c'est la même commande pour les deux usages).
- `../archives/` : chemin relatif — `..` remonte de `rapports` vers
  `exploitation`.
- `rm` supprime **définitivement** : pas de corbeille sur un serveur.
- `/etc/hostname` contient le nom de la machine, injecté par Multipass au
  premier démarrage (via cloud-init, comme le ferait AWS avec le user data).

Vérification :

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

```bash
ls -l /var/log
less /var/log/cloud-init.log
```

Dans `less` : Espace = page suivante, `b` = page précédente, `/finished`
puis Entrée = recherche, `n` = occurrence suivante, `q` = quitter.
On y voit les étapes d'initialisation de la VM par cloud-init (le mécanisme
que le cloud utilise pour configurer une machine à son premier boot).

```bash
head /var/log/dpkg.log
tail -n 5 /var/log/dpkg.log
tail -n 5 /var/log/dpkg.log > ~/exploitation/rapports/dernieres-installations.txt

wc -l ~/exploitation/rapports/dernieres-installations.txt
# 5 /home/ubuntu/exploitation/rapports/dernieres-installations.txt
```

Explication :

- `head` sans option = 10 premières lignes ; `tail -n 5` = 5 dernières.
- La redirection `>` capture la sortie de `tail` dans le fichier de rapport :
  premier pas vers l'automatisation (jour 3).

### Partie 4 — Se débrouiller avec man

```bash
man ls      # rechercher /modification -> option -t
ls -lt /var/log

man tail    # rechercher /follow -> option -f
tail -f /var/log/syslog     # ou /var/log/dpkg.log ; Ctrl+C pour sortir

printf '%s\n' \
  "ls -t : trie par date de modification, le plus récent en premier" \
  "tail -f : affiche les nouvelles lignes au fur et à mesure (suivi de journal)" \
  > ~/exploitation/rapports/options-utiles.txt
cat ~/exploitation/rapports/options-utiles.txt
```

- `ls -t` : réponse attendue à la question 1 (accepter `ls -lt`).
- `tail -f` : LA commande de suivi de journal en direct ; les apprenants la
  reverront avec `journalctl -f` au jour 2.
- Le fichier de notes peut aussi être écrit avec `nano` ou deux `echo >>` —
  peu importe la méthode, seul le contenu compte.

## Variantes acceptables

1. Trois `mkdir` séparés (ou `mkdir exploitation` puis `cd` puis
   `mkdir scripts rapports archives`) :
   - Avantage : plus lisible pour un débutant, aucun piège.
   - Inconvénient : plus long ; l'expansion d'accolades est le geste pro à
     montrer au débriefing.
2. `nano releve.txt` au lieu de `echo >` : parfaitement valable ; profiter du
   débriefing pour montrer que la redirection est scriptable, pas l'éditeur.
3. `sudo journalctl` plutôt que les fichiers de `/var/log` : hors périmètre du
   jour 1 (vu au jour 2), mais ne pas pénaliser un apprenant qui l'a découvert.

## Bonus

```bash
sudo apt update && sudo apt install -y tree
tree ~/exploitation
```

```text
/home/ubuntu/exploitation
├── archives
│   └── releve.txt
├── rapports
│   ├── dernieres-installations.txt
│   ├── identite-machine.txt
│   ├── options-utiles.txt
│   └── releve-2026-07-06.txt
└── scripts

4 directories, 5 files
```

```bash
mkdir -p ~/exploitation/archives/{2024,2025,2026}
ls ~/exploitation/archives
# 2024  2025  2026  releve.txt
```

Tri par taille décroissante, tailles lisibles (dans `man ls` : `-S` = sort by
size, `-h` = human-readable) :

```bash
ls -lhS /var/log
```

Les plus gros fichiers apparaissent en premier — c'est le réflexe « qu'est-ce
qui remplit mon disque ? »
