---
marp: true
title: Admin Cloud — CL-PYTHON — Jour 1
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Python pour l'administrateur cloud

## Votre premier langage, choisi pour votre futur métier

CL-PYTHON — Jour 1 : premiers pas, variables, décisions, répétitions

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Expliquer **pourquoi Python est l'outil n°1** de l'administrateur cloud.
- Vérifier votre installation, utiliser le **REPL** et exécuter un **premier script**.
- Manipuler les **4 types de base** : `int`, `float`, `str`, `bool` — et les **f-strings**.
- Faire prendre des **décisions** à un script (`if / elif / else`).
- **Répéter** des actions sur des listes (`for`).
- Écrire vos premières **fonctions** réutilisables.
- Créer un **environnement virtuel** (venv) et installer un paquet avec **pip**.

Vous n'avez jamais programmé ? Parfait : cette journée est conçue pour vous.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. Pourquoi Python pour l'admin cloud ?
2. Installation, REPL et premier script.
3. Variables et types de base.
4. Conditions : décider.
5. Boucles : répéter.
6. Fonctions : réutiliser.
7. venv et pip : votre atelier d'outillage.

Rythme : théorie ↔ démo courte toutes les ~45 min, deux exercices dans la journée, quiz en fin d'après-midi.

</div>

---

<!-- _class: lead -->

# 1. Pourquoi Python pour l'admin cloud ?

---

<style scoped>
div{ font-size:15px }
</style>

## Le métier : automatiser, superviser, sécuriser

<div>

Un administrateur cloud **ne clique pas dans une console à longueur de journée** :

- Il **automatise** : créer 20 serveurs identiques, sauvegarder chaque nuit, nettoyer les ressources oubliées.
- Il **supervise** : vérifier que tout répond, collecter des métriques, générer des rapports.
- Il **sécurise** : auditer les configurations, détecter les dérives, appliquer des règles.

À la main, chacune de ces tâches prend des heures et produit des erreurs.
En script, elle prend des secondes et **donne toujours le même résultat**.

Le script, c'est votre collègue infatigable. Cette semaine, vous apprenez à le recruter.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi Python, précisément ?

<div>

- **Lisible** : la syntaxe ressemble à de l'anglais simple — idéal pour débuter.
- **Partout dans le cloud** : AWS (boto3, Lambda), Azure, Ansible, OpenStack… sont écrits en Python ou pilotables en Python.
- **Préinstallé** sur la quasi-totalité des serveurs Linux que vous administrerez.
- **Un écosystème immense** : un besoin = une bibliothèque (`requests`, `pyyaml`, `fastapi`…).
- **Le langage demandé** dans les offres d'emploi « administrateur cloud / DevOps ».

Notre angle toute la semaine : Python comme **outil d'automatisation**,
pas Python pour devenir développeur — pas d'algorithmique savante, du code
**simple, lisible, qui marche**. Et une règle : **on tape tout**, on
copie-colle le moins possible ; les messages d'erreur sont des indices,
pas des sanctions.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Où Python vous servira dans le cursus

<div>

| Bloc | Ce que vous ferez en Python |
|------|-----------------------------|
| CL-PYTHON (cette semaine) | Le socle + l'application fil rouge **StockLine** |
| CL-LINUX / CL-TP1 | Scripts d'exploitation sur VM (sauvegarde, rapport) |
| CL-AWS1 / CL-TP2 | Piloter AWS avec **boto3**, scripts d'infrastructure |
| CL-AWS2 / CL-TP3 | Fonctions **Lambda** serverless en Python |
| CL-IAC / CL-TP4 | Ansible (YAML + modules Python), tests de pipeline |
| CL-CONT / CL-TP5 | Conteneuriser StockLine, sondes de santé |
| CL-SECU | Scripts d'audit de configuration |

Tout ce que vous apprenez cette semaine **resservira chaque semaine**.

</div>

---

<!-- _class: lead -->

# 2. Installation, REPL et premier script

---

<style scoped>
div{ font-size:15px }
</style>

## Vérifier son installation

<div>

Votre poste a été préparé au jour 1 du cursus. Vérifions :

```bash
python3 --version
# Python 3.12.x attendu
```

- **macOS / Linux** : la commande est `python3`.
- **Windows** : `py --version` ou `python --version` (selon l'installation).

Si la commande répond « introuvable » : levez la main maintenant —
c'est le seul blocage qui empêche de suivre la journée.

Nous utiliserons **Python 3.12** toute la formation. Écrivez `python3` dans
vos notes : c'est la commande que vous taperez des centaines de fois.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le REPL : discuter avec Python

<div>

Tapez `python3` sans argument : vous entrez dans le **REPL**
(Read-Eval-Print-Loop) — Python lit, évalue, affiche, recommence.

```python
>>> 2 + 2
4
>>> 16 * 1024        # les Mo dans 16 Go
16384
>>> "web-" + "01"
'web-01'
>>> exit()           # ou Ctrl-D pour sortir
```

- Le `>>>` est **l'invite** : Python attend votre instruction.
- Tout est évalué **immédiatement** : parfait pour tester une idée.
- `#` commence un **commentaire** : ignoré par Python, précieux pour l'humain.

Réflexe à prendre : un doute sur une syntaxe → 10 secondes de REPL.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Du REPL au script : un fichier `.py`

<div>

Le REPL oublie tout quand on le quitte. Pour **conserver et rejouer**,
on écrit les instructions dans un fichier texte d'extension `.py` :

```python
# bonjour.py — mon premier script
print("Bonjour depuis mon premier script !")
print("Ce fichier est rejouable à volonté.")
```

Exécution depuis le terminal :

```bash
python3 bonjour.py
```

- `print(...)` **affiche** dans le terminal.
- Un script = des instructions exécutées **de haut en bas**.
- Sauvegardez **avant** de lancer (Cmd/Ctrl + S) — l'oubli classique du débutant.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 1.1 — Du REPL au premier script

<div>

**Rapport d'état d'un serveur** — construit sous vos yeux, brique par brique :

1. Quelques calculs dans le REPL pour s'échauffer.
2. Un script `check_serveur.py` : variables, affichage f-string.
3. Une condition qui déclenche une alerte CPU.
4. Une boucle qui vérifie une liste de services.
5. Une fonction réutilisable `etat_cpu()`.

La démo avance **au rythme des sections de la journée** : nous y reviendrons
après chaque nouvelle notion.

📄 Fiche : `demos/02-cl-python/demo-1-1-premier-script.md`
💾 Code final : `code/02-cl-python/demo-1-1/check_serveur.py`

</div>

---

<!-- _class: lead -->

# 3. Variables et types de base

---

<style scoped>
div{ font-size:15px }
</style>

## La variable : une boîte étiquetée

<div>

```python
nom_serveur = "web-01"
memoire_go = 16
```

- Le signe `=` **affecte** : « range la valeur de droite dans la boîte de gauche ».
- Le nom s'écrit en **minuscules_avec_underscores** (convention Python).
- Une variable peut être **réutilisée** et **remplacée** :

```python
memoire_go = 16
memoire_go = 32          # la boîte contient maintenant 32
print(memoire_go)        # 32
```

Choisissez des noms qui **racontent** : `memoire_go` vaut mieux que `m`.
Dans 6 mois, vous relirez vos scripts — soyez gentil avec votre futur vous.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les 4 types de base

<div>

| Type | Exemple | Pour quoi faire |
|------|---------|-----------------|
| `int` | `16`, `8080`, `-3` | compter : Go, ports, CPU |
| `float` | `87.5`, `0.99` | mesurer : %, secondes, euros |
| `str` | `"web-01"`, `'10.0.1.10'` | nommer : hôtes, IP, chemins |
| `bool` | `True`, `False` | décider : actif ? sauvegardé ? |

```python
>>> type("8080")
<class 'str'>
>>> type(8080)
<class 'int'>
```

⚠️ `"8080"` (avec guillemets) est du **texte**, pas un nombre.
Le type détermine ce qu'on **peut faire** avec la valeur.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Opérations et conversions

<div>

```python
>>> 500 - 412.5          # int et float se mélangent
87.5
>>> 7 // 2               # division entière
3
>>> 7 % 2                # reste (modulo)
1
>>> "web" + "-01"        # + concatène les str
'web-01'
>>> "8080" + 1           # ⛔ TypeError : texte + nombre
```

Conversion explicite quand les types ne s'accordent pas :

```python
>>> int("8080") + 1
8081
>>> str(404) + " Not Found"
'404 Not Found'
```

`input()` renvoie **toujours** une `str` : convertissez avant de calculer.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les f-strings : formater proprement

<div>

La f-string insère des variables dans du texte : `f"..."` + `{variable}`.

```python
serveur = "web-01"
cpu = 87.5
print(f"Serveur {serveur} : CPU à {cpu} %")
# Serveur web-01 : CPU à 87.5 %
```

Contrôler l'affichage des nombres :

```python
ratio = 412.5 / 500 * 100
print(f"Occupation : {ratio:.1f} %")     # 82.5  (1 décimale)
print(f"Port : {8080:>6}")               # aligné à droite sur 6 caractères
```

Oublier le `f` devant les guillemets = le texte `{serveur}` s'affiche tel
quel. C'est LA faute de frappe de la semaine — vérifiez le `f` d'abord.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le bool : la réponse à une question

<div>

Un `bool` vaut `True` ou `False`. Il naît souvent d'une **comparaison** :

```python
>>> cpu = 87.5
>>> cpu > 90
False
>>> cpu >= 75
True
>>> "web-01" == "web-02"
False
>>> "web-01" != "web-02"
True
```

| Opérateur | Sens |
|-----------|------|
| `==` / `!=` | égal / différent |
| `<` `<=` `>` `>=` | comparaisons |
| `and` / `or` / `not` | et / ou / non |

⚠️ `=` affecte, `==` compare. Les confondre est l'erreur classique n°2.

</div>

---

<!-- _class: lead -->

# 4. Conditions : décider

---

<style scoped>
div{ font-size:15px }
</style>

## if / else : la première décision

<div>

```python
cpu = 87.5

if cpu >= 90:
    print("ALERTE : CPU critique !")
else:
    print("CPU sous contrôle.")
```

Anatomie — chaque détail compte :

- `if condition:` — le **deux-points** est obligatoire.
- Le bloc en dessous est **indenté de 4 espaces** : c'est l'indentation
  qui dit « ces lignes appartiennent au if ».
- `else:` — « dans tous les autres cas ».

En Python, l'indentation n'est pas de la décoration : **c'est la grammaire**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## elif : plusieurs niveaux de décision

<div>

```python
cpu = 87.5

if cpu >= 90:
    print("CRITIQUE : intervenez !")
elif cpu >= 75:
    print("ATTENTION : à surveiller.")
else:
    print("OK.")
```

- Python teste **de haut en bas** et exécute le **premier** bloc vrai — puis saute le reste.
- Ordre des seuils : **du plus restrictif au plus large** (90 avant 75).
- On enchaîne autant de `elif` que nécessaire, le `else` final est optionnel.

Question réflexe à se poser : « et si la valeur est exactement 90 ? 75 ? » —
les **bornes** sont le nid à bugs préféré des conditions.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Combiner des conditions

<div>

```python
cpu = 87.5
en_production = True

if cpu >= 75 and en_production:
    print("Serveur de prod chargé : prévenir l'astreinte.")

if not en_production:
    print("Serveur de test : personne à réveiller.")
```

- `and` : les **deux** conditions doivent être vraies.
- `or` : **au moins une**.
- `not` : inverse.

Deux questions différentes = deux `if` **séparés** (ils peuvent tous deux
s'exécuter). Une seule question à plusieurs réponses = `if/elif/else`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 1.1 — Rapport de capacité d'un serveur

<div>

**À vous** (30 min, seul·e) :

- Un script `rapport_capacite.py` : variables des 4 types, calculs
  d'espace libre et de pourcentage, affichage f-string soigné.
- Un verdict `CRITIQUE / ATTENTION / OK` selon l'occupation disque.
- Une alerte **indépendante** si la sauvegarde est désactivée.

Testez plusieurs jeux de valeurs pour passer dans **chaque branche**.

📄 Énoncé : `exercices/02-cl-python/exercice-1-1-rapport-capacite.md`

Indices dans l'énoncé (balises dépliables) — cherchez 10 min avant de les ouvrir.

</div>

---

<!-- _class: lead -->

# 5. Boucles : répéter

---

<style scoped>
div{ font-size:15px }
</style>

## for : une action par élément

<div>

```python
services = ["nginx", "postgresql", "sshd"]

for service in services:
    print(f"Vérification de {service}...")
```

```text
Vérification de nginx...
Vérification de postgresql...
Vérification de sshd...
```

- `services` est une **liste** : des valeurs ordonnées entre crochets
  (on l'explore à fond demain).
- À chaque **tour**, la variable `service` prend la valeur suivante.
- Le bloc indenté est exécuté **une fois par élément**.

3 serveurs ou 3 000 : la boucle ne change pas. **C'est ça, l'automatisation.**

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## range : répéter N fois

<div>

```python
for numero in range(3):
    print(f"Tentative {numero}")
# Tentative 0 / Tentative 1 / Tentative 2
```

- `range(3)` produit `0, 1, 2` : ça **commence à 0** et s'arrête **avant** 3.
- `range(1, 4)` produit `1, 2, 3` — début inclus, fin exclue.

Usage typique d'admin : générer des noms de machines :

```python
for numero in range(1, 4):
    print(f"web-{numero:02d}")     # web-01, web-02, web-03
```

(`:02d` : entier sur 2 chiffres, complété par un zéro.)

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le motif accumulateur

<div>

Compter ou additionner au fil de la boucle — le motif le plus utile du métier :

```python
charges = [42.0, 91.5, 78.0, 12.5, 88.0]

total = 0                 # 1. initialiser AVANT la boucle
alertes = 0

for charge in charges:
    total = total + charge        # 2. mettre à jour À CHAQUE tour
    if charge >= 75:
        alertes = alertes + 1

moyenne = total / len(charges)    # 3. exploiter APRÈS la boucle
print(f"Moyenne : {moyenne:.1f} % — {alertes} alerte(s)")
```

`len(...)` donne le nombre d'éléments. Raccourci utile : `total += charge`.

À connaître aussi : `while condition:` répète **tant que** la condition
est vraie (attendre un service, réessayer une connexion). Attention à la
boucle infinie — Ctrl-C interrompt. En pratique, `for` couvre 90 % de vos
besoins d'admin.

</div>

---

<!-- _class: lead -->

# 6. Fonctions : réutiliser

---

<style scoped>
div{ font-size:15px }
</style>

## def : donner un nom à une recette

<div>

```python
def etat_cpu(pourcentage):
    """Classe une charge CPU en CRITIQUE / ELEVE / OK."""
    if pourcentage >= 90:
        return "CRITIQUE"
    if pourcentage >= 75:
        return "ELEVE"
    return "OK"

print(etat_cpu(87.5))    # ELEVE
print(etat_cpu(42))      # OK
```

- `def nom(paramètres):` **définit** ; `nom(valeurs)` **appelle**.
- `return` renvoie le résultat à l'appelant **et termine** la fonction.
- La chaîne sous le `def` est la **docstring** : la doc intégrée.

Écrite une fois, appelée mille fois — sur 5 serveurs comme sur 500.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## return ≠ print

<div>

La confusion n°1 des débutants :

```python
def double_print(x):
    print(x * 2)         # affiche… et renvoie None

def double_return(x):
    return x * 2         # renvoie une valeur exploitable

resultat = double_return(21)
print(resultat + 8)      # 50 — on peut CALCULER avec

resultat = double_print(21)   # affiche 42...
print(resultat)               # ...mais resultat vaut None
```

- `print` **montre** à l'humain ; `return` **transmet** au programme.
- Une fonction sans `return` renvoie `None` (« rien »).

Règle d'or : la fonction **calcule et renvoie**, l'appelant **affiche**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Paramètres et valeurs par défaut

<div>

```python
def verifier(serveur, seuil=75):
    """Le seuil est optionnel : 75 si non précisé."""
    return f"{serveur} : seuil d'alerte à {seuil} %"

print(verifier("web-01"))              # seuil à 75 %
print(verifier("db-01", 90))           # seuil à 90 %
print(verifier("db-01", seuil=90))     # pareil, plus lisible
```

- Les paramètres avec défaut se placent **après** ceux sans défaut.
- L'appel avec `nom=valeur` (argument nommé) rend le code auto-documenté —
  vous le verrez partout dans boto3 et FastAPI.

Bonne pratique : une fonction = **une responsabilité**, un nom qui dit
ce qu'elle fait (`etat_cpu`, `verifier`), une docstring.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 1.2 — Surveillance CPU d'un petit parc

<div>

**À vous** (45 min, seul·e ou en binôme) :

- Une fonction `etat_cpu(pourcentage)` — testée avant d'aller plus loin.
- Une boucle sur 5 serveurs : affichage nom + charge + état.
- Le motif accumulateur : charge moyenne du parc, nombre de serveurs
  à surveiller.

Sortie attendue fournie dans l'énoncé — votre script doit la reproduire
exactement.

📄 Énoncé : `exercices/02-cl-python/exercice-1-2-surveillance-cpu.md`

Bonus si vous finissez en avance : la fonction `serveur_le_plus_charge`.

</div>

---

<!-- _class: lead -->

# 7. venv et pip : votre atelier d'outillage

---

<style scoped>
div{ font-size:15px }
</style>

## Le problème : des projets, des versions

<div>

Python de base est riche, mais le métier utilise des **bibliothèques
externes** : `requests` (HTTP), `pyyaml` (YAML), `fastapi` (API)…

Sans précaution, tout s'installe **au même endroit** :

```text
   Machine sans venv                Machine avec venv
+----------------------+       +---------------------------+
| Python système       |       | Python système (intact)   |
|  requests 2.19 ← projet A     +---------------------------+
|  requests 2.32 ← projet B     | projet-a/.venv → req 2.19 |
|  💥 conflit !        |       | projet-b/.venv → req 2.32 |
+----------------------+       |  ✅ chacun chez soi        |
                               +---------------------------+
```

Le **venv** (environnement virtuel) : une bulle Python **par projet**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Créer et activer un venv

<div>

```bash
# 1. Créer le dossier du projet et s'y placer
mkdir mon-projet && cd mon-projet

# 2. Créer la bulle (une fois par projet)
python3 -m venv .venv

# 3. L'activer (à CHAQUE session de travail)
source .venv/bin/activate        # macOS / Linux
# .venv\Scripts\activate         # Windows (PowerShell/cmd)
```

Le prompt affiche alors `(.venv)` : vous êtes **dans la bulle**.

```bash
deactivate                       # pour en sortir
```

Réflexe quotidien : terminal ouvert → `cd` projet → `source .venv/bin/activate`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## pip : installer des bibliothèques

<div>

Le venv activé, `pip` installe **dans la bulle** :

```bash
pip install requests             # installe la dernière version
pip list                         # ce qui est installé ici
```

Vérification immédiate :

```python
>>> import requests
>>> requests.__version__
'2.32.3'
```

`ModuleNotFoundError: No module named 'requests'` en lançant un script ?
Diagnostic en 5 secondes : **le venv n'est pas activé** (regardez le prompt)
ou le paquet n'est pas installé dedans. Ce message, vous le reverrez —
maintenant vous savez le lire.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## requirements.txt : la liste de courses

<div>

Pour qu'un collègue (ou un serveur !) recrée votre environnement :

```text
# requirements.txt
requests==2.32.3
pyyaml==6.0.2
```

```bash
pip install -r requirements.txt   # installe tout, aux bonnes versions
```

- `==` fige la version : le script qui marche chez vous marche chez l'autre.
- Ce fichier accompagne **chaque** projet Python sérieux — StockLine en
  aura un dès jeudi.
- C'est la première brique de la **reproductibilité**, l'obsession du
  DevOps (on la retrouvera avec Terraform, Docker…).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap — les points clés du jour

<div>

- Python = **l'outil d'automatisation** de l'admin cloud ; présent partout.
- REPL pour **tester**, script `.py` pour **conserver et rejouer**.
- 4 types : `int`, `float`, `str`, `bool` — le type détermine les opérations.
- f-string : `f"CPU à {valeur:.1f} %"`.
- `if / elif / else` : Python exécute le **premier** bloc vrai ; l'**indentation
  délimite les blocs**.
- `for element in liste:` + motif accumulateur = 90 % des scripts d'admin.
- Fonction : `def` + paramètres + `return` (qui n'est **pas** `print`).
- Un projet = un **venv** + un **requirements.txt** ; `pip install` dans la bulle.

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

**Question 1** — Quel est le type de chacune de ces valeurs ?

```python
a = "8080"
b = 8080
c = 80.80
d = False
```

**Question 2** — Qu'affichent ces deux lignes ?

```python
print(7 // 2)
print(7 % 2)
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Corrigez cette ligne pour qu'elle affiche
`Serveur web-01 : 87.5 %` :

```python
serveur = "web-01"
cpu = 87.5
print("Serveur {serveur} : {cpu} %")
```

**Question 4** — Qu'affiche ce code si `cpu = 92` ? Et si `cpu = 80` ?

```python
if cpu >= 75:
    print("ATTENTION")
elif cpu >= 90:
    print("CRITIQUE")
else:
    print("OK")
```

Y voyez-vous un problème ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Quelle est la différence entre `=` et `==` ?
Donnez un exemple d'utilisation de chacun.

**Question 6** — Combien de tours fait cette boucle, et qu'affiche-t-elle ?

```python
for i in range(3):
    print(f"web-{i}")
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Qu'affiche ce code, et pourquoi ?

```python
def calculer(x):
    print(x * 2)

resultat = calculer(10)
print(resultat)
```

**Question 8** — Ce code doit compter les serveurs chargés, mais il plante.
Pourquoi ?

```python
for charge in [80, 92, 45]:
    if charge >= 75:
        compteur = compteur + 1
print(compteur)
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — Un collègue lance votre script et obtient :
`ModuleNotFoundError: No module named 'requests'`.
Citez les **deux** causes les plus probables et la commande qui corrige
chacune.

**Question 10** — À quoi sert un environnement virtuel (venv) ?
Répondez en une phrase, puis citez la commande pour en créer un et
celle pour l'activer.

</div>

---

<!-- _class: lead -->

# À demain !

## Demain : brancher Python sur de vraies données

Listes, dictionnaires, fichiers, **JSON et YAML** — vous lirez votre premier
inventaire de serveurs et construirez votre premier outil en ligne de
commande. Le clavier chauffe sérieusement à partir de demain matin.
