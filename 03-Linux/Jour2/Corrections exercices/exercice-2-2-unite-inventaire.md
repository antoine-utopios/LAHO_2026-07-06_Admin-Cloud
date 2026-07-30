# Solution — Exercice 2-2 : Une unité systemd pour le script d'inventaire

## Approche pédagogique

Après le diagnostic (2-1), la **création** : les apprenants écrivent leur
première unité de zéro. Deux idées à ancrer : (1) on teste toujours le script
à la main avant de l'emballer dans systemd — sinon on débogue deux choses à la
fois ; (2) un `Type=oneshot` qui affiche `inactive (dead)` n'est PAS en panne :
c'est `status=0/SUCCESS` qui fait foi. Le reboot de la partie 3 est le moment
fort : le rapport régénéré « tout seul » pendant le boot rend systemd concret.
Réutilisation du bloc CL-PYTHON : faire relire le script 2 minutes en binôme
avant de l'installer (socket, /proc/uptime, shutil.disk_usage — tout est connu).

## Solution détaillée

Connexion : `multipass shell srv-linux`.

### Partie 1 — Installer et tester le script à la main

Raisonnement : installation dans `/usr/local/bin` (l'emplacement standard des
exécutables ajoutés par l'admin local), droits `755` (tout le monde exécute,
seul root modifie), répertoire de données créé d'avance — c'est la cause
d'échec n° 1 du script.

Installation (au choix `sudo nano /usr/local/bin/inventaire.py` et coller,
ou par heredoc) :

```bash
sudo tee /usr/local/bin/inventaire.py > /dev/null <<'FIN'
#!/usr/bin/env python3
"""Inventaire système : hostname, uptime, disque -> /var/lib/inventaire/rapport.txt"""

import shutil
import socket
from datetime import datetime

RAPPORT = "/var/lib/inventaire/rapport.txt"


def lire_uptime():
    with open("/proc/uptime") as f:
        secondes = float(f.read().split()[0])
    heures, reste = divmod(int(secondes), 3600)
    minutes = reste // 60
    return f"{heures} h {minutes:02d} min"


def main():
    total, utilise, libre = shutil.disk_usage("/")
    go = 1024 ** 3
    lignes = [
        f"Rapport genere  : {datetime.now():%Y-%m-%d %H:%M:%S}",
        f"Machine         : {socket.gethostname()}",
        f"Uptime          : {lire_uptime()}",
        f"Disque / total  : {total / go:.1f} Go",
        f"Disque / occupe : {utilise / go:.1f} Go ({utilise / total * 100:.0f} %)",
        f"Disque / libre  : {libre / go:.1f} Go",
    ]
    with open(RAPPORT, "w") as f:
        f.write("\n".join(lignes) + "\n")
    print(f"Rapport ecrit dans {RAPPORT}")


if __name__ == "__main__":
    main()
FIN

sudo chmod 755 /usr/local/bin/inventaire.py
sudo mkdir -p /var/lib/inventaire
```

Test manuel :

```bash
sudo /usr/local/bin/inventaire.py
# Rapport ecrit dans /var/lib/inventaire/rapport.txt
cat /var/lib/inventaire/rapport.txt
```

```text
Rapport genere  : 2026-07-07 14:20:33
Machine         : srv-linux
Uptime          : 2 h 05 min
Disque / total  : 19.3 Go
Disque / occupe : 2.1 Go (11 %)
Disque / libre  : 17.2 Go
```

Explication :

- `chmod 755` : `rwxr-xr-x` — exécutable par tous, modifiable par root seul.
- Le `sudo` est nécessaire : `/var/lib/inventaire` appartient à root et le
  script y écrit. Lancé sans sudo : `PermissionError: [Errno 13]`.
- Points du script à faire verbaliser : `/proc/uptime` (1er champ = secondes
  écoulées depuis le boot — le noyau expose son état en fichiers texte),
  `shutil.disk_usage("/")` (équivalent stdlib de `df`),
  `socket.gethostname()`.

### Partie 2 — Écrire l'unité

```bash
sudo tee /etc/systemd/system/inventaire.service > /dev/null <<'FIN'
[Unit]
Description=Inventaire systeme au demarrage (rapport dans /var/lib/inventaire)

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/bin/inventaire.py

[Install]
WantedBy=multi-user.target
FIN

sudo systemctl daemon-reload
sudo rm /var/lib/inventaire/rapport.txt
sudo systemctl start inventaire.service
```

Explication ligne à ligne de l'unité :

- `[Unit] Description=` : le libellé qui apparaîtra dans `systemctl status`
  et les journaux — toujours le renseigner.
- `Type=oneshot` : systemd lance la commande, attend sa fin, et considère le
  travail fait. Adapté aux tâches ponctuelles (vs `simple` pour un processus
  qui reste en vie, comme horodatage en 2-1).
- `ExecStart=/usr/bin/python3 /usr/local/bin/inventaire.py` : chemins
  **absolus** obligatoires — systemd ne consulte pas de `PATH` de shell.
  (Le script étant exécutable avec shebang, `ExecStart=/usr/local/bin/inventaire.py`
  seul fonctionne aussi — cf. variantes.)
- `[Install] WantedBy=multi-user.target` : au `enable`, un lien est créé dans
  `multi-user.target.wants/` → l'unité est tirée à chaque boot en mode
  serveur.

Contrôle :

```bash
systemctl status inventaire.service --no-pager
```

```text
○ inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire)
     Loaded: loaded (/etc/systemd/system/inventaire.service; disabled; preset: enabled)
     Active: inactive (dead)

Jul 07 14:31:05 srv-linux systemd[1]: Starting inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire)...
Jul 07 14:31:05 srv-linux python3[2650]: Rapport ecrit dans /var/lib/inventaire/rapport.txt
Jul 07 14:31:05 srv-linux systemd[1]: inventaire.service: Deactivated successfully.
Jul 07 14:31:05 srv-linux systemd[1]: Finished inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire).
```

```bash
cat /var/lib/inventaire/rapport.txt   # rapport recréé, daté de l'instant
```

**Réponse à la question** : nginx est un démon — un processus qui reste en
mémoire pour servir des requêtes, donc `active (running)`. Notre unité est un
`Type=oneshot` : le script s'exécute, écrit son rapport et **se termine** ;
il n'y a plus de processus à montrer, d'où `inactive (dead)`. Le succès se lit
ailleurs : `Deactivated successfully` / `Finished` dans les journaux, et
`status=0/SUCCESS` sur la ligne `Process:` (visible juste après l'exécution).
Un échec afficherait `failed` avec `status=1/FAILURE`.

### Partie 3 — Au boot, sans intervention humaine

```bash
sudo systemctl enable inventaire.service
# Created symlink /etc/systemd/system/multi-user.target.wants/inventaire.service → /etc/systemd/system/inventaire.service.
systemctl is-enabled inventaire.service
# enabled

date
# Tue Jul  7 14:40:12 CEST 2026
sudo reboot
```

La session est coupée (`Connection to ... closed`). Depuis le poste hôte,
attendre ~20 secondes puis :

```bash
multipass shell srv-linux
cat /var/lib/inventaire/rapport.txt
```

```text
Rapport genere  : 2026-07-07 14:41:03
Machine         : srv-linux
Uptime          : 0 h 00 min
Disque / total  : 19.3 Go
Disque / occupe : 2.1 Go (11 %)
Disque / libre  : 17.2 Go
```

Deux preuves dans le rapport lui-même : l'horodatage postérieur au `reboot`,
et surtout `Uptime : 0 h 00 min` — le script a tourné dans les premières
secondes de vie du système, avant toute connexion humaine.

Preuve côté journaux, limitée au boot courant (`-b`) :

```bash
journalctl -u inventaire -b --no-pager
```

```text
Jul 07 14:41:03 srv-linux systemd[1]: Starting inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire)...
Jul 07 14:41:03 srv-linux python3[912]: Rapport ecrit dans /var/lib/inventaire/rapport.txt
Jul 07 14:41:03 srv-linux systemd[1]: inventaire.service: Deactivated successfully.
Jul 07 14:41:03 srv-linux systemd[1]: Finished inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire).
```

## Variantes acceptables

1. `ExecStart=/usr/local/bin/inventaire.py` (sans `python3` devant) :
   - Avantage : plus court ; fonctionne car le script est exécutable et porte
     le shebang `#!/usr/bin/env python3`.
   - Inconvénient : dépend du bit x et du shebang ; expliciter l'interpréteur
     rend l'unité plus robuste et plus lisible.
2. Script créé avec `nano` puis `sudo cp` au lieu du heredoc `sudo tee` :
   strictement équivalent ; le heredoc est simplement plus reproductible.
3. `ExecStartPre=/usr/bin/mkdir -p /var/lib/inventaire` dans l'unité (ou
   `StateDirectory=inventaire`, plus idiomatique) : excellente initiative —
   l'unité devient autonome même sur une machine vierge. `StateDirectory`
   pourra être mentionné aux plus rapides.
4. `WantedBy=default.target` : fonctionne aussi sur un serveur, mais la
   convention pour les services système est `multi-user.target` — s'y tenir.


## Bonus

### 1. RemainAfterExit

```bash
sudo nano /etc/systemd/system/inventaire.service
```

Section `[Service]` complétée :

```ini
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/python3 /usr/local/bin/inventaire.py
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart inventaire.service
systemctl status inventaire.service --no-pager
```

```text
● inventaire.service - Inventaire systeme au demarrage (rapport dans /var/lib/inventaire)
     Loaded: loaded (/etc/systemd/system/inventaire.service; enabled; preset: enabled)
     Active: active (exited) since Tue 2026-07-07 15:02:41 CEST; 10s ago
```

Différence : `active (exited)` au lieu de `inactive (dead)` — systemd
considère l'unité comme « accomplie et toujours en vigueur » bien que le
processus soit terminé. Utilité : si d'autres unités déclarent
`After=inventaire.service` / `Requires=inventaire.service`, l'état `active`
matérialise « l'inventaire a été fait sur ce boot » ; c'est aussi ce qui
permet un `systemctl stop` symétrique (exécution d'un éventuel `ExecStop=`).
Motif classique des unités d'initialisation (pare-feu, montages, migrations).

### 2. Sentinelle disque

```bash
sudo tee /usr/local/bin/verif-disque.sh > /dev/null <<'FIN'
#!/usr/bin/env bash
SEUIL=90
USAGE=$(df --output=pcent / | tail -n 1 | tr -d ' %')
if [ "$USAGE" -gt "$SEUIL" ]; then
  echo "ALERTE : disque / rempli a ${USAGE}% (seuil ${SEUIL}%)"
  exit 1
fi
echo "OK : disque / rempli a ${USAGE}% (seuil ${SEUIL}%)"
FIN
sudo chmod 755 /usr/local/bin/verif-disque.sh

sudo tee /etc/systemd/system/verif-disque.service > /dev/null <<'FIN'
[Unit]
Description=Sentinelle disque - echoue si / depasse le seuil d'occupation

[Service]
Type=oneshot
ExecStart=/usr/local/bin/verif-disque.sh

[Install]
WantedBy=multi-user.target
FIN

sudo systemctl daemon-reload
sudo systemctl enable --now verif-disque.service
systemctl status verif-disque.service --no-pager
# ... Deactivated successfully. (status=0/SUCCESS)
# journal : OK : disque / rempli a 11% (seuil 90%)
```

Test de l'échec — abaisser le seuil à 5 :

```bash
sudo sed -i 's/^SEUIL=90/SEUIL=5/' /usr/local/bin/verif-disque.sh
sudo systemctl restart verif-disque.service
# Job for verif-disque.service failed because the control process exited with error code.
systemctl status verif-disque.service --no-pager
```

```text
× verif-disque.service - Sentinelle disque - echoue si / depasse le seuil d'occupation
     Active: failed (Result: exit-code)
    Process: 3120 ExecStart=/usr/local/bin/verif-disque.sh (code=exited, status=1/FAILURE)
...
Jul 07 15:10:22 srv-linux verif-disque.sh[3120]: ALERTE : disque / rempli a 11% (seuil 5%)
```

```bash
systemctl --failed
# UNIT                 LOAD   ACTIVE SUB    DESCRIPTION
# ● verif-disque.service loaded failed failed Sentinelle disque - ...
```

C'est le mécanisme : un script qui sort avec un code non nul fait passer
l'unité en `failed`, visible d'un coup d'œil dans `systemctl --failed` —
première brique de supervision (au jour 4 : `uptime`, `free`, puis CloudWatch
côté AWS). Remise en état :

```bash
sudo sed -i 's/^SEUIL=5/SEUIL=90/' /usr/local/bin/verif-disque.sh
sudo systemctl restart verif-disque.service
systemctl --failed
# 0 loaded units listed.
```
