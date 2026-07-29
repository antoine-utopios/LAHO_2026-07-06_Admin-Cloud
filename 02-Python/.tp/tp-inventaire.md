# TP 02 — Script d'inventaire de machines (mini-projet guidé)

> Module : 02 — CL-PYTHON — Python fondamentaux Cloud/DevOps (Jour 4)
> Durée estimée : 2 h 30
> Difficulté : 3 / 5
> Type : Travaux pratiques guidés (non noté)

## Mise en situation

Votre équipe gère un parc de machines décrit dans un fichier YAML. Chaque
matin, quelqu'un vérifie « à la main » que les machines répondent. Votre
mission : automatiser ce contrôle avec un script Python qui lit l'inventaire,
ping chaque hôte, écrit un rapport JSON exploitable par d'autres outils et
laisse une trace dans un journal. Ce script assemble **tout** ce que vous
avez appris depuis le jour 1 — et il resservira tel quel au CL-TP1.

## Objectifs

- Combiner YAML, subprocess, logging, argparse et JSON dans un script complet
- Structurer un script en fonctions testables
- Gérer proprement les erreurs (fichier absent, hôte injoignable, YAML invalide)

## Prérequis techniques

### Logiciels à installer

- Python version 3.12
- pyyaml version 6.x (`pip install pyyaml`) dans un venv
- pytest version 8.x (pour l'étape 5)

### Vérification de l'environnement

```bash
python3 --version
python3 -c "import yaml; print('pyyaml OK')"
ping -c 1 127.0.0.1   # Windows : ping -n 1 127.0.0.1
```

## Architecture cible

```text
   hotes.yaml                    inventaire.py                     sorties
+---------------+        +--------------------------+       +----------------+
| hotes:        |        | 1. charger_hotes()       |       | rapport.json   |
|  - nom: ...   | -----> | 2. ping() par hôte       | ----> | (pour les      |
|    adresse:.. |        | 3. controler_hotes()     |       |  machines)     |
|    role: ...  |        | 4. ecrire_rapport()      |       +----------------+
+---------------+        |    + logging partout     |       | inventaire.log |
                         +--------------------------+       | (pour les      |
                              options argparse               |  humains)      |
                       --fichier --rapport --timeout         +----------------+
```

## Étapes

### Étape 1 — L'inventaire et le squelette (20 min)

Objectif : un script qui charge le YAML et affiche les hôtes.

1. Créez un dossier de travail avec un venv activé, puis le fichier
   `hotes.yaml` :
   ```yaml
   hotes:
     - nom: boucle-locale
       adresse: 127.0.0.1
       role: test
     - nom: localhost
       adresse: localhost
       role: test
     - nom: hote-injoignable
       adresse: 192.0.2.1
       role: test
   ```
   (192.0.2.1 est une adresse réservée à la documentation : elle ne répond
   jamais — c'est votre cas d'échec garanti.)

2. Créez `inventaire.py` avec une fonction `charger_hotes(chemin)` qui
   renvoie la liste des hôtes, et un `main()` qui l'appelle et affiche
   chaque nom. Gérez `FileNotFoundError` et l'absence de clé `hotes`
   (message clair + `sys.exit(1)`).

Point de contrôle : `python3 inventaire.py` affiche les 3 noms ;
renommez `hotes.yaml` en `hotes.yaml.bak`, relancez : message d'erreur
propre, pas de traceback. Remettez le fichier en place.

### Étape 2 — Le ping (30 min)

Objectif : une fonction `ping(adresse, timeout_s=1)` qui renvoie un booléen.

1. Utilisez `subprocess.run` avec la commande
   `["ping", "-c", "1", adresse]` (`-n` sous Windows — testez
   `platform.system()`), `capture_output=True` et un
   `timeout=timeout_s + 1`.
2. Renvoie `True` si `returncode == 0`. Attrapez
   `subprocess.TimeoutExpired` → `False`.
3. Testez dans le REPL : `ping("127.0.0.1")` → `True`,
   `ping("192.0.2.1")` → `False` (après ~1-2 s).

Point de contrôle : les deux appels du REPL renvoient les bons booléens.

### Étape 3 — Le contrôle complet et le rapport JSON (40 min)

Objectif : parcourir les hôtes, collecter les résultats, écrire le rapport.

1. `controler_hotes(hotes, timeout_s)` : pour chaque hôte, appelle `ping` et
   construit un dictionnaire `{nom, adresse, role, joignable}` ; un hôte
   sans champ `adresse` est ignoré avec un avertissement.
2. `ecrire_rapport(resultats, chemin)` : écrit un JSON contenant
   `genere_le` (horodatage UTC ISO — `datetime.now(timezone.utc).isoformat()`),
   `total`, `joignables`, `injoignables` et la liste `hotes`.
3. Branchez le tout dans `main()`.

Point de contrôle : `cat rapport.json` montre 3 hôtes, 2 joignables,
1 injoignable, et un horodatage du jour.

### Étape 4 — logging + argparse (40 min)

Objectif : en faire un outil d'exploitation présentable.

1. Remplacez tous les `print` par logging (console **et** fichier
   `inventaire.log`) : `INFO` pour un hôte joignable, `WARNING` pour un
   injoignable, `ERROR` pour les problèmes de fichier.
2. Ajoutez argparse : `--fichier` (défaut `hotes.yaml`), `--rapport`
   (défaut `rapport.json`), `--log` (défaut `inventaire.log`),
   `--timeout` (int, défaut 1).
3. Terminez `main()` par un code retour : `sys.exit(2)` si au moins un hôte
   est injoignable (les outils de supervision lisent ce code).

Point de contrôle : `python3 inventaire.py --timeout 2 ; echo $?` affiche
le déroulé, puis `2`. `--help` documente les 4 options.

### Étape 5 — Quelques tests pytest (20 min)

Objectif : verrouiller les fonctions pures.

Créez `test_inventaire.py` avec au minimum :

- `test_ping_localhost_repond` : `ping("127.0.0.1") is True` ;
- `test_ping_adresse_documentation_ne_repond_pas` : `ping("192.0.2.1") is False` ;
- `test_ecrire_rapport` : avec une liste de résultats fabriquée à la main et
  le dossier temporaire `tmp_path` fourni par pytest, vérifiez `total`,
  `joignables`, `injoignables` dans le JSON écrit.

Point de contrôle : `pytest -v` — tous les tests verts.

## Livrable attendu

Un dossier contenant `hotes.yaml`, `inventaire.py`, `test_inventaire.py`,
et les sorties générées (`rapport.json`, `inventaire.log`). Le script doit
fonctionner sur l'inventaire d'un voisin sans modification.

## Dépannage courant

<details>
<summary>Erreur : ModuleNotFoundError: No module named 'yaml'</summary>

Cause : le venv n'est pas activé, ou pyyaml installé dans un autre venv.
Solution : `source .venv/bin/activate` puis `pip install pyyaml` ;
vérifiez avec `which python3`.

</details>

<details>
<summary>Erreur : le ping vers 192.0.2.1 est très long</summary>

Cause : selon l'OS, `ping` attend plusieurs secondes avant d'abandonner.
Solution : c'est le rôle du `timeout=` de `subprocess.run` — vérifiez qu'il
est bien passé, et que vous attrapez `subprocess.TimeoutExpired`.

</details>

<details>
<summary>Erreur : UnicodeDecodeError ou accents cassés dans le rapport</summary>

Cause : encodage non précisé à l'ouverture des fichiers.
Solution : toujours `open(chemin, encoding="utf-8")` et
`json.dump(..., ensure_ascii=False)`.

</details>

## Pour aller plus loin

- Ajoutez `--format texte|json` pour afficher aussi un tableau lisible en console.
- Ajoutez le champ `duree_ms` du ping dans chaque résultat.
- Comparez avec le corrigé `code/02-cl-python/inventaire/inventaire.py`, puis
  passez à l'assemblage de StockLine (`code/stockline/`) : même logique,
  appliquée à une API.
