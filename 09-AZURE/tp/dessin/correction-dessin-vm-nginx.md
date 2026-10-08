# Déployer l'application « dessin » sur une VM Azure avec nginx — pas à pas portail

| | |
|---|---|
| Objectif | Créer une VM Ubuntu de zéro, y installer nginx, cloner le projet `dessin` et le publier sur Internet |
| Interface | Portail Azure (https://portal.azure.com) en **français**, libellé anglais entre parenthèses |
| Région | France Central |
| Durée | 30 à 40 minutes |
| Outils | Un navigateur. Aucun terminal ni clé SSH : les commandes passent par **Exécuter la commande** du portail |
| Dépôt | https://github.com/mohamedutopios/dessin.git |

Le projet `dessin` est un **site statique** : trois fichiers (`index.html`, `style.css`, `script.js`) exécutés par le navigateur du visiteur. Le serveur n'a qu'un rôle : les envoyer. nginx est parfait pour cela.

```
Navigateur ──HTTP 80──▶ IP publique ──▶ NSG (autorise 80) ──▶ vm-dessin
                                                             └─ nginx ──▶ /var/www/html/
                                                                          ├─ index.html
                                                                          ├─ style.css
                                                                          └─ script.js
```

## Sommaire

- [Étape 0 — Vérifier le dépôt](#étape-0--vérifier-le-dépôt)
- [Étape 1 — Groupe de ressources](#étape-1--groupe-de-ressources)
- [Étape 2 — Créer la VM](#étape-2--créer-la-vm)
- [Étape 3 — Constater qu'aucun site ne répond](#étape-3--constater-quaucun-site-ne-répond)
- [Étape 4 — Installer nginx](#étape-4--installer-nginx)
- [Étape 5 — Cloner le projet et le publier](#étape-5--cloner-le-projet-et-le-publier)
- [Étape 6 — Tester l'application](#étape-6--tester-lapplication)
- [Étape 7 — Mettre à jour le site](#étape-7--mettre-à-jour-le-site)
- [Étape 8 — Bonus : un nom DNS au lieu d'une IP](#étape-8--bonus--un-nom-dns-au-lieu-dune-ip)
- [Dépannage](#dépannage)
- [Étape 9 — Nettoyage](#étape-9--nettoyage)

---

## Étape 0 — Vérifier le dépôt

1. Ouvrir une **fenêtre de navigation privée** (sans être connecté à GitHub).
2. Aller sur https://github.com/mohamedutopios/dessin.

✅ La page affiche les fichiers `index.html`, `script.js` et `style.css`.

> 💡 **Pourquoi ?**
>
> - La VM va cloner le dépôt **sans identifiant**. Le dépôt doit donc être **public**.
> - En navigation privée, on voit exactement ce que verra la VM. Si GitHub affiche « 404 », le dépôt est privé : passez-le en public (**Settings** → **Danger Zone** → **Change visibility**) ou utilisez un jeton d'accès.

---

## Étape 1 — Groupe de ressources

1. Barre de recherche du portail → **Groupes de ressources** (*Resource groups*) → **+ Créer**.

| Champ | Valeur |
|---|---|
| Abonnement | votre abonnement |
| Groupe de ressources | `rg-dessin` |
| Région | `(Europe) France Central` |

2. **Vérifier et créer** (*Review + create*) → **Créer**.

✅ `rg-dessin` apparaît dans la liste (bouton **Actualiser** si besoin).

> 💡 **Pourquoi ?**
>
> - Le groupe de ressources contiendra tout ce que la VM crée autour d'elle : disque, carte réseau, IP publique, NSG, réseau virtuel.
> - À la fin, une seule suppression efface tout, sans rien oublier de facturable.

---

## Étape 2 — Créer la VM

Barre de recherche → **Machines virtuelles** (*Virtual machines*) → **+ Créer** → **Machine virtuelle Azure**.

### Onglet Informations de base (*Basics*)

| Champ | Valeur |
|---|---|
| Groupe de ressources | `rg-dessin` |
| Nom de la machine virtuelle | `vm-dessin` |
| Région | `(Europe) France Central` |
| Options de disponibilité | `Aucune redondance d'infrastructure requise` |
| Type de sécurité | `Machines virtuelles de lancement fiable` (*Trusted launch*) |
| Image | `Ubuntu Server 24.04 LTS - x64 Gen2` |
| Architecture de machine virtuelle | `x64` |
| Taille | `Standard_B1s` (1 vCPU, 1 Gio) — lien **Afficher toutes les tailles** si absente |
| Type d'authentification | `Mot de passe` |
| Nom d'utilisateur | `azureuser` |
| Mot de passe / Confirmer le mot de passe | un mot de passe fort (12 caractères min., majuscule, minuscule, chiffre, symbole) |
| Ports d'entrée publics | `Autoriser les ports sélectionnés` |
| Sélectionner des ports d'entrée | **HTTP (80)** uniquement (décocher SSH s'il est coché) |

> 💡 **Pourquoi ?**
>
> - **Ubuntu 24.04 LTS** : version à support long (5 ans), et nginx est disponible directement dans ses dépôts. **Gen2** = démarrage UEFI, requis pour le lancement fiable.
> - **Lancement fiable** : Secure Boot + vTPM. Seuls des chargeurs et noyaux signés démarrent, ce qui protège contre les rootkits, sans surcoût.
> - **`Standard_B1s`** : la plus petite taille polyvalente, éligible à l'offre gratuite. Servir trois fichiers statiques ne demande presque aucune ressource.
> - **Mot de passe** : aucune connexion SSH n'est prévue (on passe par **Exécuter la commande**), donc pas de fichier de clé à gérer. Le mot de passe ne sert qu'en secours, via la console série.
> - **HTTP (80) seulement** : c'est le seul port dont les visiteurs ont besoin. Ne pas ouvrir SSH (22) évite d'exposer la VM aux robots qui tentent des connexions en permanence sur toutes les IP publiques.

### Onglet Disques (*Disks*)

| Champ | Valeur |
|---|---|
| Type de disque du système d'exploitation | `SSD Standard (stockage localement redondant)` |
| Supprimer avec la machine virtuelle | coché |

> 💡 **Pourquoi ?** Le SSD Standard offre un bon compromis prix/latence pour un serveur web. Le site pèse quelques Ko : aucun disque de données n'est nécessaire.

### Onglet Mise en réseau (*Networking*)

| Champ | Valeur |
|---|---|
| Réseau virtuel | **(nouveau) vm-dessin-vnet** (proposé automatiquement) |
| Sous-réseau | **(nouveau) default (10.0.0.0/24)** |
| IP publique | **(nouveau) vm-dessin-ip** |
| Groupe de sécurité réseau de la carte réseau | `De base` (*Basic*) |
| Ports d'entrée publics | `Autoriser les ports sélectionnés` → **HTTP (80)** |
| Supprimer l'adresse IP publique et la carte réseau quand la machine virtuelle est supprimée | coché |
| Options d'équilibrage de charge | `Aucun` |

> 💡 **Pourquoi ?**
>
> - Une VM doit obligatoirement être dans un **réseau virtuel**. Le portail en crée un pour nous. Pour une VM isolée, c'est suffisant.
> - **IP publique** : c'est l'adresse que les visiteurs taperont. Sans elle, le site ne serait joignable que depuis l'intérieur du réseau Azure. Elle permet aussi à la VM de sortir sur Internet (téléchargement de nginx et du dépôt).
> - **NSG `De base`** : le portail crée un pare-feu (`vm-dessin-nsg`) attaché à la carte réseau, avec une règle qui autorise le port 80 depuis Internet. Tout le reste est refusé par défaut.

### Onglet Gestion (*Management*)

| Champ | Valeur |
|---|---|
| Activer l'arrêt automatique | coché, `19:00`, fuseau `(UTC+01:00) Bruxelles, Copenhague, Madrid, Paris` |

> 💡 **Pourquoi ?** Une VM de formation oubliée tourne toute la nuit. L'arrêt automatique la **désalloue** : le calcul n'est plus facturé.

### Onglet Surveillance (*Monitoring*)

| Champ | Valeur |
|---|---|
| Diagnostics de démarrage | `Activer avec un compte de stockage managé (recommandé)` |

> 💡 **Pourquoi ?** Si la VM ne répond plus, on peut consulter sa capture d'écran et son journal de démarrage depuis le portail, sans s'y connecter.

### Onglets Avancé et Balises

Laisser les valeurs par défaut.

### Création

1. **Vérifier et créer** → relire le récapitulatif (prix horaire estimé en haut) → **Créer**.
2. Attendre **Votre déploiement a été effectué** (1 à 2 minutes) → **Accéder à la ressource**.

✅ Page **Vue d'ensemble** de `vm-dessin` : état **En cours d'exécution**. Copier l'**Adresse IP publique**.

---

## Étape 3 — Constater qu'aucun site ne répond

1. Dans un nouvel onglet : `http://<adresse IP publique>`.

✅ Le navigateur tourne puis affiche une erreur (« Ce site est inaccessible » / *connection refused*).

2. `vm-dessin` → **Mise en réseau** (*Networking*) → **Paramètres réseau** (*Network settings*) : la règle entrante **HTTP**, port **80**, action **Autoriser**, est bien présente.

> 💡 **Pourquoi ?**
>
> - Le pare-feu laisse passer le port 80, mais **aucun programme n'écoute** sur ce port dans la VM.
> - Un site web a besoin des deux : le réseau qui laisse passer (NSG) **et** un serveur qui répond (nginx). Montrer l'échec avant d'installer nginx aide à distinguer les deux couches lors d'un dépannage.

---

## Étape 4 — Installer nginx

1. `vm-dessin` → **Opérations** → **Exécuter la commande** (*Run command*) → **RunShellScript**.
2. Coller :

```bash
apt-get -o DPkg::Lock::Timeout=300 update -q
apt-get -o DPkg::Lock::Timeout=300 install -y -q nginx git rsync
systemctl enable --now nginx
systemctl is-active nginx
curl -sI http://localhost | head -n 1
```

3. **Exécuter**. Attendre la fin (1 à 3 minutes) : la sortie s'affiche sous le bouton.

✅ La sortie se termine par `active` puis `HTTP/1.1 200 OK`.

4. Recharger `http://<adresse IP publique>` dans le navigateur.

✅ La page **Welcome to nginx!** s'affiche.

> 💡 **Pourquoi ?**
>
> - **Exécuter la commande** : le portail envoie le script à l'agent Azure installé dans la VM, qui l'exécute en administrateur (root) et renvoie la sortie. Pas de SSH, pas de port 22 ouvert. Chaque exécution est tracée dans le **Journal d'activité**.
> - **`DPkg::Lock::Timeout=300`** : au premier démarrage, Ubuntu lance ses mises à jour automatiques, qui verrouillent `apt`. On attend jusqu'à 5 minutes que le verrou se libère au lieu d'échouer.
> - **`apt-get update`** : rafraîchit la liste des paquets disponibles. Sans cela, l'installation peut échouer sur une VM neuve.
> - **`nginx`** : le serveur web. **`git`** : pour cloner le dépôt. **`rsync`** : pour copier les fichiers à l'étape 5.
> - **`systemctl enable --now`** : démarre nginx tout de suite (`--now`) **et** à chaque redémarrage de la VM (`enable`). Sans `enable`, le site disparaîtrait après l'arrêt automatique du soir.
> - **`curl -sI http://localhost`** : interroge nginx depuis la VM elle-même. `200 OK` prouve que le serveur répond, indépendamment du réseau Azure.

---

## Étape 5 — Cloner le projet et le publier

1. `vm-dessin` → **Opérations** → **Exécuter la commande** → **RunShellScript**.
2. Coller :

```bash
git clone https://github.com/mohamedutopios/dessin.git /opt/dessin
rsync -a --delete --exclude '.git' /opt/dessin/ /var/www/html/
ls -l /var/www/html
curl -s http://localhost | grep -o '<title>.*</title>'
```

3. **Exécuter**.

✅ La sortie liste `index.html`, `script.js`, `style.css` puis affiche `<title>Drawing App</title>`.

> 💡 **Pourquoi ?**
>
> - **`/var/www/html`** : c'est le dossier que nginx sert par défaut sur Ubuntu (directive `root` du site `default`). Tout fichier qu'on y dépose est accessible à `http://<IP>/<nom du fichier>`. Aucune configuration de nginx n'est à modifier.
> - **Cloner dans `/opt/dessin`, puis copier** : on sépare la **copie de travail Git** (avec son historique) des **fichiers publiés**.
> - **Pourquoi ne pas cloner directement dans `/var/www/html` ?** Le dossier caché `.git` serait alors publié : n'importe qui pourrait télécharger `http://<IP>/.git/` et reconstituer tout l'historique du projet, y compris d'éventuels secrets commités par erreur. C'est une fuite de données classique.
> - **`rsync -a --delete --exclude '.git'`** :
>   - `-a` copie en conservant les droits et dates ;
>   - `--exclude '.git'` ne publie pas l'historique Git ;
>   - `--delete` supprime de `/var/www/html` ce qui n'existe pas dans le dépôt. C'est ce qui retire la page d'accueil par défaut de nginx (`index.nginx-debian.html`), et plus tard les fichiers supprimés du projet.
> - **Le `/` final de `/opt/dessin/`** : copie le **contenu** du dossier, et non le dossier lui-même (sinon on obtiendrait `/var/www/html/dessin/`).
> - Les fichiers appartiennent à root et sont lisibles par tous : nginx (utilisateur `www-data`) peut les lire, mais pas les modifier.

---

## Étape 6 — Tester l'application

1. Recharger `http://<adresse IP publique>` avec **Ctrl + F5** (ou **Cmd + Maj + R** sur Mac).

✅ La page affiche une zone de dessin et une barre d'outils (`-`, taille, `+`, couleur, `X`). On peut dessiner à la souris, changer la couleur et la taille du trait, et effacer.

> 💡 **Pourquoi ?**
>
> - **Ctrl + F5** force le navigateur à ignorer son cache : sinon il pourrait réafficher la page « Welcome to nginx! » mémorisée à l'étape 4.
> - Le dessin s'exécute **entièrement dans le navigateur** (élément `canvas` piloté par `script.js`). La VM ne fait aucun calcul : elle n'a servi que trois fichiers. C'est pourquoi la plus petite taille de VM suffit.

---

## Étape 7 — Mettre à jour le site

Après une modification poussée sur GitHub :

1. `vm-dessin` → **Opérations** → **Exécuter la commande** → **RunShellScript**.
2. Coller :

```bash
git -C /opt/dessin pull
rsync -a --delete --exclude '.git' /opt/dessin/ /var/www/html/
ls -l /var/www/html
```

3. **Exécuter**, puis recharger la page avec **Ctrl + F5**.

> 💡 **Pourquoi ?**
>
> - **`git pull`** récupère seulement les changements depuis le dernier clonage : pas besoin de tout retélécharger.
> - Le même `rsync` republie le site : fichiers ajoutés, modifiés **et supprimés**.
> - Il n'est pas nécessaire de redémarrer nginx : il lit les fichiers à chaque requête.
> - En production, on automatise ces deux lignes avec un pipeline CI/CD (GitHub Actions, Azure DevOps) qui se déclenche à chaque push.

---

## Étape 8 — Bonus : un nom DNS au lieu d'une IP

1. `vm-dessin` → **Vue d'ensemble** → cliquer le lien de l'**Adresse IP publique** (ressource `vm-dessin-ip`).
2. **Paramètres** → **Configuration**.

| Champ | Valeur |
|---|---|
| Étiquette de nom DNS (facultatif) | `dessin-<vos initiales>` (par exemple `dessin-ma`) |

3. **Enregistrer**.

✅ Le site répond aussi à `http://dessin-ma.francecentral.cloudapp.azure.com`.

> 💡 **Pourquoi ?**
>
> - Une adresse IP est difficile à retenir et peut changer si la VM est recréée. Azure fournit gratuitement un nom DNS sous `<région>.cloudapp.azure.com`.
> - L'étiquette doit être **unique dans la région**, d'où les initiales.
> - Pour un vrai nom de domaine (`dessin.mondomaine.fr`), on crée un enregistrement **CNAME** vers ce nom, ou un enregistrement **A** vers l'IP, dans la zone DNS du domaine (par exemple dans Azure DNS).

---

## Dépannage

| Symptôme | Cause probable | Vérification dans le portail |
|---|---|---|
| Le navigateur tourne puis « délai dépassé » | Port 80 non autorisé, ou VM arrêtée | **Mise en réseau** → la règle HTTP 80 existe ; **Vue d'ensemble** → état **En cours d'exécution** |
| « Connexion refusée » immédiate | nginx ne tourne pas | **Exécuter la commande** : `systemctl status nginx --no-pager` |
| Page « Welcome to nginx! » | Fichiers non copiés, ou cache du navigateur | **Exécuter la commande** : `ls -l /var/www/html` ; recharger avec Ctrl + F5 |
| Erreur `403 Forbidden` | Aucun `index.html` dans `/var/www/html` | **Exécuter la commande** : `ls -l /var/www/html` |
| Étape 5 : `fatal: could not read Username` | Dépôt privé | Revenir à l'étape 0 |
| Étape 5 : `destination path '/opt/dessin' already exists` | Étape 5 déjà exécutée | Utiliser les commandes de l'étape 7 |
| Étape 4 : `Could not get lock` | Mises à jour automatiques en cours | Patienter 2 minutes et relancer |
| **Exécuter la commande** ne répond pas | Agent de la VM indisponible | **Aide** → **Diagnostics de démarrage** → onglet **Journal série** |

> 💡 **Méthode** : remonter les couches dans l'ordre. **VM démarrée ?** → **NSG ouvert ?** → **nginx actif ?** (`curl localhost` répond depuis la VM) → **fichiers présents ?** → **cache du navigateur ?**

---

## Étape 9 — Nettoyage

1. Barre de recherche → **Groupes de ressources** → `rg-dessin`.
2. **Supprimer le groupe de ressources**.
3. Saisir `rg-dessin` dans le champ de confirmation → **Supprimer**.

✅ Après quelques minutes, la cloche 🔔 confirme la suppression. **Actualiser** la liste : `rg-dessin` a disparu.

> 💡 **Pourquoi ?**
>
> - Supprimer le groupe efface d'un coup la VM, son disque, sa carte réseau, son IP publique, son NSG et son réseau virtuel.
> - Une VM **arrêtée** (désallouée) ne coûte plus en calcul, mais son disque et son IP publique restent facturés : seule la suppression ramène le coût à zéro.
