---
marp: true
title: Admin Cloud — CL-PYTHON — Jour 4
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Python d'exploitation et StockLine v1

## Le jour où tout s'assemble

CL-PYTHON — Jour 4 : subprocess, logging, pytest, mini-projet, fil rouge

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Lancer des **commandes système** depuis Python (`subprocess`).
- Manipuler **chemins et fichiers** avec `pathlib`, lire l'environnement
  avec `os.environ`, dater avec `datetime`.
- **Journaliser** proprement avec `logging` (console + fichier, niveaux).
- Écrire vos premiers **tests pytest**.
- Réaliser le **mini-projet** : script d'inventaire complet
  (YAML → ping → rapport JSON + journal).
- Assembler et lancer **StockLine v1** : l'API fil rouge du cursus
  (FastAPI + SQLite/PostgreSQL + front statique).

Aujourd'hui, on ne découvre presque plus : on **assemble**.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. subprocess : Python pilote la machine.
2. pathlib, os.environ, datetime : la boîte à outils.
3. logging : des traces professionnelles.
4. pytest : la confiance automatisée.
5. 🧪 Mini-projet : le script d'inventaire.
6. StockLine v1 : assemblage du fil rouge.

Matin : outils + mini-projet. Après-midi : StockLine.

</div>

---

<!-- _class: lead -->

# 1. subprocess : Python pilote la machine

---

<style scoped>
div{ font-size:15px }
</style>

## Lancer une commande, récupérer sa sortie

<div>

```python
import subprocess

resultat = subprocess.run(
    ["df", "-h", "/"],        # la commande, UN argument par case
    capture_output=True,      # capturer stdout/stderr
    text=True,                # en str, pas en octets
)

print(resultat.returncode)    # 0 = succès
print(resultat.stdout)        # la sortie de la commande
```

- La commande est une **liste** : `["ping", "-c", "1", hote]` — jamais une
  grande chaîne (lisibilité + sécurité : pas d'injection shell).
- `returncode` : le code retour — 0 succès, autre = échec. Les mêmes codes
  que vos scripts renvoient avec `sys.exit()` : la boucle est bouclée.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Gérer l'échec et l'attente

<div>

```python
try:
    resultat = subprocess.run(
        ["ping", "-c", "1", "192.0.2.1"],
        capture_output=True, text=True,
        timeout=2,            # ne JAMAIS attendre indéfiniment
        check=True,           # returncode != 0 → exception
    )
except subprocess.TimeoutExpired:
    print("Trop long : hôte considéré injoignable.")
except subprocess.CalledProcessError as erreur:
    print(f"Échec (code {erreur.returncode})")
```

- `timeout=` : le réflexe déjà pris avec requests — même logique.
- `check=True` quand l'échec est **anormal** (df qui plante).
- Pas de `check` quand l'échec est une **information** (ping KO = hôte
  down, c'est le résultat qu'on cherche !).

</div>

---

<!-- _class: lead -->

# 2. pathlib, os.environ, datetime

---

<style scoped>
div{ font-size:15px }
</style>

## pathlib : les chemins sans casse-tête

<div>

```python
from pathlib import Path

repertoire = Path("/var/log")
fichier = repertoire / "app.log"      # le / assemble — Windows et Linux !

fichier.exists()            # le fichier existe ?
fichier.is_file()           # c'est bien un fichier ?
fichier.stat().st_size      # taille en octets
fichier.name                # 'app.log'
fichier.suffix              # '.log'

for log in repertoire.glob("*.log"):   # tous les .log du dossier
    print(log.name)
```

- Fini les chemins concaténés à la main (`"/var" + "/" + "log"`) : `Path`
  gère les séparateurs de chaque OS.
- `glob("*.log")` : filtrer par motif — l'équivalent du `ls *.log`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## os.environ : configurer sans toucher au code

<div>

```python
import os

# Lire une variable d'environnement, avec valeur par défaut
cible = os.environ.get("REPERTOIRE_CIBLE", "/var/log")
url_bdd = os.environ.get("DATABASE_URL", "sqlite:///./stockline.db")
```

```bash
# Le MÊME script, deux comportements :
python3 audit.py
REPERTOIRE_CIBLE=/tmp python3 audit.py
```

- Le code ne change pas, la **configuration** change : dev, test, prod.
- C'est LE mécanisme de configuration du cloud : variables d'une VM, d'un
  conteneur Docker, d'une Lambda… et de **StockLine cet après-midi**.
- Jamais de secret en dur dans le code : mot de passe → variable
  d'environnement (ou gestionnaire de secrets, bloc CL-SECU).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## datetime : horodater

<div>

```python
from datetime import datetime, timezone

maintenant = datetime.now(timezone.utc)
print(maintenant.isoformat())     # 2026-01-15T09:42:03.120+00:00

# Âge d'un fichier (avec pathlib)
modif = datetime.fromtimestamp(fichier.stat().st_mtime)
age = datetime.now() - modif      # un timedelta
print(age.days)                   # en jours entiers
```

- Format **ISO 8601** (`isoformat()`) pour les rapports : triable,
  universel, compris par tous les outils.
- Les serveurs travaillent en **UTC** : pas de surprise au changement
  d'heure, pas d'ambiguïté entre régions cloud.
- Soustraire deux datetime → `timedelta` (`.days`, `.total_seconds()`).

</div>

---

<!-- _class: lead -->

# 3. logging : des traces professionnelles

---

<style scoped>
div{ font-size:15px }
</style>

## print ne suffit plus

<div>

Votre script tournera **sans vous** : la nuit en cron, sur un serveur,
dans un conteneur. Quand ça casse à 3 h du matin, il faut des traces :

| | `print` | `logging` |
|---|---------|-----------|
| Horodatage | ❌ à la main | ✅ automatique |
| Gravité | ❌ indifférenciée | ✅ INFO/WARNING/ERROR… |
| Destination | terminal seul | console **et** fichier |
| Filtrable | ❌ | ✅ par niveau |

Niveaux, du plus bavard au plus grave :
`DEBUG` < `INFO` < `WARNING` < `ERROR` < `CRITICAL`

Règle simple : `INFO` raconte le déroulé, `WARNING` signale l'anormal
non bloquant, `ERROR` un échec.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Mise en place en 6 lignes

<div>

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(message)s",
    handlers=[
        logging.StreamHandler(),              # console
        logging.FileHandler("script.log"),    # + fichier
    ],
)
journal = logging.getLogger("inventaire")

journal.info("Début du contrôle : %d hôtes", 3)
journal.warning("%s : INJOIGNABLE", "db-01")
journal.error("Fichier de configuration manquant")
```

```text
2026-01-15 09:42:03,120 INFO     Début du contrôle : 3 hôtes
2026-01-15 09:42:05,417 WARNING  db-01 : INJOIGNABLE
```

Le fichier `.log` **s'enrichit** à chaque exécution : l'historique survit.

</div>

---

<!-- _class: lead -->

# 4. pytest : la confiance automatisée

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi tester, et comment

<div>

Un script d'exploitation **modifié sans test** = une roulette russe en
production. Un test = une vérification **rejouable en une commande**.

```python
# test_outils.py           pip install pytest
from outils import etat_cpu

def test_cpu_normal():
    assert etat_cpu(42) == "OK"

def test_cpu_critique():
    assert etat_cpu(95) == "CRITIQUE"

def test_borne_exacte():
    assert etat_cpu(90) == "CRITIQUE"    # les bornes : nids à bugs
```

- Un test = une fonction `test_...` avec des `assert`.
- pytest **découvre** tout seul les fichiers `test_*.py`.
- Tester : le cas normal, les **bornes**, le cas d'erreur.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Lancer, lire, tester les erreurs

<div>

```bash
$ pytest -v
test_outils.py::test_cpu_normal PASSED                    [ 33%]
test_outils.py::test_cpu_critique PASSED                  [ 66%]
test_outils.py::test_borne_exacte FAILED                  [100%]
=================== 1 failed, 2 passed in 0.04s ===================
```

Un `FAILED` montre la ligne et les valeurs comparées : réparer, relancer.

Tester qu'une **exception** est bien levée :

```python
import pytest

def test_taille_negative():
    with pytest.raises(ValueError):
        convertir_taille(-1)
```

Au bloc CL-IAC, un pipeline **refusera de déployer** si pytest est rouge :
les tests que vous écrivez aujourd'hui sont le langage de la CI de demain.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 4.1 — Script d'exploitation complet

<div>

**Les quatre outils réunis**, en direct :

1. `subprocess.run(["df", "-h", "/"])` : l'espace disque capturé.
2. `pathlib` : les gros fichiers d'un répertoire (`iterdir`, `stat`).
3. `os.environ.get("REPERTOIRE_CIBLE", ".")` : configuration externe.
4. `logging` : console + `exploitation.log`, niveaux INFO/WARNING/ERROR.

📄 Fiche : `demos/02-cl-python/demo-4-1-script-exploitation.md`
💾 Code : `code/02-cl-python/demo-4-1/exploitation.py`

**✏️ Puis à vous, en deux temps :**
Exercice 4.1 — audit d'un répertoire de logs (45 min)
Exercice 4.2 — premiers tests pytest (40 min)
📄 `exercices/02-cl-python/exercice-4-1-audit-repertoire.md` et `-4-2-tests-pytest.md`

</div>

---

<!-- _class: lead -->

# 5. 🧪 Mini-projet : le script d'inventaire

---

<style scoped>
div{ font-size:15px }
</style>

## 🧪 Le cahier des charges

<div>

**Automatiser le contrôle matinal du parc** (2 h 30, TP guidé non noté) :

```text
   hotes.yaml                  inventaire.py                    sorties
+---------------+      +--------------------------+      +----------------+
| hotes:        |      | charger_hotes()   (YAML) |      | rapport.json   |
|  - nom: ...   | ---> | ping()       (subprocess)| ---> | inventaire.log |
|    adresse:.. |      | controler_hotes()        |      | code retour 0/2|
+---------------+      | ecrire_rapport()  (JSON) |      +----------------+
                       |  + logging + argparse    |
                       +--------------------------+
```

- 5 étapes guidées, un **point de contrôle** à chaque étape.
- Étape 5 : quelques tests pytest sur les fonctions.
- Tout ce que vous avez appris depuis lundi, dans **un** livrable.

📄 Sujet : `tp/02-cl-python/tp-inventaire.md`
💾 Corrigé de référence : `code/02-cl-python/inventaire/`

</div>

---

<!-- _class: lead -->

# 6. StockLine v1 : assemblage du fil rouge

---

<style scoped>
div{ font-size:15px }
</style>

## StockLine : pourquoi cette application ?

<div>

**StockLine** : une API de gestion d'inventaire (produits, stocks,
mouvements) — l'application que vous allez déployer **pendant 15 semaines** :

| Étape du cursus | StockLine devient… |
|-----------------|--------------------|
| CL-TP1 | service systemd + nginx sur VM Linux |
| CL-TP2 | architecture 3-tiers AWS (ALB + EC2 + RDS) |
| CL-TP3 | serverless (Lambda / App Service) |
| CL-TP4 | provisionnée Terraform, configurée Ansible |
| CL-TP5 | conteneurisée sur Kubernetes (EKS) |
| CL-SECU | auditée et durcie |

Un admin déploie du code écrit par d'autres… sauf aujourd'hui :
**celui-là, vous l'aurez construit.** Plus jamais une boîte noire.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## L'architecture de la v1

<div>

```text
+-----------------+      HTTP (fetch)       +--------------------+
| front/          | ----------------------> | app/main.py        |
| index.html      |                         | FastAPI : routes   |
| (page statique) | <---------------------- |   + CORS           |
+-----------------+         JSON            +---------+----------+
                                                      |
                                   app/models.py (pydantic : validation)
                                                      |
                                            app/db.py (SQLAlchemy)
                                                      |
                                     +----------------v----------------+
                                     | SQLite (défaut, zéro config)    |
                                     | ou PostgreSQL si DATABASE_URL   |
                                     +---------------------------------+
```

Trois couches, trois fichiers : **routes** (main), **validation** (models),
**persistance** (db). Chaque brique = une notion de la semaine.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les endpoints de référence

<div>

| Méthode | Route | Rôle | Codes |
|---------|-------|------|-------|
| GET | `/sante` | health check API + base | 200 |
| GET | `/produits` | lister les produits | 200 |
| POST | `/produits` | créer (référence unique) | 201, 409, 422 |
| GET | `/produits/{id}` | détail | 200, 404 |
| GET | `/mouvements` | lister entrées/sorties | 200 |
| POST | `/mouvements` | entrée ou sortie de stock | 201, 400, 404 |
| GET | `/stocks/{produit_id}` | stock courant + alerte | 200, 404 |

- Le stock n'est **pas stocké** : il est **calculé** = Σ entrées − Σ sorties.
- Une sortie > stock courant → **400** refusé : règle métier.
- `/sante` : la route que **tous** vos outils de supervision appelleront
  (ALB, Kubernetes, CloudWatch…). Retenez-la.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## db.py : SQLite aujourd'hui, PostgreSQL demain

<div>

```python
# app/db.py (extrait)
import os
from sqlalchemy import create_engine

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./stockline.db")
engine = create_engine(DATABASE_URL, ...)
```

- **Aucune variable définie** → SQLite : un simple fichier `stockline.db`,
  zéro installation. C'est le mode d'aujourd'hui.
- `DATABASE_URL=postgresql+psycopg2://...` → PostgreSQL, **sans changer
  une ligne de code**. C'est le mode des TP à venir (RDS au CL-TP2 !).
- SQLAlchemy parle aux deux : il traduit nos objets Python en SQL.

Le motif `os.getenv(..., défaut)` vu ce matin porte ici toute la
stratégie de déploiement du cursus.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## models.py et main.py : du déjà-vu

<div>

```python
# app/models.py (extrait) — pydantic, comme hier
class ProduitCreate(BaseModel):
    reference: str = Field(min_length=1, max_length=50)
    nom: str = Field(min_length=1, max_length=200)
    prix_unitaire: float = Field(gt=0)
    seuil_alerte: int = Field(default=5, ge=0)
```

```python
# app/main.py (extrait) — FastAPI, comme hier
@app.post("/produits", response_model=models.Produit, status_code=201)
def creer_produit(produit: models.ProduitCreate,
                  session: Session = Depends(get_session)):
    ...
```

Seule vraie nouveauté : `Depends(get_session)` — FastAPI fournit une
session de base à chaque requête et la referme après. Retenez l'idée,
pas le détail : on **lit** ce code ensemble, fichier par fichier.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Lancer StockLine en local

<div>

```bash
cd code/stockline

python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

uvicorn app.main:app --reload
# → http://127.0.0.1:8000/docs
```

Premiers pas (dans un second terminal) :

```bash
curl http://127.0.0.1:8000/sante
# {"statut":"ok","base_de_donnees":"ok","version":"1.0.0"}

curl -X POST http://127.0.0.1:8000/produits \
  -H "Content-Type: application/json" \
  -d '{"reference": "SSD-500", "nom": "Disque SSD 500 Go",
       "prix_unitaire": 59.90, "seuil_alerte": 5}'
```

📄 Tout le déroulé : `code/stockline/README.md`

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Scénario de test : la vie d'un stock

<div>

```bash
# +20 unités en stock
curl -X POST http://127.0.0.1:8000/mouvements \
  -H "Content-Type: application/json" \
  -d '{"produit_id": 1, "type": "entree", "quantite": 20}'

# -17 unités
curl -X POST http://127.0.0.1:8000/mouvements \
  -H "Content-Type: application/json" \
  -d '{"produit_id": 1, "type": "sortie", "quantite": 17}'

# Le stock courant ?
curl http://127.0.0.1:8000/stocks/1
# {"quantite": 3, "seuil_alerte": 5, "alerte": true, ...}

# Sortir 10 de plus ? Refusé :
# {"detail": "Stock insuffisant ... 3 en stock, sortie demandée de 10."}
```

3 < seuil de 5 → `alerte: true` : la donnée qu'un système de supervision
exploitera. Chaque code HTTP rencontré cette semaine joue son rôle.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le front et les tests

<div>

**Le front statique** (second terminal) :

```bash
cd front && python3 -m http.server 8080
# → http://127.0.0.1:8080 : la liste des produits via fetch
```

Une page HTML + 30 lignes de JavaScript qui appellent `GET /produits` —
minimal exprès : ce cursus déploie, il ne fait pas de front-end.

**Les tests pytest** (8 tests fournis) :

```bash
pytest tests/ -v
# 8 passed — santé, produits, doublons 409, mouvements,
#            stock insuffisant 400, 404, validation 422
```

Ces tests sont votre **filet de sécurité** pour 15 semaines : après chaque
redéploiement de StockLine, `pytest` + `curl /sante` = certitude.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap — les points clés du jour (et du bloc)

<div>

- `subprocess.run([...], capture_output=True, text=True, timeout=...)` :
  Python pilote le système ; le code retour est un langage.
- `pathlib.Path` pour les chemins, `os.environ.get` pour la config,
  `datetime` UTC/ISO pour les horodatages.
- `logging` : niveaux + console + fichier — vos scripts parlent en votre
  absence.
- pytest : `test_*.py`, `assert`, bornes et exceptions — le filet.
- Mini-projet : YAML + subprocess + logging + argparse + JSON + pytest =
  l'anatomie de **tout** script d'exploitation.
- **StockLine v1 vit** : FastAPI + pydantic + SQLAlchemy, SQLite sans
  config, PostgreSQL par simple variable `DATABASE_URL`.

</div>

---

<!-- _class: lead -->

# Quiz de fin de bloc

## 10 questions — répondez sur papier, correction ensemble

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 1 et 2

<div>

**Question 1** — Pourquoi écrit-on
`subprocess.run(["ping", "-c", "1", hote])` avec une **liste**, plutôt
que `subprocess.run("ping -c 1 " + hote, shell=True)` ?
Donnez deux raisons.

**Question 2** — Dans notre script d'inventaire, l'appel `ping` n'utilise
**pas** `check=True`, alors que l'appel `df` de la démo l'utilisait.
Pourquoi cette différence ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Que renvoie chacune de ces expressions pathlib ?

```python
p = Path("/var/log") / "app.log"
p.name
p.suffix
list(Path("/var/log").glob("*.log"))
```

**Question 4** — Écrivez la ligne Python qui lit la variable
d'environnement `DATABASE_URL` en retombant sur
`"sqlite:///./stockline.db"` si elle est absente. Pourquoi ce mécanisme
est-il central pour les déploiements à venir ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Classez ces événements par niveau de log approprié
(INFO / WARNING / ERROR) :
a) « hôte db-01 injoignable, on continue le contrôle » ;
b) « fichier d'inventaire introuvable, arrêt du script » ;
c) « contrôle terminé : 12 hôtes, 12 joignables ».

**Question 6** — Citez **deux** avantages de logging sur print pour un
script lancé par cron chaque nuit.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Que vérifie ce test, et que se passe-t-il si
`convertir_taille(-1)` renvoie `"0 o"` au lieu de lever l'exception ?

```python
def test_taille_negative():
    with pytest.raises(ValueError):
        convertir_taille(-1)
```

**Question 8** — pytest affiche `collected 0 items` alors que votre
fichier `verifications.py` contient bien des fonctions de test.
Quelles sont les deux causes probables ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — Dans StockLine, le stock d'un produit n'est stocké dans
aucune table : comment `GET /stocks/1` calcule-t-il la quantité ?
Et quel code de statut renvoie `POST /mouvements` pour une sortie de 10
quand le stock courant est de 3 ?

**Question 10** — Demain, un collègue déploie StockLine sur un serveur
avec PostgreSQL. Quels changements doit-il faire dans le **code** de
l'application ? Et en dehors du code ?

</div>

---

<!-- _class: lead -->

# Bravo — le bloc CL-PYTHON est terminé !

## En 4 jours : de zéro à une API déployable

Lundi, vous n'aviez jamais programmé. Ce soir, StockLine tourne sur votre
machine, testée par pytest. Dès lundi prochain : **CL-LINUX** — le système
qui hébergera StockLine, et au CL-TP1, son premier vrai déploiement
(systemd + nginx). Gardez votre venv au chaud.
