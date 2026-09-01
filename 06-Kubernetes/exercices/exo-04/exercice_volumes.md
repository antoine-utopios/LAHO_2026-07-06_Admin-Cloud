# Exercice Kubernetes #4 - Stockage de fichiers

Déployer une API qui écrit des logs dans un fichier, observer le comportement sans volume, puis introduire un volume `emptyDir` / `hostPath`

Les fichiers `app.py` et `Dockerfile` sont fournis dans le dossier de l'exercice.

L'API expose trois routes :

| Méthode | Route | Description |
|---------|-------|-------------|
| `POST` | `/log` | Écrit un message dans `/app/logs/events.log` |
| `GET` | `/log` | Retourne le contenu du fichier sous forme de tableau JSON |
| `POST` | `/crash` | Arrête le processus (simule un crash applicatif) |

* Créer un cluster KinD dédié.
* Construire l'image Docker et chargé l'image dans le cluster.
* Déployer l'API **sans volume** et observé le comportement des données après un crash.
* Déployer l'API **avec un volume `emptyDir`** monté sur `/app/logs` et observer la différence.
* Déployer l'API **avec un volume `hostPath`** monté sur `/app/logs` et observer la différence.