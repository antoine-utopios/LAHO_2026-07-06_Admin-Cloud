# Exercice 2-1 — Un service qui ne démarre pas

> Module : 03 — CL-LINUX Linux pour l'admin cloud
> Durée estimée : 45 min
> Difficulté : 2 / 5
> Type : Exercice d'application (diagnostic)

## Objectifs pédagogiques

À la fin de cet exercice, vous serez capable de :

- Diagnostiquer un service systemd en échec avec `systemctl status` et `journalctl -u`
- Lire et corriger un fichier d'unité dans `/etc/systemd/system/`
- Appliquer le cycle correct : modifier → `daemon-reload` → redémarrer → vérifier
- Activer un service au démarrage avec `enable --now`

## Prérequis

- Avoir suivi la partie « Services systemd » du module 03 (jour 2) et assisté à la démo 2-1
- Environnement : VM `srv-linux` (Ubuntu Server 24.04 LTS sous Multipass) — connectez-vous avec `multipass shell srv-linux` depuis le poste hôte
- Outils : `systemctl`, `journalctl`, `nano`, `id`, `ls`

## Contexte

Voici la situation. Vous êtes d'astreinte ce matin. Un collègue, parti en congés hier soir, a installé un petit service maison appelé `horodatage`. Le rôle de ce service est simple : écrire la date et l'heure dans les journaux toutes les trente secondes. L'équipe s'en sert pour vérifier que la supervision remonte bien les logs, c'est un indicateur de bon fonctionnement.

Sauf que le service ne démarre pas.

Son dernier message avant de partir : « J'ai dû me planter quelque part, le service refuse de démarrer — tu peux regarder ? »

C'est exactement le quotidien d'un administrateur cloud. Vous arrivez sur une machine que vous n'avez pas configurée vous-même, un service est en panne, et vous devez comprendre pourquoi. La méthode est toujours la même : `systemctl status` pour savoir ce qui ne va pas, `journalctl -u` pour comprendre la cause, correction, vérification.

Vous avez quarante-cinq minutes. Le service `horodatage` cache deux erreurs distinctes. Trouvez-les, corrigez-les, et rendez le service opérationnel et persistant au démarrage.

## Mise en place (copier-coller tel quel)

Collez le bloc suivant **d'un seul tenant** dans la VM pour reproduire l'installation de votre collègue.

⚠️ **Règle du jeu** : ce bloc contient les erreurs que vous devez trouver. Pour que l'exercice ait un intérêt, **ne le lisez pas** — copiez-le, collez-le, et faites défiler le terminal. Le diagnostic doit venir des outils systemd, pas de la lecture de l'énoncé.

```bash
sudo mkdir -p /opt/horodatage
sudo tee /opt/horodatage/horodatage.sh > /dev/null <<'FIN'
#!/usr/bin/env bash
while true; do
  echo "Horodatage : $(date '+%Y-%m-%d %H:%M:%S')"
  sleep 30
done
FIN
sudo chmod 755 /opt/horodatage/horodatage.sh
sudo tee /etc/systemd/system/horodatage.service > /dev/null <<'FIN'
[Unit]
Description=Horodatage - journalise la date toutes les 30 secondes

[Service]
ExecStart=/usr/local/bin/horodatage.sh
User=horodata
Restart=on-failure

[Install]
WantedBy=multi-user.target
FIN
sudo systemctl daemon-reload
sudo systemctl start horodatage.service
```

La dernière commande doit afficher une erreur. C'est normal : c'est la panne que vous allez diagnostiquer.

## Énoncé

### Partie 1 — Constater et qualifier la panne

Avant de corriger quoi que ce soit, il faut d'abord comprendre ce qui se passe. La première chose à faire face à un service qui refuse de démarrer, c'est de consulter son état. Pas de devinette, pas d'hypothèse au hasard : on lit ce que le système nous dit.

1. Affichez l'état du service `horodatage`. Relevez son état (`active` / `failed` / autre) et le code d'erreur affiché.
2. Consultez les journaux de ce service uniquement depuis le dernier démarrage de la machine. Notez les lignes d'erreur exactes. C'est dans les journaux que se trouve l'explication détaillée : le code d'erreur vous dit qu'il y a un problème, le journal vous dit lequel.
3. À partir de ces informations, formulez une hypothèse : qu'est-ce qui empêche le démarrage ?

Résultat attendu : vous savez citer l'état exact du service et au moins un code d'erreur systemd (`status=2xx/...`) tiré de `systemctl status` ou de `journalctl -u horodatage`.

### Partie 2 — Vérifier l'hypothèse sur le terrain

Un bon diagnostic ne s'arrête pas à la lecture des messages d'erreur. Il se vérifie sur le terrain. Les outils systemd vous ont dit ce qui n'allait pas : maintenant, allez constater par vous-même que le problème est bien réel.

1. Ouvrez le fichier d'unité `/etc/systemd/system/horodatage.service` en lecture. Regardez chaque directive de la section `[Service]` et confrontez-la à la réalité du système :
   - Le programme pointé par `ExecStart` existe-t-il ? (`ls -l` sur le chemin)
   - L'utilisateur déclaré par `User=` existe-t-il ? (`id <nom>`)
2. L'indice de l'équipe : les applications maison sont installées sous `/opt`. Le script a bien été livré quelque part. Retrouvez-le.

Résultat attendu : vous avez identifié **deux** anomalies précises dans l'unité, preuves à l'appui (sortie de `ls -l` et de `id`).

### Partie 3 — Corriger, recharger, vérifier

Maintenant que vous savez exactement ce qui ne va pas, vous pouvez corriger. L'ordre des opérations est important : on corrige d'abord le fichier, on prévient systemd du changement, on redémarre, et on vérifie.

1. Corrigez le fichier d'unité pour qu'il pointe vers le script réellement installé. Pour l'utilisateur, deux choix sont possibles : créer l'utilisateur système manquant, ou supprimer la directive `User=` pour faire tourner le service sans utilisateur dédié. Choisissez et assumez votre choix (vous le justifierez au débriefing).
2. Faites prendre en compte la modification par systemd, puis démarrez le service.
3. Vérifiez qu'il est `active (running)` et que la date tombe bien dans les journaux. Suivez les logs en direct pendant environ une minute : vous devez voir au moins deux lignes `Horodatage : ...` espacées de trente secondes.
4. Faites en sorte que le service **survive à un redémarrage** de la VM. Prouvez-le : `sudo reboot`, reconnectez-vous, vérifiez l'état.

Résultat attendu :

```bash
systemctl is-active horodatage && systemctl is-enabled horodatage
```

```text
active
enabled
```

et `journalctl -u horodatage -n 4 --no-pager` montre des lignes `Horodatage : 2026-07-07 ...` régulières, y compris après le reboot.

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — les deux commandes du diagnostic</summary>

`systemctl status horodatage` donne l'état, la dernière erreur et les dernières lignes de journal. `journalctl -u horodatage -b --no-pager` donne tout l'historique du service depuis le boot. Les codes parlants : `217/USER` = utilisateur introuvable, `203/EXEC` = exécutable introuvable.

</details>

<details>
<summary>Indice 2 — il peut y avoir plusieurs pannes</summary>

systemd s'arrête à la **première** erreur rencontrée. Corriger une anomalie puis voir le service échouer différemment n'est pas un échec : c'est un progrès. Refaites le cycle status → journalctl après chaque correction.

</details>

<details>
<summary>Indice 3 — modification non prise en compte ?</summary>

Après toute modification d'un fichier `.service`, systemd travaille sur sa copie en mémoire tant que vous n'avez pas lancé `sudo systemctl daemon-reload`. Ensuite seulement : `sudo systemctl restart horodatage`.

</details>

## Pour aller plus loin (bonus)

1. Provoquez une panne en direct : tuez le processus du service (`systemctl status horodatage` vous donne son PID, puis `sudo kill <PID>`). Observez avec `systemctl status` ce que fait systemd dans les secondes qui suivent. Quelle directive de l'unité est responsable de ce comportement ?
2. Le service redémarre-t-il aussi si vous l'arrêtez proprement avec `sudo systemctl stop horodatage` ? Testez, puis expliquez la différence.
