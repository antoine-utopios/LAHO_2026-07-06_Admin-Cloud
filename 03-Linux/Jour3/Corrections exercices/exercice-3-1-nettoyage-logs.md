# Solution — Exercice 3-1 : Script de nettoyage de logs

## Approche pédagogique

Cet exercice consolide toute la journée 3 : arguments avec défauts (revus de `backup.sh`), `set -euo pipefail`, codes retour explicites, `find` par âge, et planification cron. L'apprenant doit produire un script **rejouable** : la deuxième exécution « à vide » (0 compressé / 0 supprimé) est le vrai test de robustesse. Laissez les binômes se heurter au comportement de `find -mtime` (+0 = plus de 24 h) plutôt que de le donner d'emblée : la lecture de `man find` fait partie des objectifs implicites. Chronométrage conseillé : 15 min partie 1, 25 min partie 2, 15 min partie 3, 5 min de marge ou bonus.

## Solution détaillée

### Mise en place — vérification

Après le copier-coller du bloc fourni, `ls -l /var/log/appdemo` doit donner (dates relatives au jour de la session, ici le 2026-07-02) :

```text
-rw-r--r-- 1 ubuntu ubuntu 30 Jun 23 00:00 app-2026-06-23.log
-rw-r--r-- 1 ubuntu ubuntu 30 Jun 24 00:00 app-2026-06-24.log
…
-rw-r--r-- 1 ubuntu ubuntu 30 Jul  2 14:00 app-2026-07-02.log
```

10 fichiers, propriétaire `ubuntu` (le `chown` évite d'imposer sudo dans le script — voir variantes).

### Parties 1 et 2 — Le script complet

Raisonnement partie 1 : les défauts se posent avec `${1:-…}`, la garde d'existence avec `[[ -d … ]]`, le message d'erreur part sur stderr (`>&2`) et le script sort en `exit 1` — même grammaire que `backup.sh` de la démo 3-1.

Raisonnement partie 2 : on **compte d'abord** (find + wc -l), on **agit ensuite** (find -exec / -delete) : deux passes, plus simple et plus lisible qu'un compteur dans une boucle. `-mtime +0` = modifié il y a plus de 24 h ; `-mtime +N` = strictement plus de N jours. `wc -l` renvoie `0` sans code d'erreur : compatible `set -e`.

Fichier `~/exploitation/scripts/nettoie-logs.sh` complet :

```bash
#!/usr/bin/env bash
# nettoie-logs.sh — compresse les .log de plus de 1 jour, supprime les .log.gz
# de plus de N jours. Usage : nettoie-logs.sh [repertoire] [retention_jours]
set -euo pipefail

REPERTOIRE="${1:-/var/log/appdemo}"
RETENTION="${2:-7}"

if [[ ! -d "$REPERTOIRE" ]]; then
    echo "ERREUR : le répertoire $REPERTOIRE n'existe pas." >&2
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nettoyage de $REPERTOIRE (rétention $RETENTION jours)"

# 1. Compression des .log de plus de 1 jour
NB_COMPRESSES=$(find "$REPERTOIRE" -maxdepth 1 -name "*.log" -mtime +0 | wc -l)
find "$REPERTOIRE" -maxdepth 1 -name "*.log" -mtime +0 -exec gzip {} \;

# 2. Suppression des .log.gz plus vieux que N jours
NB_SUPPRIMES=$(find "$REPERTOIRE" -maxdepth 1 -name "*.log.gz" -mtime +"$RETENTION" | wc -l)
find "$REPERTOIRE" -maxdepth 1 -name "*.log.gz" -mtime +"$RETENTION" -delete

echo "Fichiers compressés : $NB_COMPRESSES"
echo "Archives supprimées : $NB_SUPPRIMES"
exit 0
```

Mise en place et tests :

```bash
mkdir -p ~/exploitation/scripts ~/exploitation/rapports
nano ~/exploitation/scripts/nettoie-logs.sh      # coller le script
chmod +x ~/exploitation/scripts/nettoie-logs.sh

# Test répertoire absent → code 1
~/exploitation/scripts/nettoie-logs.sh /repertoire/inexistant ; echo $?
# ERREUR : le répertoire /repertoire/inexistant n'existe pas.
# 1

# Première exécution réelle → code 0
~/exploitation/scripts/nettoie-logs.sh ; echo $?
# [2026-07-02 14:05:12] Nettoyage de /var/log/appdemo (rétention 7 jours)
# Fichiers compressés : 9
# Archives supprimées : 2
# 0

ls /var/log/appdemo
# app-2026-06-25.log.gz  app-2026-06-26.log.gz … app-2026-07-01.log.gz  app-2026-07-02.log

# Deuxième exécution → rejouable, 0/0
~/exploitation/scripts/nettoie-logs.sh ; echo $?
# Fichiers compressés : 0
# Archives supprimées : 0
# 0
```

Explication ligne par ligne (les lignes qui comptent) :

- `set -euo pipefail` : arrêt à la première erreur (`-e`), erreur sur variable non définie (`-u`), un pipe échoue si un maillon échoue (`pipefail`).
- `REPERTOIRE="${1:-/var/log/appdemo}"` : argument 1 s'il est fourni, défaut sinon. Idem `RETENTION`.
- `[[ ! -d "$REPERTOIRE" ]]` : garde d'existence ; `>&2` envoie le message sur la sortie d'erreur ; `exit 1` = code retour contractuel « répertoire absent ».
- `find … -maxdepth 1 -name "*.log" -mtime +0` : fichiers `.log` du répertoire seul (pas les sous-répertoires), modifiés il y a plus de 24 h. Détail d'arithmétique `find` : `-mtime +0` = âge > 1 jour ; `-mtime +7` = âge > 7 jours révolus (les fichiers de 8 jours et plus). Avec la mise en place (0 à 9 jours), la première passe compresse les 9 fichiers d'hier et avant, la seconde supprime les archives de 8 et 9 jours : 9 / 2.
- Comptage AVANT action : le second `find` retrouve exactement les mêmes fichiers, donc le compte est juste ; après `gzip` les `.log` n'existent plus, d'où l'ordre compter-puis-agir.
- `-exec gzip {} \;` : gzip remplace chaque `fichier.log` par `fichier.log.gz` en conservant la date de modification (c'est ce qui permet à la passe de suppression de fonctionner sur l'âge d'origine).
- `-delete` : suppression intégrée à find, plus sûre que `-exec rm` (pas de souci d'espaces).

### Partie 3 — Planification cron

```bash
crontab -e     # choisir 1 (nano) au premier lancement
```

Ligne à ajouter :

```text
0 4 * * * /home/ubuntu/exploitation/scripts/nettoie-logs.sh >> /home/ubuntu/exploitation/rapports/nettoie-logs.journal 2>&1
```

Lecture : minute 0, heure 4, tous les jours/mois/jours-de-semaine ; `>>` ajoute (n'écrase pas) ; `2>&1` capture aussi les erreurs — sans lui, les messages `ERREUR :` partiraient dans le vide (cron enverrait un mail local que personne ne lit).

Vérifications :

```bash
crontab -l
# 0 4 * * * /home/ubuntu/exploitation/scripts/nettoie-logs.sh >> /home/ubuntu/exploitation/rapports/nettoie-logs.journal 2>&1

# Exécution manuelle de la commande exacte de cron :
/home/ubuntu/exploitation/scripts/nettoie-logs.sh >> /home/ubuntu/exploitation/rapports/nettoie-logs.journal 2>&1
cat ~/exploitation/rapports/nettoie-logs.journal
# [2026-07-02 14:20:03] Nettoyage de /var/log/appdemo (rétention 7 jours)
# Fichiers compressés : 0
# Archives supprimées : 0
```

Insister : chemins **absolus** dans la crontab (cron a un PATH minimal et démarre dans `$HOME`, pas dans le répertoire du script).

## Variantes acceptables

1. Compression avec `find … -print0 | xargs -0 gzip` : équivalent à `-exec`, plus rapide sur de gros volumes (un seul processus gzip).
   - Avantage : performance, idiome très courant en production.
   - Inconvénient : moins lisible pour un débutant ; le comptage doit toujours se faire à part.
2. Boucle `while read` sur `find` avec compteur incrémental : `while IFS= read -r f; do gzip "$f"; ((++nb)); done < <(find …)`. Une seule passe, mais attention : `((nb++))` renvoie 1 quand nb vaut 0 → plantage avec `set -e` ; il faut `((++nb))` ou `nb=$((nb+1))`. Bon point de discussion, pas exigible.
3. `-mtime +1` au lieu de `+0` pour la compression : accepté si l'apprenant justifie (« plus de 2 jours ») — l'énoncé dit « plus de 1 jour », donc `+0` est la réponse canonique ; l'important est qu'il sache expliquer la sémantique.
4. `crontab` de root ou fichier `/etc/cron.d/` : fonctionne, mais hors périmètre (le répertoire appartient à `ubuntu` grâce à la mise en place) ; faire remarquer qu'en prod, un nettoyage de `/var/log` tournerait plutôt sous root ou via logrotate.

## Erreurs classiques à repérer en correction

| Erreur observée | Cause probable | Comment corriger |
|-----------------|----------------|------------------|
| Le script affiche « Fichiers compressés : 0 » alors que des fichiers ont été gzippés | Comptage APRÈS le `gzip` : les `.log` n'existent plus au moment du `wc -l` | Compter avant d'agir (deux `find` successifs, comptage d'abord) |
| `gzip: app-….log.gz already has .gz suffix` en relançant | Le motif `-name "*.log"` matche aussi… non : c'est un motif `*.log*` trop large écrit par l'apprenant | Revenir au motif strict `"*.log"` (les `.log.gz` ne matchent pas) |
| Script qui plante à la 2ᵉ exécution avec `set -e` | Un `grep` de filtrage intermédiaire qui ne matche rien (code 1) | Supprimer le grep inutile ou suffixer `|| true` ; `find | wc -l` seul ne pose aucun problème |
| Cron ne fait rien à 04h00 | Chemin relatif dans la crontab, ou script non exécutable | Chemin absolu + `chmod +x` ; tester la commande exacte à la main |
| Journal cron vide alors que le script échoue | `2>&1` oublié : stderr part en mail local | Ajouter `2>&1` APRÈS la redirection `>> fichier` (l'ordre compte) |
| `Permission denied` sur /var/log/appdemo | Mise en place relancée avec sudo sans le `chown` final, ou VM recréée | Rejouer le bloc de mise en place complet (le chown en fait partie) |
| `-mtime 7` sans le `+` | Confusion « exactement 7 jours » vs « plus de 7 jours » | Expliquer la triple sémantique `N` / `+N` / `-N` de find |


## Bonus — version timer systemd

Fichier `/etc/systemd/system/nettoie-logs.service` :

```ini
[Unit]
Description=Nettoyage des logs appdemo

[Service]
Type=oneshot
User=ubuntu
ExecStart=/home/ubuntu/exploitation/scripts/nettoie-logs.sh
```

Fichier `/etc/systemd/system/nettoie-logs.timer` :

```ini
[Unit]
Description=Nettoyage quotidien des logs appdemo a 04h00

[Timer]
OnCalendar=*-*-* 04:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Mise en service et vérifications :

```bash
sudo nano /etc/systemd/system/nettoie-logs.service
sudo nano /etc/systemd/system/nettoie-logs.timer
sudo systemctl daemon-reload
sudo systemctl enable --now nettoie-logs.timer
systemctl list-timers | grep nettoie
# Thu 2026-07-03 04:00:00 UTC  …  nettoie-logs.timer  nettoie-logs.service

# Déclenchement immédiat pour tester :
sudo systemctl start nettoie-logs.service
journalctl -u nettoie-logs.service -n 5
# … srv-linux nettoie-logs.sh[…]: [2026-07-02 14:30:41] Nettoyage de /var/log/appdemo (rétention 7 jours)
# … srv-linux nettoie-logs.sh[…]: Fichiers compressés : 0
# … srv-linux nettoie-logs.sh[…]: Archives supprimées : 0

crontab -e    # retirer la ligne 0 4 * * * pour ne pas nettoyer deux fois
```

Avantages à faire verbaliser (mêmes réponses que la question 6 du quiz J3) : sortie captée automatiquement par le journal (`journalctl -u`, plus de redirection à écrire), `Persistent=true` rattrape une exécution manquée si la VM était éteinte à 04h00, `systemctl list-timers` donne une supervision immédiate de toutes les tâches planifiées, et l'unité bénéficie des dépendances/conditions systemd.
