# Mini-TP — Votre premier serveur de production

> Module : 03 — CL-LINUX « Linux pour l'admin cloud »
> Durée estimée : 2 h (fin du jour 4)
> Difficulté : 3 / 5
> Type : Travaux pratiques guidés — **non noté** (entraînement pour le CL-TP1)

## Mise en situation

L'équipe StockLine a terminé la première version « lite » de son API d'inventaire
(FastAPI + SQLite). Le chef de projet vous confie **la première mise en production** :
l'application doit tourner en continu sur le serveur `srv-linux`, redémarrer toute
seule en cas de plantage ou de reboot, être accessible sur le port 80 via nginx,
être sauvegardée chaque nuit, et le serveur doit être protégé par un pare-feu.

Vous venez de voir le formateur dérouler ce déploiement en démo (démo 4-1).
À vous de le refaire **en autonomie**, étape par étape. Chaque étape se termine par
un **point de contrôle** : ne passez à la suivante que lorsqu'il est vert.

Tout ce que vous faites ici, vous le referez tel quel sur une instance EC2 ou une
VM Azure — seule la façon d'obtenir la machine change.

## Objectifs

- Déployer une application Python complète sur Ubuntu Server 24.04 : code, venv,
  utilisateur système dédié, service systemd.
- Placer nginx en reverse proxy devant uvicorn et vérifier la chaîne de bout en bout.
- Automatiser la sauvegarde des données avec un script bash et un timer systemd.
- Appliquer un durcissement minimal avec ufw, sans se couper l'accès SSH.

## Prérequis techniques

### Logiciels et acquis nécessaires

- Multipass installé sur le poste hôte, VM `srv-linux` créée au jour 1
  (plan B : VM VirtualBox équivalente).
- Client OpenSSH et `rsync` sur le poste hôte.
- Le dépôt de formation cloné au jour 1 (il contient `code/03-cl-linux/stockline-lite/`).
- Cours des jours 1 à 4 du bloc CL-LINUX.
- **Exercice 4-1 terminé** : l'utilisateur `deploy` existe sur la VM, votre clé SSH
  est installée et votre `~/.ssh/config` contient l'entrée `Host srv-linux`.

### Vérification de l'environnement

Depuis le poste hôte :

```bash
multipass info srv-linux          # la VM existe (notez son IPv4 au passage)
ssh srv-linux 'echo acces OK'     # la connexion par clé en tant que deploy fonctionne
rsync --version | head -n 1       # rsync est disponible sur le poste
```

Si `ssh srv-linux` échoue, reprenez l'exercice 4-1 avant de continuer.

## Architecture cible

```text
Poste hôte                              VM srv-linux (Ubuntu Server 24.04)
──────────                              ─────────────────────────────────────────────
rsync (via SSH, user deploy) ──22──>    /home/deploy/stockline-lite  (zone de transit)

curl http://<IP-VM>/sante ──80──>  nginx (reverse proxy) ──127.0.0.1:8000──> uvicorn (StockLine)
                                     │                                          │ User=stockline
                                    ufw (22, 80 autorisés)                      ▼
                                                                /opt/stockline/data/stockline.db
                                                                                │
                                              backup.timer (03:00) ──> /var/backups/stockline/
```

Arborescence applicative sur la VM :

```text
/opt/stockline/
├── app/     main.py, requirements.txt        (code, propriété stockline)
├── venv/    environnement Python dédié
└── data/    stockline.db                     (la base SQLite)
```

## Étapes

### Étape 1 — VM prête et à jour (10 min)

Objectif : partir d'un serveur démarré, à jour, comme avant toute mise en production.

1. Démarrez la VM et ouvrez une session d'administration :
   ```bash
   multipass start srv-linux
   multipass shell srv-linux
   ```

2. Mettez le système à jour (réflexe n° 1 sur toute machine cloud fraîchement lancée) :
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

Point de contrôle : `lsb_release -a` affiche `Description: Ubuntu 24.04.2 LTS`
(ou une révision 24.04.x plus récente) et `apt upgrade` se termine sans erreur.

### Étape 2 — Transfert du code avec rsync (10 min)

Objectif : envoyer le code de StockLine « lite » sur la VM via l'accès `deploy`
mis en place à l'exercice 4-1.

1. **Depuis le poste hôte**, placez-vous à la racine du dépôt de formation cloné
   au jour 1, puis transférez le dossier :
   ```bash
   cd formation-admin-cloud-2026
   rsync -av code/03-cl-linux/stockline-lite/ srv-linux:~/stockline-lite/
   ```
   Le `/` final après `stockline-lite/` compte : on copie le **contenu** du dossier.

2. Relancez la même commande une seconde fois : rsync ne retransfère rien
   (c'est tout son intérêt pour les déploiements répétés).

Point de contrôle :
```bash
ssh srv-linux 'ls -l ~/stockline-lite'
```
affiche `main.py` et `requirements.txt`.

### Étape 3 — Utilisateur système et arborescence /opt/stockline (10 min)

Objectif : créer l'identité sous laquelle tournera l'application (jamais root,
jamais votre compte) et son arborescence standard.

1. Dans la session `multipass shell srv-linux`, créez l'utilisateur **système**
   `stockline` (pas de connexion possible, pas de mot de passe) :
   ```bash
   sudo adduser --system --group --home /opt/stockline --shell /usr/sbin/nologin stockline
   ```

2. Créez l'arborescence et installez le code :
   ```bash
   sudo mkdir -p /opt/stockline/app /opt/stockline/venv /opt/stockline/data
   sudo cp /home/deploy/stockline-lite/main.py /home/deploy/stockline-lite/requirements.txt /opt/stockline/app/
   sudo chown -R stockline:stockline /opt/stockline
   ```

Point de contrôle :
```bash
id stockline && ls -l /opt/stockline
```
`id` répond (l'utilisateur existe) et les trois répertoires `app`, `data`, `venv`
appartiennent à `stockline stockline`.

### Étape 4 — venv, dépendances et test manuel d'uvicorn (20 min)

Objectif : installer les dépendances dans un venv dédié et vérifier que l'API
démarre **avant** d'en faire un service (on ne « systemd-ise » jamais un
programme qu'on n'a pas vu tourner).

1. Installez le module venv et créez l'environnement :
   ```bash
   sudo apt install -y python3-venv
   sudo python3 -m venv /opt/stockline/venv
   sudo /opt/stockline/venv/bin/pip install -r /opt/stockline/app/requirements.txt
   sudo chown -R stockline:stockline /opt/stockline
   ```

2. Lancez uvicorn à la main, sous l'identité `stockline`, avec la variable
   d'environnement qui place la base dans `data/` :
   ```bash
   cd /opt/stockline/app
   sudo -u stockline env STOCKLINE_DB=/opt/stockline/data/stockline.db \
     /opt/stockline/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
   ```

3. Ouvrez un **deuxième terminal** sur le poste hôte, puis :
   ```bash
   multipass shell srv-linux
   curl http://127.0.0.1:8000/sante
   ```

4. Revenez au premier terminal et arrêtez uvicorn avec `Ctrl+C`
   (le test manuel est terminé, systemd prend le relais à l'étape suivante).

Point de contrôle : le `curl` renvoie la réponse JSON du health check
(`{"statut":"ok"}`) et le fichier `/opt/stockline/data/stockline.db` existe
(`ls -l /opt/stockline/data`).

### Étape 5 — Le service systemd stockline.service (15 min)

Objectif : faire d'uvicorn un vrai service : démarré au boot, relancé en cas
de plantage, journalisé.

1. Créez l'unité (le fichier de référence est aussi dans
   `code/03-cl-linux/stockline.service`, mais tapez-le au moins une fois —
   c'est en l'écrivant qu'on le retient) :
   ```bash
   sudo nano /etc/systemd/system/stockline.service
   ```
   Contenu complet :
   ```ini
   [Unit]
   Description=StockLine - API d'inventaire (uvicorn)
   After=network.target

   [Service]
   User=stockline
   Group=stockline
   WorkingDirectory=/opt/stockline/app
   Environment=STOCKLINE_DB=/opt/stockline/data/stockline.db
   ExecStart=/opt/stockline/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
   Restart=on-failure

   [Install]
   WantedBy=multi-user.target
   ```

2. Rechargez systemd, puis démarrez et activez le service en une commande :
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now stockline
   ```

Point de contrôle :
```bash
systemctl status stockline --no-pager
curl http://127.0.0.1:8000/sante
```
`Active: active (running)`, la ligne `Loaded:` se termine par `enabled;`,
et le curl renvoie le JSON du health check. En cas d'échec :
`journalctl -u stockline -n 30 --no-pager`.

### Étape 6 — nginx en reverse proxy (15 min)

Objectif : exposer l'API sur le port 80 sans jamais exposer uvicorn directement.

1. Installez nginx :
   ```bash
   sudo apt install -y nginx
   ```

2. Créez le site (référence : `code/03-cl-linux/stockline.conf`) :
   ```bash
   sudo nano /etc/nginx/sites-available/stockline.conf
   ```
   Contenu complet :
   ```nginx
   server {
       listen 80;
       server_name _;

       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

3. Activez le site, désactivez le site par défaut, testez puis rechargez :
   ```bash
   sudo ln -s /etc/nginx/sites-available/stockline.conf /etc/nginx/sites-enabled/stockline.conf
   sudo rm /etc/nginx/sites-enabled/default
   sudo nginx -t && sudo systemctl reload nginx
   ```

Point de contrôle : `sudo nginx -t` affiche `syntax is ok` et
`test is successful`, puis `curl http://localhost/sante` renvoie le même JSON
qu'en direct sur le port 8000.

### Étape 7 — Vérifications de bout en bout (10 min)

Objectif : valider la chaîne complète, du poste hôte jusqu'à la base SQLite.

1. Les trois niveaux du health check :
   ```bash
   # Dans la VM : API directe, puis via nginx
   curl http://127.0.0.1:8000/sante
   curl http://localhost/sante
   ```
   ```bash
   # Depuis le poste hôte (IP donnée par : multipass info srv-linux)
   curl http://<IP-VM>/sante
   ```

2. Un vrai scénario métier, depuis la VM (les champs correspondent aux modèles
   définis dans `code/03-cl-linux/stockline-lite/main.py` — en cas d'erreur 422,
   relisez-y les modèles) :
   ```bash
   curl -X POST http://localhost/produits \
     -H "Content-Type: application/json" \
     -d '{"nom": "Clavier mécanique", "sku": "KB-001"}'

   curl -X POST http://localhost/mouvements \
     -H "Content-Type: application/json" \
     -d '{"produit_id": 1, "type": "entree", "quantite": 10}'

   curl http://localhost/stocks/1
   ```

Point de contrôle : les trois `/sante` renvoient le même JSON, la création du
produit renvoie un objet avec `"id": 1`, et `GET /stocks/1` reflète le mouvement
d'entrée (stock de 10).

### Étape 8 — Sauvegarde des données : backup.sh + timer (20 min)

Objectif : réutiliser le script de sauvegarde du jour 3 pour archiver la base
chaque nuit à 03 h 00.

1. Installez le script (référence : `code/03-cl-linux/backup.sh`) :
   ```bash
   sudo nano /usr/local/bin/backup.sh
   ```
   Contenu complet :
   ```bash
   #!/usr/bin/env bash
   # backup.sh — archive un répertoire en tar.gz avec rétention (7 archives)
   # Usage : backup.sh [SOURCE_DIR] [DEST_DIR]
   set -euo pipefail

   SOURCE_DIR="${1:-/etc}"
   DEST_DIR="${2:-/var/backups/demo}"
   RETENTION=7

   log() {
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
   }

   if [ ! -d "$SOURCE_DIR" ]; then
       log "ERREUR : répertoire source introuvable : $SOURCE_DIR"
       exit 1
   fi

   mkdir -p "$DEST_DIR" 2>/dev/null || true
   if [ ! -d "$DEST_DIR" ] || [ ! -w "$DEST_DIR" ]; then
       log "ERREUR : destination non inscriptible : $DEST_DIR"
       exit 2
   fi

   NOM="$(basename "$SOURCE_DIR")"
   ARCHIVE="$DEST_DIR/$NOM-$(date +%Y%m%d-%H%M%S).tar.gz"

   log "Sauvegarde de $SOURCE_DIR vers $ARCHIVE"
   tar -czf "$ARCHIVE" -C "$(dirname "$SOURCE_DIR")" "$NOM"
   log "Archive créée : $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"

   find "$DEST_DIR" -maxdepth 1 -name "$NOM-*.tar.gz" | sort -r \
       | tail -n +$((RETENTION + 1)) | while read -r ancienne; do
       log "Suppression de l'ancienne archive : $ancienne"
       rm -f "$ancienne"
   done

   log "Sauvegarde terminée avec succès"
   exit 0
   ```
   ```bash
   sudo chmod +x /usr/local/bin/backup.sh
   ```

2. Testez-le à la main sur les données StockLine :
   ```bash
   sudo /usr/local/bin/backup.sh /opt/stockline/data /var/backups/stockline
   ls -lh /var/backups/stockline
   ```

3. Créez le couple service + timer (références : `code/03-cl-linux/backup.service`
   et `code/03-cl-linux/backup.timer`) :
   ```bash
   sudo nano /etc/systemd/system/backup.service
   ```
   ```ini
   [Unit]
   Description=Sauvegarde des donnees StockLine

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/backup.sh /opt/stockline/data /var/backups/stockline
   ```
   ```bash
   sudo nano /etc/systemd/system/backup.timer
   ```
   ```ini
   [Unit]
   Description=Sauvegarde quotidienne des donnees StockLine

   [Timer]
   OnCalendar=*-*-* 03:00:00
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

4. Activez le timer (c'est **le timer** qu'on active, pas le service) et testez
   le service une fois :
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now backup.timer
   sudo systemctl start backup.service
   ```

Point de contrôle :
```bash
systemctl list-timers backup.timer --no-pager
ls -lh /var/backups/stockline
```
`backup.timer` apparaît avec un `NEXT` à la prochaine occurrence de 03:00:00,
et `/var/backups/stockline` contient au moins deux archives `data-*.tar.gz`
(le test manuel + le `start` du service).

### Étape 9 — Durcissement express avec ufw (10 min)

Objectif : ne laisser entrer que SSH (22) et HTTP (80).

1. Autorisez **d'abord** SSH — vous êtes connecté par SSH, activer le pare-feu
   avant cette règle vous couperait la branche sur laquelle vous êtes assis —
   puis HTTP, et seulement ensuite activez :
   ```bash
   sudo ufw allow OpenSSH
   sudo ufw allow 80/tcp
   sudo ufw enable
   ```
   Répondez `y` à l'avertissement sur les connexions SSH existantes.

Point de contrôle :
```bash
sudo ufw status verbose
```
affiche `Status: active` avec les règles `22/tcp (OpenSSH) ALLOW IN` et
`80/tcp ALLOW IN` ; depuis le poste hôte, `ssh srv-linux 'echo OK'` et
`curl http://<IP-VM>/sante` fonctionnent toujours.

## Livrable attendu

Pas de rendu noté : le livrable, c'est **votre serveur en état de marche** et la
checklist ci-dessous entièrement cochée. Montrez au formateur le résultat de
`curl http://<IP-VM>/sante` depuis votre poste hôte.

### Checklist d'auto-validation

- [ ] La VM `srv-linux` est démarrée et à jour (`apt upgrade` sans erreur).
- [ ] L'utilisateur système `stockline` existe, avec shell `/usr/sbin/nologin`.
- [ ] Le code est dans `/opt/stockline/app`, tout `/opt/stockline` appartient à `stockline:stockline`.
- [ ] Le venv fonctionne : `/opt/stockline/venv/bin/uvicorn --version` répond.
- [ ] `systemctl status stockline` : `active (running)` **et** `enabled`.
- [ ] `curl http://127.0.0.1:8000/sante` répond (API directe).
- [ ] `curl http://localhost/sante` répond (via nginx).
- [ ] `curl http://<IP-VM>/sante` répond depuis le poste hôte.
- [ ] `POST /produits` puis `GET /stocks/1` renvoient des données cohérentes.
- [ ] `backup.timer` est dans `systemctl list-timers`, une archive existe dans `/var/backups/stockline`, et `ufw status` est `active` avec 22 et 80 autorisés.

> **⚠️ Pas de teardown !** Contrairement aux TP cloud, **ne supprimez pas cette
> VM** : elle resservira telle quelle au CL-TP1. Ce soir, contentez-vous de
> `multipass stop srv-linux` depuis le poste hôte.

> **ℹ️ Et après ?** Au CL-TP1 (après le bloc réseau), vous referez ce déploiement
> **en version notée**, avec PostgreSQL à la place de SQLite et un script Python
> d'exploitation en plus. Tout ce que vous venez de faire est réutilisable à
> l'identique — gardez vos notes.

## Dépannage courant

<details>
<summary>Erreur : 502 Bad Gateway en passant par nginx</summary>

Cause : nginx tourne mais n'arrive pas à joindre uvicorn — le service
`stockline` est arrêté ou en échec, ou uvicorn n'écoute pas sur `127.0.0.1:8000`
(mauvais port ou mauvaise adresse dans `ExecStart`).

Solution : `systemctl status stockline` puis `journalctl -u stockline -n 30`.
Vérifiez avec `ss -tlnp | grep 8000` qu'uvicorn écoute bien sur `127.0.0.1:8000`.
Corrigez l'unité si besoin, puis `sudo systemctl daemon-reload && sudo systemctl restart stockline`.

</details>

<details>
<summary>Erreur : `[Errno 98] Address already in use` au démarrage d'uvicorn</summary>

Cause : un autre processus occupe déjà le port 8000 — le plus souvent l'uvicorn
manuel de l'étape 4 que vous avez oublié d'arrêter avant de lancer le service.

Solution : identifiez le processus avec `ss -tlnp | grep 8000`, arrêtez-le
proprement (`Ctrl+C` dans le terminal concerné, ou `sudo kill <PID>`), puis
`sudo systemctl restart stockline`.

</details>

<details>
<summary>Erreur : `permission denied` sur /opt/stockline/data (ou `unable to open database file`)</summary>

Cause : le service tourne sous `User=stockline` mais le répertoire `data/` (ou la
base créée lors d'un test lancé en root) appartient à quelqu'un d'autre.

Solution : `ls -l /opt/stockline /opt/stockline/data` pour constater, puis
`sudo chown -R stockline:stockline /opt/stockline` et
`sudo systemctl restart stockline`.

</details>

<details>
<summary>Erreur : l'unité reste en échec (ou garde l'ancien comportement) après modification du .service</summary>

Cause : systemd travaille sur une copie en mémoire des unités — vous avez oublié
`daemon-reload` après avoir modifié le fichier. Indice : `systemctl status`
affiche `Warning: The unit file ... changed on disk`.

Solution : `sudo systemctl daemon-reload` puis `sudo systemctl restart stockline`.
Toujours enchaîner les deux après chaque modification d'unité.

</details>

<details>
<summary>Erreur : curl depuis le poste hôte échoue (timeout ou connexion refusée) alors que tout marche dans la VM</summary>

Cause : soit ufw a été activé sans la règle `80/tcp`, soit vous n'utilisez pas la
bonne IP (elle peut changer après un `multipass stop/start`).

Solution : dans la VM, `sudo ufw status` — ajoutez `sudo ufw allow 80/tcp` si la
règle manque. Sur l'hôte, relevez l'IP actuelle avec `multipass info srv-linux`
et réessayez `curl http://<IP-VM>/sante`.

</details>

## Pour aller plus loin

- Testez l'auto-réparation : tuez le processus uvicorn
  (`sudo kill -9 $(systemctl show -p MainPID --value stockline)`) et observez
  `Restart=on-failure` le relancer (`systemctl status stockline`, compteur de
  redémarrages dans `journalctl -u stockline`).
- Suivez les requêtes en direct : `journalctl -u stockline -f` dans un terminal
  pendant que vous faites des `curl` dans un autre.
- Réinvestissez le tunnel SSH du matin : depuis l'hôte,
  `ssh -L 8000:localhost:8000 srv-linux` puis `curl http://localhost:8000/sante`
  — vous atteignez uvicorn directement, sans passer par nginx ni ouvrir le port.
- Modifiez `main.py` sur le poste hôte, relancez le `rsync` de l'étape 2, copiez
  le fichier dans `/opt/stockline/app` et redéployez : vous venez d'inventer
  votre premier pipeline de déploiement (à la main).
