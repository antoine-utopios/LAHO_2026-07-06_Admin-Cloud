# Solution — Exercice 2-1 : Un service qui ne démarre pas

## Approche pédagogique

Premier vrai exercice de **diagnostic** du cursus : on n'évalue pas la
correction elle-même (deux lignes à changer) mais la **démarche** —
status → journaux → hypothèse → vérification terrain → correction → contrôle.
L'unité contient DEUX pannes (User inexistant, puis ExecStart faux) et systemd
ne révèle que la première : les apprenants qui corrigent `User=` verront le
service échouer *différemment* — c'est voulu, c'est le moment pédagogique clé
(« un diagnostic n'est jamais fini tant que le service ne tourne pas »).
Veiller à ce que personne ne lise le bloc de mise en place : le rappeler à
l'oral au lancement.

Note technique : avec `User=horodata` inexistant, le premier échec est
`217/USER` ; une fois l'utilisateur réglé, le chemin `/usr/local/bin/horodatage.sh`
inexistant produit `203/EXEC`. L'ordre de découverte est donc déterministe.

## Solution détaillée

Connexion : `multipass shell srv-linux`. La mise en place de l'énoncé a été
collée au préalable ; `sudo systemctl start horodatage.service` a affiché :

```text
Job for horodatage.service failed because of unavailable resources or another error.
See "systemctl status horodatage.service" and "journalctl -xeu horodatage.service" for details.
```

### Partie 1 — Constater et qualifier la panne

Raisonnement : toujours commencer par `systemctl status`, puis élargir avec
`journalctl -u` si le status ne suffit pas.

```bash
systemctl status horodatage.service --no-pager
```

Sortie attendue (extrait) :

```text
× horodatage.service - Horodatage - journalise la date toutes les 30 secondes
     Loaded: loaded (/etc/systemd/system/horodatage.service; disabled; preset: enabled)
     Active: failed (Result: exit-code) since Tue 2026-07-07 11:02:41 CEST; 20s ago
    Process: 2231 ExecStart=/usr/local/bin/horodatage.sh (code=exited, status=217/USER)
   Main PID: 2231 (code=exited, status=217/USER)

Jul 07 11:02:41 srv-linux systemd[1]: horodatage.service: Main process exited, code=exited, status=217/USER
Jul 07 11:02:41 srv-linux systemd[1]: horodatage.service: Failed with result 'exit-code'.
Jul 07 11:02:41 srv-linux systemd[1]: Failed to start horodatage.service - Horodatage - journalise la date toutes les 30 secondes.
```

```bash
journalctl -u horodatage -b --no-pager
```

On y retrouve les mêmes lignes, plus éventuellement :

```text
Jul 07 11:02:41 srv-linux (odatage.sh)[2231]: horodatage.service: Failed to determine user credentials: No such process
Jul 07 11:02:41 srv-linux (odatage.sh)[2231]: horodatage.service: Failed at step USER spawning /usr/local/bin/horodatage.sh: No such process
```

Lecture :

- État : `failed (Result: exit-code)` — le service a tenté de démarrer et a
  échoué (systemd a aussi épuisé les tentatives de `Restart=on-failure` :
  lignes `Start request repeated too quickly` possibles).
- Code : `status=217/USER` → systemd n'a pas pu prendre l'identité demandée.
  Hypothèse : l'utilisateur déclaré dans `User=` n'existe pas.

### Partie 2 — Vérifier l'hypothèse sur le terrain

```bash
cat /etc/systemd/system/horodatage.service
```

```text
[Unit]
Description=Horodatage - journalise la date toutes les 30 secondes

[Service]
ExecStart=/usr/local/bin/horodatage.sh
User=horodata
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Confrontation au réel — anomalie n° 1, l'utilisateur :

```bash
id horodata
# id: 'horodata': no such user
```

Anomalie n° 2, l'exécutable :

```bash
ls -l /usr/local/bin/horodatage.sh
# ls: cannot access '/usr/local/bin/horodatage.sh': No such file or directory
```

Où est le vrai script ? Les applications maison sont sous `/opt` :

```bash
ls -l /opt/horodatage/
# -rwxr-xr-x 1 root root 108 Jul  7 11:00 horodatage.sh
cat /opt/horodatage/horodatage.sh    # une boucle date + sleep 30 : cohérent
```

Bilan : **deux** anomalies prouvées — `User=horodata` (utilisateur absent) et
`ExecStart=/usr/local/bin/horodatage.sh` (chemin faux, le script est dans
`/opt/horodatage/horodatage.sh`).

### Partie 3 — Corriger, recharger, vérifier

Correction de l'unité :

```bash
sudo nano /etc/systemd/system/horodatage.service
```

Politique A (recommandée — créer l'utilisateur système manquant, moindre
privilège) : d'abord

```bash
sudo adduser --system --group --no-create-home --shell /usr/sbin/nologin horodata
id horodata
# uid=997(horodata) gid=997(horodata) groups=997(horodata)
```

puis l'unité corrigée :

```ini
[Unit]
Description=Horodatage - journalise la date toutes les 30 secondes

[Service]
ExecStart=/opt/horodatage/horodatage.sh
User=horodata
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Politique B (acceptable ici — supprimer la ligne `User=`, le service tourne
alors en root) : même unité sans la ligne `User=horodata`. À justifier :
pour un script qui ne fait qu'écrire dans le journal, root fonctionne, mais
la règle du moindre privilège plaide pour la politique A 

Application et vérification :

```bash
sudo systemctl daemon-reload
sudo systemctl restart horodatage.service
systemctl status horodatage.service --no-pager
```

```text
● horodatage.service - Horodatage - journalise la date toutes les 30 secondes
     Loaded: loaded (/etc/systemd/system/horodatage.service; disabled; preset: enabled)
     Active: active (running) since Tue 2026-07-07 11:15:02 CEST; 12s ago
   Main PID: 2410 (horodatage.sh)
      Tasks: 2 (limit: 4557)
...
Jul 07 11:15:02 srv-linux horodatage.sh[2410]: Horodatage : 2026-07-07 11:15:02
```

Suivi en direct (~1 min, deux lignes espacées de 30 s) :

```bash
journalctl -u horodatage -f
# Jul 07 11:15:02 srv-linux horodatage.sh[2410]: Horodatage : 2026-07-07 11:15:02
# Jul 07 11:15:32 srv-linux horodatage.sh[2410]: Horodatage : 2026-07-07 11:15:32
# Ctrl+C pour sortir
```

Survie au redémarrage :

```bash
sudo systemctl enable horodatage.service
# Created symlink /etc/systemd/system/multi-user.target.wants/horodatage.service → /etc/systemd/system/horodatage.service.
sudo reboot
```

Puis, depuis le poste hôte, se reconnecter et contrôler :

```bash
multipass shell srv-linux
systemctl is-active horodatage && systemctl is-enabled horodatage
# active
# enabled
journalctl -u horodatage -n 4 --no-pager
```

(remarque : `enable --now` en une fois est équivalent à `enable` + `start` ;
ici le service tournait déjà, `enable` seul suffit.)

Explication des étapes :

- `daemon-reload` : systemd relit les fichiers d'unité ; sans lui, il
  travaille sur l'ancienne version en mémoire (il l'indique d'ailleurs par un
  avertissement « changed on disk » dans status).
- `restart` : stop + start ; sur un service `failed`, `start` suffirait aussi.
- `enable` crée le lien symbolique dans `multi-user.target.wants/` — c'est
  toute la différence entre « tourne maintenant » et « tournera au boot ».


## Bonus

1. Tuer le processus et observer l'auto-réparation :

```bash
systemctl status horodatage --no-pager | grep "Main PID"
#    Main PID: 2410 (horodatage.sh)
sudo kill 2410
sleep 2
systemctl status horodatage --no-pager
```

Sortie attendue : le service est de nouveau `active (running)` avec un
**nouveau** `Main PID`, et le journal montre :

```text
Jul 07 11:32:10 srv-linux systemd[1]: horodatage.service: Main process exited, code=killed, status=15/TERM
Jul 07 11:32:10 srv-linux systemd[1]: horodatage.service: Failed with result 'signal'.
Jul 07 11:32:10 srv-linux systemd[1]: horodatage.service: Scheduled restart job, restart counter is at 1.
Jul 07 11:32:10 srv-linux systemd[1]: Started horodatage.service - Horodatage - journalise la date toutes les 30 secondes.
```

La directive responsable est `Restart=on-failure` : mort par signal ou code
de sortie non nul = échec → relance automatique.

2. Arrêt propre :

```bash
sudo systemctl stop horodatage
systemctl is-active horodatage
# inactive
```

Le service ne redémarre PAS : un `systemctl stop` est un arrêt **demandé par
l'administrateur**, pas un échec — `on-failure` ne se déclenche donc pas.
(Une valeur `Restart=always` relancerait même après un stop du processus par
signal externe, mais jamais après un `systemctl stop`, que systemd traite à
part.) Différence à retenir : systemd distingue « on me l'a demandé » de
« c'est tombé en panne ».
