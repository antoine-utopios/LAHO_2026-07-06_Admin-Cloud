# Exercice 3-1 — Script de nettoyage de logs

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 60 min
> Difficulté : 3 / 5
> Type : Exercice d'application

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Écrire un script bash robuste avec arguments, valeurs par défaut, codes retour et `set -euo pipefail`
- Manipuler `find` pour sélectionner des fichiers selon leur âge, les compresser et les supprimer
- Planifier une tâche récurrente avec cron et journaliser sa sortie dans un fichier

## Prérequis

- Avoir suivi les parties « Scripting bash » et « cron et timers systemd » du module 03 (jour 3)
- Environnement : VM Multipass `srv-linux` (Ubuntu Server 24.04 LTS), utilisateur `ubuntu` — connexion : `multipass shell srv-linux`
- Outils : bash, find, gzip, crontab, nano

## Contexte

Une application interne (appelons-la « appdemo ») écrit ses journaux dans `/var/log/appdemo`, un fichier par jour, et personne n'a jamais configuré logrotate pour elle. Résultat : les fichiers `.log` s'accumulent et l'équipe d'exploitation vous demande un script de nettoyage maison, planifié chaque nuit. C'est un grand classique du métier : sur une instance EC2, un disque rempli par des logs oubliés est l'une des pannes les plus fréquentes. Votre mission : écrire `nettoie-logs.sh`, le tester, puis le planifier avec cron.

## Mise en place (copier-coller tel quel)

Connectez-vous à la VM (`multipass shell srv-linux`) puis copiez-collez ce bloc en une seule fois. Il crée `/var/log/appdemo` avec une dizaine de fichiers `.log` dont les dates de modification s'étalent sur les 10 derniers jours :

```bash
sudo mkdir -p /var/log/appdemo
for i in 0 1 2 3 4 5 6 7 8 9; do
  d=$(date -d "$i days ago" +%Y-%m-%d)
  echo "journal appdemo du $d" | sudo tee "/var/log/appdemo/app-$d.log" > /dev/null
  sudo touch -d "$i days ago" "/var/log/appdemo/app-$d.log"
done
sudo chown -R ubuntu:ubuntu /var/log/appdemo
ls -l /var/log/appdemo
```

Résultat attendu : `ls -l /var/log/appdemo` affiche 10 fichiers `app-AAAA-MM-JJ.log` appartenant à `ubuntu`, avec des dates de modification échelonnées d'aujourd'hui à il y a 9 jours.

## Énoncé

### Partie 1 — Squelette du script et validation des arguments

Créez le script `~/exploitation/scripts/nettoie-logs.sh` (créez le répertoire si besoin) qui :

1. commence par `#!/usr/bin/env bash` et `set -euo pipefail` ;
2. accepte deux arguments **optionnels** :
   - argument 1 : le répertoire à nettoyer (défaut : `/var/log/appdemo`) ;
   - argument 2 : l'âge maximal en jours des archives compressées (défaut : `7`) ;
3. vérifie que le répertoire existe : s'il n'existe pas, affiche un message d'erreur explicite sur la **sortie d'erreur** et sort avec le code retour `1` ;
4. affiche une ligne d'en-tête horodatée, par exemple : `[2026-07-02 14:00:00] Nettoyage de /var/log/appdemo (rétention 7 jours)`.

Rendez le script exécutable et testez les deux cas : répertoire existant (le script continue) et répertoire inexistant (message d'erreur + `echo $?` affiche `1`).

Résultat attendu : `./nettoie-logs.sh /repertoire/inexistant ; echo $?` affiche un message d'erreur puis `1` ; `./nettoie-logs.sh ; echo $?` affiche l'en-tête puis `0`.

### Partie 2 — Compression et suppression

Complétez le script :

1. **compression** : tous les fichiers `.log` du répertoire modifiés il y a **plus de 1 jour** sont compressés avec `gzip` (ils deviennent des `.log.gz`) ; les fichiers du jour restent intacts ;
2. **suppression** : tous les fichiers `.log.gz` plus vieux que N jours (l'argument 2) sont supprimés ;
3. **comptage** : le script affiche le nombre de fichiers compressés et le nombre de fichiers supprimés, par exemple :
   ```text
   Fichiers compressés : 6
   Archives supprimées : 3
   ```
4. le script se termine par un code retour `0` en cas de succès.

Testez sur `/var/log/appdemo`, puis relancez une deuxième fois : la deuxième exécution doit afficher `0` compressé / `0` supprimé (le script est **rejouable**, il ne doit pas planter quand il n'y a rien à faire — attention, c'est le piège de `set -e` combiné à `find | wc -l`).

Résultat attendu : après la première exécution, `ls /var/log/appdemo` montre le fichier du jour en `.log`, les fichiers de 2 à 7 jours en `.log.gz`, et plus aucun fichier de 8-9 jours. La deuxième exécution affiche 0 / 0 et sort avec le code `0`.

### Partie 3 — Planification avec cron

1. Ouvrez la crontab de l'utilisateur `ubuntu` avec `crontab -e` (choisissez nano si on vous demande un éditeur).
2. Ajoutez une ligne qui exécute le script **tous les jours à 04h00**, avec la sortie standard **et** la sortie d'erreur redirigées en ajout dans `/home/ubuntu/exploitation/rapports/nettoie-logs.journal` :
   - expression cron imposée : `0 4 * * *` ;
   - le fichier journal doit s'enrichir à chaque exécution (pas s'écraser).
3. Vérifiez la ligne enregistrée avec `crontab -l`.
4. Sans attendre 04h00 : exécutez à la main la commande exacte que cron lancera (copiez la partie commande de la ligne cron) et vérifiez que le journal se remplit avec `cat`.

Résultat attendu : `crontab -l` affiche la ligne `0 4 * * *` complète ; après exécution manuelle, `cat ~/exploitation/rapports/nettoie-logs.journal` contient au moins un en-tête horodaté et les deux lignes de comptage.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — Arguments avec valeur par défaut</summary>

La syntaxe `VARIABLE="${1:-valeur_par_defaut}"` affecte le premier argument s'il est fourni, sinon la valeur par défaut. Exemple : `REPERTOIRE="${1:-/var/log/appdemo}"` et `RETENTION="${2:-7}"`. C'est exactement le mécanisme vu dans `backup.sh` en démo 3-1.

</details>

<details>
<summary>Indice 2 — Sélectionner des fichiers par âge</summary>

`find "$REPERTOIRE" -maxdepth 1 -name "*.log" -mtime +0` liste les `.log` modifiés il y a plus de 24 h (`-mtime +0` = strictement plus de 1 jour). Pour agir sur chaque fichier : `-exec gzip {} \;`. Pour la suppression : `-name "*.log.gz" -mtime +"$RETENTION" -delete`. Astuce comptage : faites d'abord un `find … | wc -l` dans une variable, puis le `find … -exec`/`-delete`.

</details>

<details>
<summary>Indice 3 — set -e et un comptage qui vaut 0</summary>

`wc -l` renvoie 0 sans erreur, ce n'est pas lui le piège. Le piège classique est plutôt d'écrire `NB=$(find … | wc -l)` avec un chemin entre guillemets manquants ou un `grep` qui ne matche rien (code retour 1 → `set -e` arrête le script). Restez sur `find | wc -l`, quotez toutes les variables, et le script sera rejouable. Pour l'en-tête horodaté : `date '+%Y-%m-%d %H:%M:%S'`.

</details>

## Pour aller plus loin (bonus)

Remplacez la ligne cron par une paire d'unités systemd, comme pour `backup.sh` :

1. `/etc/systemd/system/nettoie-logs.service` : `Type=oneshot`, `ExecStart=/home/ubuntu/exploitation/scripts/nettoie-logs.sh` ;
2. `/etc/systemd/system/nettoie-logs.timer` : `OnCalendar=*-*-* 04:00:00`, `Persistent=true`, `WantedBy=timers.target` ;
3. `sudo systemctl daemon-reload`, activez le timer avec `enable --now`, vérifiez avec `systemctl list-timers` et déclenchez une exécution immédiate avec `sudo systemctl start nettoie-logs.service` ;
4. comparez : où lisez-vous la sortie du script maintenant ? (`journalctl -u nettoie-logs.service`) Quel avantage sur le fichier journal de cron ?

Pensez à retirer la ligne cron (`crontab -e`) pour ne pas nettoyer deux fois.
