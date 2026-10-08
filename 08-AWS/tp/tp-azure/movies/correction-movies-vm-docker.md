# Déployer l'application « movies » avec Docker sur une VM Azure — pas à pas portail

| | |
|---|---|
| Objectif | Créer une VM Ubuntu de zéro, y installer Docker, cloner le projet `movies`, construire son image et lancer le conteneur |
| Interface | Portail Azure (https://portal.azure.com) en **français**, libellé anglais entre parenthèses, et site github.com |
| Région | France Central |
| Durée | 40 à 50 minutes |
| Outils | Un navigateur. Aucun terminal ni clé SSH : les commandes passent par **Exécuter la commande** du portail |
| Dépôt | https://github.com/mohamedutopios/movies.git |

Le projet `movies` est un **site statique** (`index.html`, `style.css`, `script.js`). C'est le navigateur du visiteur qui interroge l'API de films TMDB. Le serveur se contente d'envoyer les trois fichiers. Ici, ce serveur est un **nginx dans un conteneur Docker**, et non installé directement sur la VM.

```
Navigateur ──HTTP 80──▶ IP publique ──▶ NSG (autorise 80) ──▶ vm-movies (Ubuntu + Docker)
     │                                                        └─ port 80 ──▶ conteneur « movies »
     │                                                                        nginx:alpine
     │                                                                        /usr/share/nginx/html/
     └──HTTPS──▶ api.themoviedb.org  (appel fait par le navigateur, pas par la VM)
```

## Sommaire

- [Étape 0 — Ajouter le Dockerfile au dépôt](#étape-0--ajouter-le-dockerfile-au-dépôt)
- [Étape 1 — Groupe de ressources](#étape-1--groupe-de-ressources)
- [Étape 2 — Créer la VM](#étape-2--créer-la-vm)
- [Étape 3 — Installer Docker](#étape-3--installer-docker)
- [Étape 4 — Cloner le projet et construire l'image](#étape-4--cloner-le-projet-et-construire-limage)
- [Étape 5 — Lancer le conteneur](#étape-5--lancer-le-conteneur)
- [Étape 6 — Tester l'application](#étape-6--tester-lapplication)
- [Étape 7 — Observer le conteneur](#étape-7--observer-le-conteneur)
- [Étape 8 — Mettre à jour l'application](#étape-8--mettre-à-jour-lapplication)
- [Étape 9 — Bonus : un nom DNS au lieu d'une IP](#étape-9--bonus--un-nom-dns-au-lieu-dune-ip)
- [Dépannage](#dépannage)
- [Étape 10 — Nettoyage](#étape-10--nettoyage)

---

## Étape 0 — Ajouter le Dockerfile au dépôt

La VM ne connaîtra que ce qui est **sur GitHub**. Le dépôt doit donc contenir le `Dockerfile`.

1. Ouvrir https://github.com/mohamedutopios/movies (connecté avec le compte propriétaire).
2. Bouton **Add file** → **Create new file**.
3. **Name your file** : `Dockerfile` (D majuscule, sans extension).
4. Contenu :

```dockerfile
FROM nginx:alpine

COPY index.html style.css script.js /usr/share/nginx/html/

EXPOSE 80
```

5. **Commit changes…** → message `Ajout du Dockerfile` → **Commit changes**.
6. Recommencer avec un fichier nommé `.dockerignore`, contenant :

```
.git
Dockerfile
.dockerignore
```

7. Ouvrir le dépôt dans une **fenêtre de navigation privée**.

✅ La page liste `Dockerfile`, `.dockerignore`, `index.html`, `script.js`, `style.css`. Elle est visible sans être connecté : le dépôt est **public**.

> 💡 **Pourquoi ?**
>
> - Un `Dockerfile` est la **recette** de l'image. Sans lui, la commande `docker build` de l'étape 4 échoue avec `failed to read dockerfile`.
> - **`FROM nginx:alpine`** : on part d'une image officielle qui contient déjà nginx, sur Alpine Linux (une distribution minimale d'environ 5 Mo). L'image finale est petite, rapide à télécharger, et expose peu de surface d'attaque.
> - **`COPY … /usr/share/nginx/html/`** : c'est le dossier que nginx sert par défaut **dans cette image**. Les fichiers du site sont donc intégrés **dans** l'image.
> - **`EXPOSE 80`** : documente le port sur lequel le conteneur écoute. Cette ligne n'ouvre rien à elle seule : c'est l'option `-p` de l'étape 5 qui publie le port.
> - **`.dockerignore`** : exclut `.git` des fichiers envoyés à Docker au moment de la construction. La construction est plus rapide, et l'historique du projet ne risque pas de se retrouver dans l'image.
> - **Navigation privée** : on voit exactement ce que verra la VM, qui clone **sans identifiant**.

---

## Étape 1 — Groupe de ressources

1. Barre de recherche du portail → **Groupes de ressources** (*Resource groups*) → **+ Créer**.

| Champ | Valeur |
|---|---|
| Abonnement | votre abonnement |
| Groupe de ressources | `rg-movies` |
| Région | `(Europe) France Central` |

2. **Vérifier et créer** (*Review + create*) → **Créer**.

✅ `rg-movies` apparaît dans la liste.

> 💡 **Pourquoi ?** Le groupe contiendra la VM et tout ce qu'elle crée autour d'elle (disque, carte réseau, IP, NSG, réseau virtuel). À la fin, une seule suppression efface tout.

---

## Étape 2 — Créer la VM

Barre de recherche → **Machines virtuelles** (*Virtual machines*) → **+ Créer** → **Machine virtuelle Azure**.

### Onglet Informations de base (*Basics*)

| Champ | Valeur |
|---|---|
| Groupe de ressources | `rg-movies` |
| Nom de la machine virtuelle | `vm-movies` |
| Région | `(Europe) France Central` |
| Options de disponibilité | `Aucune redondance d'infrastructure requise` |
| Type de sécurité | `Machines virtuelles de lancement fiable` (*Trusted launch*) |
| Image | `Ubuntu Server 24.04 LTS - x64 Gen2` |
| Architecture de machine virtuelle | `x64` |
| Taille | `Standard_B1ms` (1 vCPU, 2 Gio) — lien **Afficher toutes les tailles** si absente |
| Type d'authentification | `Mot de passe` |
| Nom d'utilisateur | `azureuser` |
| Mot de passe / Confirmer le mot de passe | un mot de passe fort (12 caractères min., majuscule, minuscule, chiffre, symbole) |
| Ports d'entrée publics | `Autoriser les ports sélectionnés` |
| Sélectionner des ports d'entrée | **HTTP (80)** uniquement (décocher SSH s'il est coché) |

> 💡 **Pourquoi ?**
>
> - **Ubuntu 24.04 LTS** : support long (5 ans), et Docker est disponible directement dans ses dépôts (paquet `docker.io`).
> - **`Standard_B1ms`** (2 Gio) plutôt que B1s (1 Gio) : le moteur Docker et la construction d'une image consomment plus de mémoire qu'un simple nginx installé sur la VM. Avec 1 Gio, la construction peut échouer faute de mémoire.
> - **Mot de passe** : aucune connexion SSH n'est prévue, donc pas de fichier de clé à gérer. Il ne sert qu'en secours, via la console série.
> - **HTTP (80) seulement** : c'est le seul port utile aux visiteurs. Ne pas ouvrir SSH évite d'exposer la VM aux robots qui tentent des connexions en permanence.

### Onglet Disques (*Disks*)

| Champ | Valeur |
|---|---|
| Type de disque du système d'exploitation | `SSD Standard (stockage localement redondant)` |
| Supprimer avec la machine virtuelle | coché |

> 💡 **Pourquoi ?** Les images et conteneurs Docker sont stockés sur le disque système (`/var/lib/docker`). Les 30 Gio par défaut suffisent largement pour une image nginx:alpine (environ 50 Mo).

### Onglet Mise en réseau (*Networking*)

| Champ | Valeur |
|---|---|
| Réseau virtuel | **(nouveau) vm-movies-vnet** (proposé automatiquement) |
| Sous-réseau | **(nouveau) default (10.0.0.0/24)** |
| IP publique | **(nouveau) vm-movies-ip** |
| Groupe de sécurité réseau de la carte réseau | `De base` (*Basic*) |
| Ports d'entrée publics | `Autoriser les ports sélectionnés` → **HTTP (80)** |
| Supprimer l'adresse IP publique et la carte réseau quand la machine virtuelle est supprimée | coché |
| Options d'équilibrage de charge | `Aucun` |

> 💡 **Pourquoi ?**
>
> - **IP publique** : l'adresse que les visiteurs taperont. Elle permet aussi à la VM de **sortir** sur Internet pour télécharger Docker, le dépôt GitHub et l'image `nginx:alpine` depuis Docker Hub.
> - **NSG `De base`** : le portail crée un pare-feu (`vm-movies-nsg`) avec une règle qui autorise le port 80 depuis Internet. Tout le reste est refusé.

### Onglet Gestion (*Management*)

| Champ | Valeur |
|---|---|
| Activer l'arrêt automatique | coché, `19:00`, fuseau `(UTC+01:00) Bruxelles, Copenhague, Madrid, Paris` |

> 💡 **Pourquoi ?** L'arrêt automatique **désalloue** la VM : le calcul n'est plus facturé la nuit. Le conteneur redémarrera tout seul au prochain démarrage de la VM (voir `--restart` à l'étape 5).

### Onglet Surveillance (*Monitoring*)

| Champ | Valeur |
|---|---|
| Diagnostics de démarrage | `Activer avec un compte de stockage managé (recommandé)` |

### Onglets Avancé et Balises

Laisser les valeurs par défaut.

### Création

1. **Vérifier et créer** → relire le récapitulatif → **Créer**.
2. Attendre **Votre déploiement a été effectué** → **Accéder à la ressource**.

✅ **Vue d'ensemble** de `vm-movies` : état **En cours d'exécution**. Copier l'**Adresse IP publique**. L'ouvrir dans le navigateur (`http://<IP>`) : rien ne répond. Le port est ouvert, mais aucun programme n'écoute encore.

---

## Étape 3 — Installer Docker

1. `vm-movies` → **Opérations** → **Exécuter la commande** (*Run command*) → **RunShellScript**.
2. Coller :

```bash
apt-get -o DPkg::Lock::Timeout=300 update -q
apt-get -o DPkg::Lock::Timeout=300 install -y -q docker.io git
systemctl enable --now docker
docker version --format 'Docker {{.Server.Version}}'
docker run --rm hello-world | grep "Hello from Docker"
```

3. **Exécuter**. Attendre la fin (2 à 4 minutes).

✅ La sortie affiche `Docker 2x.x.x` puis `Hello from Docker!`.

> 💡 **Pourquoi ?**
>
> - **Exécuter la commande** : le portail envoie le script à l'agent Azure de la VM, qui l'exécute en root et affiche la sortie. Pas de SSH, pas de port 22. Chaque exécution est tracée dans le **Journal d'activité**.
> - **`DPkg::Lock::Timeout=300`** : au premier démarrage, Ubuntu lance ses mises à jour automatiques, qui verrouillent `apt`. On attend que le verrou se libère au lieu d'échouer.
> - **`docker.io`** : le moteur Docker packagé par Ubuntu, la façon la plus simple de l'installer. **`git`** : pour cloner le dépôt.
> - **`systemctl enable --now docker`** : démarre Docker maintenant et à chaque démarrage de la VM. Indispensable pour que le conteneur revienne après l'arrêt automatique.
> - **`hello-world`** : test complet en une commande. Docker télécharge une image depuis Docker Hub (la sortie Internet fonctionne), crée un conteneur, l'exécute, puis le supprime (`--rm`).
> - **Pas de nginx sur la VM** : contrairement au déploiement classique, nginx vit **dans** le conteneur. La VM n'a besoin que de Docker.

---

## Étape 4 — Cloner le projet et construire l'image

1. `vm-movies` → **Opérations** → **Exécuter la commande** → **RunShellScript**.
2. Coller :

```bash
git clone https://github.com/mohamedutopios/movies.git /opt/movies
cd /opt/movies
ls -la
docker build -t movies:1.0 .
docker images movies
```

3. **Exécuter** (1 à 2 minutes).

✅ `ls -la` liste `Dockerfile`. La dernière ligne montre l'image `movies`, tag `1.0`, d'environ 50 Mo.

> 💡 **Pourquoi ?**
>
> - **`/opt/movies`** : emplacement conventionnel pour une application ajoutée à la main. Ce dossier ne sert que de **source** pour la construction : il n'est pas publié sur le web.
> - **`docker build -t movies:1.0 .`** : Docker lit le `Dockerfile` du dossier courant (`.`, appelé le **contexte**), télécharge `nginx:alpine`, y copie les trois fichiers, et enregistre le résultat sous le nom `movies` avec le **tag** `1.0`.
> - **Tag de version** plutôt que `latest` : on sait exactement quelle version tourne, et on peut revenir à la précédente (étape 8).
> - **Image ≠ conteneur** : l'image est un modèle figé, en lecture seule (comme une image de VM) ; le conteneur est une instance en cours d'exécution de cette image. À ce stade, rien ne tourne encore.

---

## Étape 5 — Lancer le conteneur

1. `vm-movies` → **Opérations** → **Exécuter la commande** → **RunShellScript**.
2. Coller :

```bash
docker run -d --name movies --restart unless-stopped -p 80:80 movies:1.0
sleep 3
docker ps
curl -s http://localhost | grep -o '<title>.*</title>'
```

3. **Exécuter**.

✅ `docker ps` montre le conteneur `movies`, état `Up`, ports `0.0.0.0:80->80/tcp`. La dernière ligne affiche `<title>Movie App</title>`.

> 💡 **Pourquoi ?**
>
> - **`-d`** (*detached*) : le conteneur tourne en arrière-plan. Sans cette option, la commande ne rendrait jamais la main.
> - **`--name movies`** : un nom fixe, plus simple à manipuler qu'un identifiant aléatoire (`docker logs movies`, `docker rm movies`…).
> - **`--restart unless-stopped`** : Docker relance le conteneur s'il plante **et** au redémarrage de la VM, sauf si on l'a arrêté volontairement. Sans cette option, le site disparaîtrait après l'arrêt automatique du soir.
> - **`-p 80:80`** : publie le port. Le premier `80` est le port **de la VM** (celui qu'autorise le NSG), le second celui **du conteneur** (celui où écoute nginx). On pourrait écrire `-p 8080:80` pour exposer le site sur le port 8080 de la VM, à condition d'ouvrir aussi ce port dans le NSG.
> - **`curl http://localhost`** : vérifie depuis la VM que la chaîne VM → conteneur → nginx fonctionne, indépendamment du réseau Azure.

---

## Étape 6 — Tester l'application

1. Ouvrir `http://<adresse IP publique>` (recharger avec **Ctrl + F5** si besoin).

✅ La page affiche une grille d'affiches de films populaires, avec leur note. Taper un titre dans **Search** puis Entrée affiche les résultats de recherche.

> 💡 **Pourquoi ?**
>
> - Les films ne viennent pas de la VM : c'est **le navigateur du visiteur** qui appelle `api.themoviedb.org` (voir `script.js`). La VM n'a servi que trois fichiers.
> - Conséquence : si la page s'affiche mais **sans films**, le problème est côté API TMDB ou côté navigateur (bloqueur, réseau), pas côté Azure. Ouvrir les outils de développement (F12) → onglet **Console** pour voir l'erreur.
> - ⚠️ La clé d'API TMDB est écrite en clair dans `script.js` : n'importe quel visiteur peut la lire. C'est acceptable pour une démo, pas pour une application réelle (il faudrait un back-end qui appelle l'API à la place du navigateur).

---

## Étape 7 — Observer le conteneur

1. `vm-movies` → **Opérations** → **Exécuter la commande** → **RunShellScript** :

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
docker logs --tail 10 movies
docker stats --no-stream movies
```

✅ On voit l'image utilisée, depuis combien de temps le conteneur tourne, les dernières requêtes HTTP (dont les vôtres, avec votre IP), et la mémoire consommée (quelques Mo).

> 💡 **Pourquoi ?**
>
> - **`docker logs`** : nginx écrit ses journaux d'accès sur la sortie standard du conteneur, et Docker les conserve. C'est le premier réflexe en cas de problème.
> - **`docker stats`** : CPU et mémoire du conteneur. On constate qu'un nginx statique consomme très peu : la VM est largement dimensionnée.
> - Pour tester `--restart` : **Vue d'ensemble** → **Redémarrer** la VM, attendre l'état **En cours d'exécution**, puis recharger le site. Il revient sans aucune action.

---

## Étape 8 — Mettre à jour l'application

Après une modification poussée sur GitHub (par exemple un changement dans `style.css`) :

1. `vm-movies` → **Opérations** → **Exécuter la commande** → **RunShellScript**.
2. Coller, en incrémentant le numéro de version :

```bash
cd /opt/movies
git pull
docker build -t movies:1.1 .
docker rm -f movies
docker run -d --name movies --restart unless-stopped -p 80:80 movies:1.1
docker ps
docker images movies
```

3. **Exécuter**, puis recharger la page avec **Ctrl + F5**.

✅ `docker images movies` liste les tags `1.0` **et** `1.1`. Le conteneur tourne avec `movies:1.1`.

**Revenir en arrière** si la version 1.1 pose problème :

```bash
docker rm -f movies
docker run -d --name movies --restart unless-stopped -p 80:80 movies:1.0
```

> 💡 **Pourquoi ?**
>
> - Les fichiers du site sont **dans l'image**. Un `git pull` seul ne change donc rien au site : il faut **reconstruire** l'image, puis **remplacer** le conteneur.
> - **`docker rm -f`** arrête et supprime l'ancien conteneur pour libérer le nom `movies` et le port 80. Le site est indisponible quelques secondes : acceptable ici. En production, on évite cette coupure avec plusieurs instances derrière un équilibreur de charge.
> - **Garder l'ancienne image** permet un retour arrière immédiat, sans reconstruction. C'est l'intérêt principal des tags de version.
> - En production, l'image est construite par un pipeline CI/CD et poussée dans un registre (**Azure Container Registry**) ; la VM ne fait plus que `docker pull` puis `docker run`.

---

## Étape 9 — Bonus : un nom DNS au lieu d'une IP

1. `vm-movies` → **Vue d'ensemble** → cliquer le lien de l'**Adresse IP publique** (`vm-movies-ip`).
2. **Paramètres** → **Configuration**.

| Champ | Valeur |
|---|---|
| Étiquette de nom DNS (facultatif) | `movies-<vos initiales>` |

3. **Enregistrer**.

✅ Le site répond à `http://movies-<vos initiales>.francecentral.cloudapp.azure.com`.

> 💡 **Pourquoi ?** Un nom se retient mieux qu'une IP. L'étiquette doit être unique dans la région, d'où les initiales.

---

## Dépannage

| Symptôme | Cause probable | Vérification |
|---|---|---|
| Le navigateur tourne puis « délai dépassé » | Port 80 non autorisé, ou VM arrêtée | **Mise en réseau** → règle HTTP 80 ; **Vue d'ensemble** → état |
| « Connexion refusée » immédiate | Conteneur arrêté ou non publié sur le port 80 | **Exécuter la commande** : `docker ps -a` puis `docker logs movies` |
| Étape 4 : `failed to read dockerfile` | `Dockerfile` absent du dépôt | Revenir à l'étape 0, puis `cd /opt/movies && git pull` |
| Étape 4 : `fatal: could not read Username` | Dépôt privé | Rendre le dépôt public (étape 0) |
| Étape 4 : `destination path '/opt/movies' already exists` | Étape déjà exécutée | Utiliser `cd /opt/movies && git pull` |
| Étape 5 : `Conflict. The container name "/movies" is already in use` | Conteneur déjà créé | `docker rm -f movies` puis relancer `docker run` |
| Étape 5 : `address already in use` sur le port 80 | Un nginx est installé directement sur la VM | `systemctl disable --now nginx` puis relancer `docker run` |
| Étape 3 : `Could not get lock` | Mises à jour automatiques en cours | Patienter 2 minutes et relancer |
| Page affichée **sans films** | Appel à l'API TMDB bloqué côté navigateur | F12 → **Console** dans le navigateur |
| Ancienne version affichée après mise à jour | Cache du navigateur, ou conteneur non remplacé | Ctrl + F5 ; `docker ps` (colonne IMAGE) |

> 💡 **Méthode** : remonter les couches dans l'ordre. **VM démarrée ?** → **NSG ouvert ?** → **conteneur `Up` ?** (`docker ps`) → **port publié ?** (`0.0.0.0:80->80`) → **nginx répond ?** (`curl localhost`) → **cache du navigateur ?**

---

## Étape 10 — Nettoyage

1. Barre de recherche → **Groupes de ressources** → `rg-movies`.
2. **Supprimer le groupe de ressources** → saisir `rg-movies` → **Supprimer**.

✅ Après quelques minutes, la cloche 🔔 confirme la suppression ; **Actualiser** : `rg-movies` a disparu.

> 💡 **Pourquoi ?** Supprimer le groupe efface la VM, son disque (et donc Docker, les images et le conteneur), sa carte réseau, son IP publique, son NSG et son réseau virtuel. Une VM simplement arrêtée continue de facturer son disque et son IP.
