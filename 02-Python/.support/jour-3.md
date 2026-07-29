---
marp: true
title: Admin Cloud — CL-PYTHON — Jour 3
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# Objets, HTTP et votre première API

## Des deux côtés du réseau

CL-PYTHON — Jour 3 : POO utile, requests, FastAPI, pydantic

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Écrire une **classe simple** et comprendre les objets que vous utilisez déjà.
- Décoder une **requête HTTP** : méthode, URL, en-têtes, code de statut.
- Interroger une **API REST publique** avec `requests` (GET, POST, params, timeout).
- Créer votre **première API** avec **FastAPI** : routes, uvicorn, `/docs`.
- Valider les données entrantes avec **pydantic** — sans écrire la validation.

Matin : vous êtes le **client** qui appelle. Après-midi : vous devenez le
**serveur** qui répond. Le rythme accélère — vous avez le socle pour suivre.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. La POO utile à l'admin : classes simples.
2. HTTP : la langue du web et du cloud.
3. requests : consommer une API REST.
4. Changer de camp : concevoir une API.
5. FastAPI : hello, routes, uvicorn.
6. pydantic : la validation en douceur.

</div>

---

<!-- _class: lead -->

# 1. La POO utile à l'admin

---

<style scoped>
div{ font-size:15px }
</style>

## Vous utilisez des objets depuis lundi

<div>

```python
nom = "web-01"
nom.upper()              # méthode d'un objet str
serveurs.append("db-01") # méthode d'un objet list
compteur.get("web", 0)   # méthode d'un objet dict
```

- Un **objet** = des **données** + des **comportements** (méthodes) qui
  vont avec.
- `valeur.methode()` : « demande à l'objet de faire quelque chose ».
- Une **classe** est le moule ; l'objet (ou *instance*) est le gâteau.

Nouveauté du jour : fabriquer **vos propres moules** — parce que
« un serveur » mérite mieux qu'un dictionnaire anonyme.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Écrire une classe simple

<div>

```python
class Serveur:
    """Un serveur du parc."""

    def __init__(self, nom, ip, ram_go):
        self.nom = nom          # attributs : les données de CET objet
        self.ip = ip
        self.ram_go = ram_go

    def description(self):
        return f"{self.nom} ({self.ip}) — {self.ram_go} Go"

web01 = Serveur("web-01", "10.0.1.10", 4)   # appelle __init__
print(web01.description())                  # web-01 (10.0.1.10) — 4 Go
print(web01.ram_go)                         # 4
```

- `__init__` : le **constructeur**, exécuté à la création.
- `self` : « l'objet en train d'agir » — 1ᵉʳ paramètre de chaque méthode,
  rempli automatiquement à l'appel.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Méthodes : le comportement près des données

<div>

```python
class Serveur:
    def __init__(self, nom, ip, ram_go, seuil_alerte=75):
        self.nom = nom
        self.ip = ip
        self.ram_go = ram_go
        self.seuil_alerte = seuil_alerte
        self.cpu = 0.0

    def relever_cpu(self, valeur):
        self.cpu = valeur

    def en_alerte(self):
        return self.cpu >= self.seuil_alerte

web01 = Serveur("web-01", "10.0.1.10", 4)
web01.relever_cpu(87.5)
if web01.en_alerte():
    print(f"{web01.nom} est en alerte !")
```

La règle métier (`en_alerte`) vit **avec** les données : plus de seuil
recopié dans dix scripts.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Une liste d'objets — et les limites du jour

<div>

```python
parc = [
    Serveur("web-01", "10.0.1.10", 4),
    Serveur("web-02", "10.0.1.11", 4),
    Serveur("db-01", "10.0.2.10", 16),
]

for serveur in parc:
    print(serveur.description())

gros = [s for s in parc if s.ram_go >= 8]    # compréhensions : idem !
```

**Notre périmètre POO — assumé :**

- ✅ classes simples, attributs, méthodes, `__init__`.
- ❌ héritage complexe, méthodes magiques, design patterns : hors sujet
  pour l'admin. Si un script en réclame, il est probablement trop compliqué.

Objectif réel : **lire** le code objet des autres (boto3 !) et structurer
proprement le vôtre. Cet après-midi, pydantic écrira les classes pour nous.

</div>

---

<!-- _class: lead -->

# 2. HTTP : la langue du web et du cloud

---

<style scoped>
div{ font-size:15px }
</style>

## Anatomie d'un échange HTTP

<div>

```text
   CLIENT (vous, un script,            SERVEUR (API publique,
    un navigateur, boto3)               AWS, votre FastAPI...)
        |                                      |
        |  REQUÊTE                             |
        |  GET /communes?nom=Lille HTTP/1.1    |
        |  Host: geo.api.gouv.fr               |
        |  Accept: application/json            |
        | ------------------------------------>|
        |                                      |
        |  RÉPONSE                             |
        |  HTTP/1.1 200 OK                     |
        |  Content-Type: application/json      |
        |                                      |
        |  [{"nom": "Lille", ...}]             |
        |<------------------------------------ |
```

Requête = **méthode + URL + en-têtes (+ corps)**.
Réponse = **code de statut + en-têtes + corps** (souvent du JSON).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Méthodes et codes de statut

<div>

Les méthodes — l'**intention** du client :

| Méthode | Intention | Exemple |
|---------|-----------|---------|
| GET | lire | lister les produits |
| POST | créer | ajouter un produit |
| PUT/PATCH | modifier | changer un prix |
| DELETE | supprimer | retirer un produit |

Les codes — le **verdict** du serveur :

| Code | Sens | À retenir |
|------|------|-----------|
| 2xx | succès | 200 OK, 201 créé, 204 sans contenu |
| 4xx | erreur **client** | 400 requête invalide, 401/403 accès, 404 introuvable, 409 conflit, 422 données invalides |
| 5xx | erreur **serveur** | 500 bug côté serveur, 503 indisponible |

Réflexe : **toujours regarder le code avant de lire le corps.**

</div>

---

<!-- _class: lead -->

# 3. requests : consommer une API REST

---

<style scoped>
div{ font-size:15px }
</style>

## Premier GET

<div>

```python
import requests          # pip install requests

reponse = requests.get(
    "https://geo.api.gouv.fr/communes",
    params={"nom": "Lille", "fields": "nom,population"},
    timeout=5,
)

print(reponse.status_code)    # 200
print(reponse.url)            # l'URL réellement appelée, encodée
donnees = reponse.json()      # le corps JSON → structures Python
print(donnees[0]["nom"], donnees[0]["population"])
```

- `params=` construit l'URL proprement (espaces, accents encodés) —
  jamais de concaténation manuelle.
- `timeout=5` : **obligatoire** dans nos scripts — un réseau muet ne doit
  jamais geler un outil d'exploitation.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Vérifier avant d'exploiter

<div>

```python
reponse = requests.get(url, params=parametres, timeout=5)

if reponse.status_code != 200:
    print(f"L'API a répondu {reponse.status_code}", file=sys.stderr)
    sys.exit(1)

donnees = reponse.json()
```

Et l'échec **réseau** (DNS, coupure, timeout) lève une exception :

```python
try:
    reponse = requests.get(url, timeout=5)
except requests.exceptions.RequestException:
    print("Erreur réseau : API injoignable.", file=sys.stderr)
    sys.exit(1)
```

`RequestException` est la mère de toutes les erreurs requests : un seul
`except` les couvre. Le `try/except` d'hier trouve ici son vrai terrain.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## POST : envoyer des données

<div>

```python
nouveau = {"nom": "web-04", "ip": "10.0.1.13", "role": "web"}

reponse = requests.post(
    "http://127.0.0.1:8000/machines",
    json=nouveau,          # sérialise en JSON + en-tête Content-Type
    timeout=5,
)

print(reponse.status_code)     # 201 espéré
print(reponse.json())          # l'objet créé, renvoyé par le serveur
```

- `json=dictionnaire` : requests fabrique le corps JSON **et** l'en-tête
  `Content-Type: application/json`.
- En-têtes personnalisés (authentification, très bientôt dans le cloud) :

```python
requests.get(url, headers={"Authorization": "Bearer <jeton>"}, timeout=5)
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 3.1 — Consommer une API publique

<div>

**À vous** (45 min) :

- `population_commune(nom)` : GET sur `geo.api.gouv.fr` avec `params=`,
  vérification du code, recherche de la correspondance exacte, retour
  `dict` ou `None`.
- Comparatif de 3 villes candidates, trié par population décroissante.
- Blindage : `timeout=5` partout + `except RequestException` → exit 1.

📄 Énoncé : `exercices/02-cl-python/exercice-3-1-consommer-api.md`

Bonus : version CLI avec les villes en arguments (`nargs="+"`).
Les API AWS/Azure se consomment exactement ainsi — avec un jeton en plus.

</div>

---

<!-- _class: lead -->

# 4. Changer de camp : concevoir une API

---

<style scoped>
div{ font-size:15px }
</style>

## Pourquoi l'admin écrit-il des API ?

<div>

Ce matin, quelqu'un répondait à vos requêtes. Qui ? **Un programme comme
celui que vous allez écrire.**

Pourquoi c'est votre affaire, même « côté ops » :

- L'application **StockLine** que vous déploierez pendant tout le cursus
  est une API : il faut comprendre ce qu'on déploie, supervise, sécurise.
- Les outils d'exploitation modernes **exposent** des API : health checks
  (`/sante`), métriques, webhooks.
- Comprendre le serveur = diagnostiquer 10× plus vite côté client
  (« 422 ? C'est ma donnée. 500 ? C'est leur code. »).

Une API = des **fonctions Python** + un **serveur** qui les expose sur
le réseau. Vous savez déjà écrire les fonctions.

</div>

---

<!-- _class: lead -->

# 5. FastAPI : hello, routes, uvicorn

---

<style scoped>
div{ font-size:15px }
</style>

## Une API en 6 lignes

<div>

```python
# hello_api.py          pip install fastapi "uvicorn[standard]"
from fastapi import FastAPI

app = FastAPI(title="Ma première API")

@app.get("/")
def bonjour():
    return {"message": "Bonjour, ici votre première API !"}
```

```bash
uvicorn hello_api:app --reload
# INFO: Uvicorn running on http://127.0.0.1:8000
```

- `@app.get("/")` : un **décorateur** — « quand un GET arrive sur `/`,
  appelle cette fonction ».
- Le dictionnaire renvoyé devient **automatiquement du JSON**.
- `hello_api:app` = fichier `hello_api.py`, objet `app` ;
  `--reload` = redémarrage auto à chaque sauvegarde (dev uniquement).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## FastAPI, uvicorn : qui fait quoi ?

<div>

```text
                 requête HTTP
   client  ─────────────────────►  ┌─────────────────────────────┐
  (navigateur,                     │ UVICORN — le serveur        │
   curl,                           │ écoute le port 8000,        │
   requests)                       │ parle HTTP                  │
                                   ├─────────────────────────────┤
                                   │ FASTAPI — le cadre          │
                                   │ route vers la bonne         │
           ◄─────────────────────  │ fonction, valide, convertit │
                 réponse JSON      ├─────────────────────────────┤
                                   │ VOS FONCTIONS PYTHON        │
                                   └─────────────────────────────┘
```

- **uvicorn** : la boîte qui écoute le réseau (le « moteur »).
- **FastAPI** : l'aiguilleur + le traducteur JSON (le « cadre »).
- **vous** : la logique métier — des fonctions, comme depuis lundi.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## /docs : la documentation gratuite

<div>

Ouvrez `http://127.0.0.1:8000/docs` :

- Chaque route est **documentée automatiquement** : méthode, paramètres,
  schéma de réponse.
- Le bouton **« Try it out »** exécute de vraies requêtes — un client HTTP
  intégré, parfait pour tester sans curl.
- La doc se met à jour **toute seule** à chaque route ajoutée.

Pour l'admin, `/docs` est un outil de **diagnostic** : l'API est-elle
vivante ? Quelles routes existent ? Quel format attend-elle ?

(Cette page vous accompagnera à chaque déploiement de StockLine.)

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Routes avec paramètres

<div>

Paramètre **de chemin** — dans l'URL :

```python
@app.get("/serveurs/{nom}")
def detail_serveur(nom: str):
    return {"serveur": nom, "statut": "actif"}
# GET /serveurs/web-01  →  {"serveur": "web-01", ...}
```

Paramètre **de requête** — après le `?` :

```python
@app.get("/serveurs")
def lister(role: str | None = None):
    if role is None:
        return serveurs
    return [s for s in serveurs if s.role == role]
# GET /serveurs?role=web
```

Règle : le `{nom}` du décorateur doit correspondre **exactement** au
paramètre de la fonction. Un paramètre avec défaut = paramètre `?query`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 3.1 — Première API FastAPI

<div>

**De « hello » au mini-inventaire**, en direct :

1. L'API en 6 lignes + `uvicorn --reload`.
2. Le moment `/docs` — la doc interactive.
3. Route paramétrée `GET /serveurs/{nom}`.
4. Modèle pydantic `Serveur` + `POST /serveurs` : la validation
   automatique (le fameux 422) et le conflit 409.
5. Redémarrage → données perdues : pourquoi il faudra une **base** demain.

📄 Fiche : `demos/02-cl-python/demo-3-1-api-fastapi.md`
💾 Code : `code/02-cl-python/demo-3-1/hello_api.py`

</div>

---

<!-- _class: lead -->

# 6. pydantic : la validation en douceur

---

<style scoped>
div{ font-size:15px }
</style>

## Le problème : on ne fait pas confiance au client

<div>

Votre API va recevoir du JSON du monde extérieur. Que faire de :

```json
{"nom": "", "ip": 42, "cpu": -8}
```

Sans garde-fou : données pourries en mémoire, bugs différés, incidents.
À la main : des dizaines de `if` pénibles dans chaque route.

**pydantic** : on **déclare** la forme attendue, la bibliothèque contrôle
tout à l'entrée.

```python
from pydantic import BaseModel, Field

class Serveur(BaseModel):
    nom: str = Field(min_length=1)
    ip: str
    cpu: int = Field(gt=0, le=128)
```

Une classe (comme ce matin !) qui hérite de `BaseModel` : champs typés,
contraintes déclarées.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## pydantic + FastAPI : le videur à l'entrée

<div>

```python
serveurs: list[Serveur] = []

@app.post("/serveurs", status_code=201)
def ajouter(serveur: Serveur):     # ← le type suffit !
    serveurs.append(serveur)
    return serveur
```

FastAPI voit le type `Serveur` et fait tout : lecture du corps JSON,
validation, conversion en objet. Donnée invalide → réponse **422**
détaillée, votre fonction **n'est jamais appelée** :

```json
{"detail": [{"loc": ["body", "cpu"],
             "msg": "Input should be greater than 0", ...}]}
```

Accès dans le code : `serveur.nom`, `serveur.cpu` — un objet propre,
garanti conforme. Le 422 dit au client : « c'est **ta** donnée le problème ».

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Refuser proprement : HTTPException

<div>

pydantic contrôle la **forme** ; les règles **métier** restent à vous :

```python
from fastapi import HTTPException

@app.post("/serveurs", status_code=201)
def ajouter(serveur: Serveur):
    for existant in serveurs:
        if existant.nom == serveur.nom:
            raise HTTPException(
                status_code=409,
                detail=f"{serveur.nom} existe déjà.",
            )
    serveurs.append(serveur)
    return serveur
```

- 422 : forme invalide (pydantic, automatique).
- 409 : conflit métier (doublon) — **votre** règle, votre `raise`.
- 404 : introuvable — idem pour `GET /serveurs/{nom}` inconnu.

Le code HTTP **est** le contrat : les clients décident en le lisant.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 3.2 — Votre première API : le parc de machines

<div>

**À vous** (60 min) — seuls aux commandes cette fois :

- Modèle `Machine` : nom (1-50 car.), ip, rôle limité à 3 valeurs
  (`Literal`), `ram_go` entre 1 et 1024.
- `GET /machines`, `GET /machines/{nom}` (404 si absente),
  `POST /machines` (201, et 409 sur doublon).
- Vérification aux codes : 201, puis 409, puis 422 — commandes curl
  fournies dans l'énoncé.

📄 Énoncé : `exercices/02-cl-python/exercice-3-2-api-parc.md`

Bonus : `DELETE /machines/{nom}` (204) et filtre `?role=web`.
C'est la répétition générale de StockLine, assemblée demain.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap — les points clés du jour

<div>

- Classe = données (`self.attribut`) + comportements (méthodes) ;
  `__init__` construit ; notre POO reste **volontairement simple**.
- HTTP : méthode (GET/POST/…) + URL + en-têtes + corps ; réponse = code
  + corps. 2xx succès, 4xx faute du client, 5xx faute du serveur.
- requests : `params=`, `json=`, `timeout=5` **toujours**,
  `except RequestException` pour le réseau.
- FastAPI : `@app.get("/route")` sur une fonction ; uvicorn sert ;
  `/docs` documente et teste.
- pydantic : la forme des données **déclarée** dans un modèle ; 422
  automatique ; les règles métier restent à vous (`HTTPException`).
- En mémoire = perdu au redémarrage → demain : la **base de données**.

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

**Question 1** — Dans cette classe, à quoi sert `self` ? Et quand
`__init__` est-elle exécutée ?

```python
class Serveur:
    def __init__(self, nom):
        self.nom = nom
```

**Question 2** — Associez chaque méthode HTTP à son intention :
GET, POST, DELETE — créer une ressource, lire des données,
supprimer une ressource.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 3 et 4

<div>

**Question 3** — Votre script reçoit un code **404**, puis sur un autre
appel un code **503**. Dans chaque cas : qui est en cause (client ou
serveur) et que signifie le code ?

**Question 4** — Quels sont les **deux** défauts de cet appel ?

```python
reponse = requests.get("https://api.exemple.fr/communes?nom=" + ville)
donnees = reponse.json()
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 5 et 6

<div>

**Question 5** — Que fait l'argument `json=` dans
`requests.post(url, json=donnees)` ? Citez les deux choses qu'il
prépare dans la requête.

**Question 6** — Dans la commande `uvicorn hello_api:app --reload` :
a) que désignent `hello_api` et `app` ?
b) que fait `--reload`, et pourquoi est-il réservé au développement ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 7 et 8

<div>

**Question 7** — Quelle URL faut-il appeler, avec quelle méthode, pour
déclencher cette fonction avec `nom = "db-01"` ?

```python
@app.get("/serveurs/{nom}")
def detail(nom: str):
    ...
```

**Question 8** — Un client envoie `{"cpu": -8}` à une route dont le
modèle pydantic exige `cpu: int = Field(gt=0)`.
a) Quel code de statut reçoit-il ?
b) Votre fonction de route est-elle exécutée ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Quiz — questions 9 et 10

<div>

**Question 9** — Quelle est la différence de rôle entre la validation
pydantic (422) et un `raise HTTPException(status_code=409)` dans la
route ? Donnez un exemple de chaque.

**Question 10** — Hier soir, un apprenti a créé 3 machines via
`POST /machines` sur l'API de l'exercice 3.2. Ce matin, `GET /machines`
renvoie `[]`. Que s'est-il passé, et quelle est la solution générale
(vue demain) ?

</div>

---

<!-- _class: lead -->

# À demain !

## Demain : le grand assemblage

Le matin, la boîte à outils d'exploitation (subprocess, pathlib, logging,
pytest) et le **mini-projet inventaire**. L'après-midi, naissance de
**StockLine v1** — l'API que vous déploierez pendant les 15 prochaines
semaines. Le meilleur jour de la semaine.
