---
marp: true
title: Admin Cloud — CL-PYTHON — Jour 2
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Données, fichiers et premiers outils

## Brancher Python sur le monde réel

CL-PYTHON — Jour 2 : collections, JSON/YAML/CSV, exceptions, argparse

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Organiser des données avec **listes, dictionnaires, tuples et sets**.
- Filtrer et transformer avec les **compréhensions** simples.
- **Lire et écrire des fichiers** proprement (`with open`).
- Manipuler les 3 formats du métier : **JSON, YAML, CSV** — dont un
  inventaire de serveurs.
- Rendre un script **robuste** avec les exceptions (`try/except`).
- Découper un projet en **modules** importables.
- Construire un **outil en ligne de commande** avec argparse.

Fil rouge du jour : d'un fichier d'inventaire brut à un outil de filtrage
que vous pourriez livrer à un collègue.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. Listes : des valeurs en ordre.
2. Dictionnaires : des valeurs nommées.
3. Tuples et sets, en deux mots.
4. Compréhensions : filtrer en une ligne.
5. Fichiers : lire et écrire.
6. JSON, YAML, CSV : les formats de l'admin.
7. Exceptions : les erreurs prévues.
8. Modules : ranger son code.
9. argparse : de script à outil.

</div>

---

<!-- _class: lead -->

# 1. Listes : des valeurs en ordre

---

<style scoped>
div{ font-size:15px }
</style>

## Créer, lire, modifier

<div>

```python
serveurs = ["web-01", "web-02", "db-01"]

serveurs[0]          # 'web-01'  — les indices commencent à 0 !
serveurs[-1]         # 'db-01'   — -1 : le dernier
len(serveurs)        # 3

serveurs.append("bastion")       # ajoute à la fin
serveurs.remove("web-02")        # retire par valeur
serveurs[0] = "web-01b"          # remplace par indice
```

- Une liste est **ordonnée** et **modifiable**.
- Accès hors bornes → `IndexError: list index out of range` :
  le message dit exactement ce qui se passe.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Trancher, trier, tester

<div>

```python
charges = [42.0, 91.5, 78.0, 12.5, 88.0]

charges[0:2]         # [42.0, 91.5]  — tranche : début inclus, fin exclue
charges[:3]          # les 3 premiers
charges[-2:]         # les 2 derniers

sorted(charges)              # nouvelle liste triée
sorted(charges, reverse=True)  # décroissant
max(charges), min(charges), sum(charges)   # 91.5, 12.5, 312.0

91.5 in charges      # True — test d'appartenance
```

`sorted()` **renvoie une copie** triée ; `charges.sort()` trie **sur place**.
Ce petit vocabulaire (`in`, `len`, `sum`, `max`, tranche) couvre l'essentiel
des manipulations d'inventaire.

</div>

---

<!-- _class: lead -->

# 2. Dictionnaires : des valeurs nommées

---

<style scoped>
div{ font-size:15px }
</style>

## Clé → valeur : LA structure du métier

<div>

```python
serveur = {
    "nom": "web-01",
    "ip": "10.0.1.10",
    "role": "web",
    "ram_go": 4,
}

serveur["ip"]              # '10.0.1.10' — accès par clé
serveur["ram_go"] = 8      # modification
serveur["env"] = "prod"    # ajout d'une nouvelle clé
```

- Chaque valeur porte une **étiquette** (la clé) au lieu d'un numéro.
- Clé absente → `KeyError: 'ipp'` — relisez l'orthographe de la clé.
- Toutes les données du cloud (API AWS, JSON, YAML) arrivent sous
  cette forme : **maîtriser le dictionnaire = maîtriser le cloud**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## get, parcours et imbrication

<div>

```python
serveur.get("env")             # None si absente — pas d'erreur
serveur.get("env", "inconnu")  # valeur par défaut

for cle, valeur in serveur.items():
    print(f"{cle} = {valeur}")
```

Le motif réel : **une liste de dictionnaires** (un par serveur) :

```python
parc = [
    {"nom": "web-01", "role": "web"},
    {"nom": "db-01", "role": "base-de-donnees"},
]
for serveur in parc:
    print(serveur["nom"], "→", serveur["role"])
```

C'est exactement la forme d'un inventaire — on la retrouve dans une heure.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le dictionnaire compteur

<div>

Compter les serveurs par rôle — motif à connaître par cœur :

```python
parc = [
    {"nom": "web-01", "role": "web"},
    {"nom": "web-02", "role": "web"},
    {"nom": "db-01", "role": "base-de-donnees"},
]

compteur = {}
for serveur in parc:
    role = serveur["role"]
    compteur[role] = compteur.get(role, 0) + 1

print(compteur)   # {'web': 2, 'base-de-donnees': 1}
```

`get(role, 0)` : « la valeur actuelle, ou 0 si ce rôle est nouveau ».
Même motif pour compter des erreurs dans un log, des types d'instances AWS…

</div>

---

<!-- _class: lead -->

# 3. Tuples et sets, en deux mots

---

<style scoped>
div{ font-size:15px }
</style>

## Tuple : figé — Set : sans doublon

<div>

```python
# Tuple : comme une liste, mais NON modifiable — parenthèses
mesure = ("web-01", 87.5)
nom, cpu = mesure              # déballage : deux variables d'un coup

# Set : collection SANS doublons ni ordre — accolades
ips = {"10.0.1.10", "10.0.1.11", "10.0.1.10"}
print(ips)                     # {'10.0.1.10', '10.0.1.11'} — doublon éliminé
```

Usages concrets :

- Tuple : un couple/triplet stable (hôte, port), retour multiple de fonction.
- Set : dédupliquer (`set(liste)`) et croiser :

```python
declares - vus      # dans l'inventaire mais jamais vus : machines fantômes ?
vus - declares      # vus mais non déclarés : machines pirates ?
```

</div>

---

<!-- _class: lead -->

# 4. Compréhensions : filtrer en une ligne

---

<style scoped>
div{ font-size:15px }
</style>

## De la boucle à la compréhension

<div>

Version boucle (parfaitement valable) :

```python
noms = []
for serveur in parc:
    if serveur["role"] == "web":
        noms.append(serveur["nom"])
```

Version compréhension — la même chose, en une ligne :

```python
noms = [s["nom"] for s in parc if s["role"] == "web"]
```

Lecture en français : « le nom de chaque serveur `s` du parc, **si** son
rôle est web ». Squelette : `[expression for element in collection if condition]`.

Restez simple : une compréhension illisible vaut moins qu'une boucle claire.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Compréhensions : les cas utiles

<div>

```python
# Transformer
majuscules = [nom.upper() for nom in noms]

# Filtrer
production = [s for s in parc if s["env"] == "production"]

# Filtrer PUIS agréger
ram_prod = sum(s["ram_go"] for s in parc if s["env"] == "production")

# Chaîner deux filtres ? Deux étapes lisibles :
web = [s for s in parc if s["role"] == "web"]
web_petits = [s for s in web if s["ram_go"] < 8]
```

La 3ᵉ forme (dans `sum()`, sans crochets) s'appelle expression génératrice —
retenez juste qu'elle **se lit pareil**.

</div>

---

<!-- _class: lead -->

# 5. Fichiers : lire et écrire

---

<style scoped>
div{ font-size:15px }
</style>

## Lire un fichier avec with

<div>

```python
with open("app.log", encoding="utf-8") as fichier:
    for ligne in fichier:
        print(ligne.strip())
```

- `with` ouvre le fichier et **garantit sa fermeture**, même si ça plante
  au milieu — toujours cette forme, jamais `open()` seul.
- `encoding="utf-8"` : explicite, pour que les accents survivent partout.
- Itérer ligne par ligne : le fichier n'est **jamais chargé en entier** —
  précieux pour un log de plusieurs Go.
- `ligne.strip()` retire le `\n` invisible en fin de ligne.

Tout lire d'un coup (petits fichiers) : `contenu = fichier.read()`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Écrire un fichier

<div>

```python
rapport = ["web-01 : OK", "db-01 : ALERTE"]

with open("rapport.txt", "w", encoding="utf-8") as fichier:
    for ligne in rapport:
        fichier.write(ligne + "\n")
```

Les **modes** d'ouverture :

| Mode | Effet |
|------|-------|
| `"r"` | lecture (défaut) |
| `"w"` | écriture — **écrase** le contenu existant ! |
| `"a"` | ajout à la fin (append) — pour les journaux |

⚠️ `"w"` sur un fichier précieux = fichier vidé sans sommation.
Relisez le mode avant d'exécuter — réflexe de survie.

</div>

---

<!-- _class: lead -->

# 6. JSON, YAML, CSV : les formats de l'admin

---

<style scoped>
div{ font-size:15px }
</style>

## Trois formats, une même structure

<div>

```text
      JSON  (API, cloud)      YAML (config, Ansible)     CSV (tableurs)
+------------------------+  +----------------------+  +--------------------+
| {                      |  | serveurs:            |  | nom,ip,role        |
|   "serveurs": [        |  |   - nom: web-01      |  | web-01,10.0.1.10,w |
|     {"nom": "web-01",  |  |     ip: 10.0.1.10    |  | db-01,10.0.2.10,db |
|      "ip": "10.0.1.10"}|  |   - nom: db-01       |  +--------------------+
|   ]                    |  |     ip: 10.0.2.10    |
| }                      |  +----------------------+
+------------------------+
```

Trois textes différents… mais une fois chargés en Python : **les mêmes
dictionnaires et listes**. Un seul savoir-faire pour trois formats.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## JSON : lire et écrire

<div>

```python
import json

# Lire : texte JSON → structures Python
with open("parc.json", encoding="utf-8") as fichier:
    donnees = json.load(fichier)
print(donnees["parc"][0]["nom"])

# Écrire : structures Python → texte JSON
with open("rapport.json", "w", encoding="utf-8") as fichier:
    json.dump(donnees, fichier, indent=2, ensure_ascii=False)
```

- `json.load` / `json.dump` : fichier ↔ Python (module **standard**, rien à installer).
- `indent=2` : lisible par un humain ; `ensure_ascii=False` : accents préservés.
- Correspondances : objet JSON ↔ `dict`, tableau ↔ `list`,
  `true/false/null` ↔ `True/False/None`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## YAML : le format des configs

<div>

```python
import yaml            # pip install pyyaml — votre venv sert enfin !

with open("serveurs.yaml", encoding="utf-8") as fichier:
    inventaire = yaml.safe_load(fichier)

for serveur in inventaire["serveurs"]:
    print(serveur["nom"], serveur["ip"])
```

- L'indentation structure le YAML (comme Python !), `-` introduit un
  élément de liste.
- **Toujours `safe_load`**, jamais `load` : `load` peut exécuter du code
  caché dans le fichier — réflexe sécurité dès aujourd'hui.
- YAML est LE format d'Ansible, Kubernetes, GitHub Actions : vous allez
  en manger pendant tout le cursus.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## CSV : les données en colonnes

<div>

```python
import csv

with open("serveurs.csv", encoding="utf-8") as fichier:
    lecteur = csv.DictReader(fichier)
    for ligne in lecteur:
        print(ligne["nom"], ligne["ram_go"])
```

- `DictReader` : la 1ʳᵉ ligne (en-têtes) devient les **clés** de chaque ligne
  → encore des dictionnaires !
- ⚠️ Tout arrive en **str** : `int(ligne["ram_go"])` avant de calculer.
- Usage : exports d'outils, rapports de facturation cloud, imports tableur.

Bilan des 3 formats : JSON pour **échanger**, YAML pour **configurer**,
CSV pour **tabuler**. Python les unifie.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 2.1 — Lire un inventaire de serveurs

<div>

**Du YAML au rapport JSON**, en direct :

1. Chargement de `serveurs.yaml` (5 serveurs) avec `yaml.safe_load`.
2. Parcours et affichage aligné.
3. Filtrage des serveurs de production (compréhension).
4. Calcul de la RAM totale, export `rapport_production.json`.
5. Transformation en outil CLI : `filtrer_inventaire.py --role web`.

📄 Fiche : `demos/02-cl-python/demo-2-1-inventaire-json-yaml.md`
💾 Code : `code/02-cl-python/demo-2-1/`

La partie 5 anticipe la fin de journée — gardez-la en tête.

</div>

---

<!-- _class: lead -->

# 7. Exceptions : les erreurs prévues

---

<style scoped>
div{ font-size:15px }
</style>

## Lire une traceback sans paniquer

<div>

```python
>>> int("abc")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: invalid literal for int() with base 10: 'abc'
```

Méthode de lecture — **toujours partir du bas** :

1. **Dernière ligne** : le type (`ValueError`) et l'explication.
2. Lignes au-dessus : le fichier et la ligne exacte du problème.

Les habitués du métier : `FileNotFoundError` (fichier absent), `KeyError`
(clé absente), `ValueError` (conversion impossible), `TypeError` (types
incompatibles), `IndexError` (indice hors liste).

Une traceback est un **diagnostic gratuit**, pas un échec.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## try / except : prévoir l'échec

<div>

```python
import sys

try:
    with open("parc.json", encoding="utf-8") as fichier:
        donnees = json.load(fichier)
except FileNotFoundError:
    print("Erreur : parc.json introuvable.", file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError as erreur:
    print(f"Erreur : JSON invalide : {erreur}", file=sys.stderr)
    sys.exit(1)
```

- `try` : le code qui **peut** échouer ; `except TypePrécis` : la réaction.
- `as erreur` récupère les détails pour le message.
- `sys.exit(1)` : sortie propre, code retour ≠ 0 → les autres outils
  (cron, CI) sauront que ça a échoué.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les règles du try/except propre

<div>

```python
# ❌ À bannir : attrape TOUT, cache les vrais bugs
try:
    traitement()
except:
    pass

# ✅ Ciblé, informatif, honnête
try:
    traitement()
except FileNotFoundError:
    journal.error("Fichier manquant : %s", chemin)
    sys.exit(1)
```

- Attraper **des exceptions précises**, jamais `except:` nu.
- Ne protéger **que les lignes à risque** (fichier, réseau, conversion) —
  pas tout le programme.
- Un except qui `pass` en silence = un bug qui se cache pour mieux revenir.

Philosophie : une erreur **prévue** est gérée ; une erreur **imprévue**
doit planter bruyamment pour être découverte.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2.1 — Parser un journal d'application

<div>

**À vous** (45 min) :

- Lire `app.log` (fourni dans l'énoncé) ligne par ligne.
- Compter INFO / WARNING / ERROR avec un **dictionnaire compteur**.
- Extraire l'heure et le message des lignes ERROR (`split(" ", 3)`).
- Blinder avec `try/except FileNotFoundError` — sortie propre exigée.

📄 Énoncé : `exercices/02-cl-python/exercice-2-1-parser-logs.md`

Bonus : exporter le tout en `rapport_logs.json` — la boucle complète
texte brut → données structurées.

</div>

---

<!-- _class: lead -->

# 8. Modules : ranger son code

---

<style scoped>
div{ font-size:15px }
</style>

## import : la bibliothèque et vos fichiers

<div>

Vous importez depuis ce matin (`json`, `yaml`, `csv`, `sys`)…
Vos **propres fichiers** s'importent pareil :

```python
# outils_parc.py — vos fonctions réutilisables
def filtrer_par_role(serveurs, role):
    return [s for s in serveurs if s["role"] == role]
```

```python
# rapport.py — les utilise
from outils_parc import filtrer_par_role

web = filtrer_par_role(parc, "web")
```

- Un fichier `.py` = un **module** ; son nom (sans `.py`) = le nom d'import.
- `import module` puis `module.fonction()`, ou `from module import fonction`.
- Objectif : les fonctions génériques d'un côté, le scénario de l'autre.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le garde `if __name__ == "__main__":`

<div>

```python
# outils_parc.py
def filtrer_par_role(serveurs, role):
    return [s for s in serveurs if s["role"] == role]

def main():
    print("Test rapide :", filtrer_par_role([{"role": "web"}], "web"))

if __name__ == "__main__":
    main()      # exécuté SEULEMENT en lancement direct
```

- `python3 outils_parc.py` → `main()` s'exécute.
- `from outils_parc import ...` depuis un autre fichier → `main()` **ne
  s'exécute pas** : on ne veut que les fonctions.

Mettez ce garde dans **tous** vos scripts dès aujourd'hui : c'est lui qui
rendra vos fonctions testables avec pytest au J4.

</div>

---

<!-- _class: lead -->

# 9. argparse : de script à outil

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi des arguments en ligne de commande ?

<div>

Comparez ces deux mondes :

```bash
# Le script rigide : il faut ÉDITER le code pour changer le fichier
python3 filtrer.py

# L'outil souple : le comportement se choisit à l'appel
python3 filtrer.py --fichier parc.json --role web --ram-max 8
```

Tous les outils que vous utiliserez fonctionnent ainsi :
`aws ec2 describe-instances --region eu-west-3`,
`kubectl get pods --namespace prod`…

**argparse** (module standard) donne cette interface à vos scripts —
aide `--help` générée comprise.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le squelette argparse

<div>

```python
import argparse

def main():
    parseur = argparse.ArgumentParser(
        description="Filtre un inventaire de serveurs."
    )
    parseur.add_argument("--fichier", default="parc.json",
                         help="fichier d'inventaire")
    parseur.add_argument("--role", help="ne garder que ce rôle")
    parseur.add_argument("--ram-max", type=int,
                         help="RAM strictement inférieure à N Go")
    arguments = parseur.parse_args()

    print(arguments.fichier, arguments.role, arguments.ram_max)

if __name__ == "__main__":
    main()
```

`--ram-max` devient `arguments.ram_max` (tiret → underscore) ;
sans `type=int`, tout arrive en `str`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Ce qu'argparse offre gratuitement

<div>

```bash
$ python3 filtrer.py --help
usage: filtrer.py [-h] [--fichier FICHIER] [--role ROLE] [--ram-max RAM_MAX]

Filtre un inventaire de serveurs.

options:
  -h, --help         show this help message and exit
  --fichier FICHIER  fichier d'inventaire
  ...

$ python3 filtrer.py --rol web
filtrer.py: error: unrecognized arguments: --rol web
```

- `--help` automatique : le mode d'emploi de votre outil.
- Erreur claire + code retour 2 sur option inconnue.
- Valeurs par défaut, conversion de types, options obligatoires…

Un script + argparse + gestion d'erreurs = **un outil livrable**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2.2 — Filtrer un inventaire (outil CLI)

<div>

**À vous** (60 min) — la synthèse de la journée :

- `charger_parc(chemin)` : lecture JSON blindée (fichier absent → exit 1).
- `filtrer(serveurs, role, environnement, ram_max)` : critères optionnels
  combinables (compréhensions).
- Interface argparse complète : `--fichier`, `--role`, `--environnement`,
  `--ram-max`, et un `--help` digne d'un outil pro.

```bash
python3 filtrer_parc.py --role web --environnement production --ram-max 8
```

📄 Énoncé : `exercices/02-cl-python/exercice-2-2-filtrer-inventaire.md`

Bonus : option `--sortie rapport.json` pour exporter au lieu d'afficher.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap — les points clés du jour

<div>

- **Liste** = ordre + indices (dès 0) ; **dictionnaire** = clé → valeur ;
  le réel = des **listes de dictionnaires**.
- Tuple : figé (déballage `nom, cpu = mesure`) ; set : sans doublons.
- Compréhension : `[s["nom"] for s in parc if s["role"] == "web"]` — un
  filtre lisible en une ligne.
- Fichiers : **toujours** `with open(..., encoding="utf-8")` ; mode `"w"`
  écrase !
- JSON (`json.load/dump`), YAML (`yaml.safe_load`), CSV (`DictReader`) →
  les mêmes structures Python.
- `try/except` **ciblé** + `sys.exit(1)` : un outil échoue proprement.
- `if __name__ == "__main__":` dans chaque script — importable ET exécutable.
- argparse : options, types, défauts, `--help` gratuit.

</div>

---

<!-- _class: lead -->

# Quiz de fin de journée

## 10 questions — répondez sur papier, correction ensemble

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 1 et 2

<div>

**Question 1** — Qu'affiche ce code ?

```python
serveurs = ["web-01", "web-02", "db-01"]
print(serveurs[1])
print(serveurs[-1])
print(len(serveurs))
```

**Question 2** — Quelle est la différence entre `serveur["env"]` et
`serveur.get("env")` quand la clé `env` n'existe pas dans le dictionnaire ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Réécrivez cette boucle en une compréhension de liste :

```python
resultat = []
for s in parc:
    if s["ram_go"] < 8:
        resultat.append(s["nom"])
```

**Question 4** — Que contient `ips` après ce code, et pourquoi ?

```python
ips = set(["10.0.1.10", "10.0.1.11", "10.0.1.10"])
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Ce code veut ajouter une ligne à un journal, mais un
collègue signale que le journal est vidé à chaque exécution. Corrigez :

```python
with open("suivi.log", "w", encoding="utf-8") as fichier:
    fichier.write("nouvelle entrée\n")
```

**Question 6** — Pourquoi doit-on utiliser `yaml.safe_load` plutôt que
`yaml.load` ? En une phrase.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Après lecture d'un CSV avec `csv.DictReader`, ce calcul
plante : `total += ligne["ram_go"]`. Pourquoi, et comment corriger ?

**Question 8** — Qu'a de dangereux ce fragment ?

```python
try:
    donnees = json.load(fichier)
except:
    pass
```

Citez deux problèmes distincts.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — À quoi sert `if __name__ == "__main__":` ?
Que se passe-t-il pour ce bloc quand le fichier est **importé** ?

**Question 10** — Avec cette déclaration argparse :

```python
parseur.add_argument("--ram-max", type=int, default=8)
```

a) Comment accède-t-on à la valeur dans le code ?
b) Que vaut-elle si l'utilisateur ne passe pas l'option ?
c) Que se passe-t-il s'il tape `--ram-max abc` ?

</div>

---

<!-- _class: lead -->

# À demain !

## Demain : Python parle au réseau

Un peu d'objets, puis **requests** pour interroger une API publique réelle…
et l'après-midi, retournement de situation : **c'est vous qui écrirez
l'API**, avec FastAPI. Le fil rouge StockLine se rapproche.
