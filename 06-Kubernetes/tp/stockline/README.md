# StockLine v1 — API d'inventaire (fil rouge du cursus)

API de gestion d'inventaire (produits, mouvements, stocks) en **FastAPI**,
construite au bloc CL-PYTHON. Elle sera redéployée à chaque TP du cursus
(VM Linux, 3-tiers AWS, serverless, IaC, Kubernetes…).

## Architecture

```text
+-----------------+        HTTP (fetch)        +------------------+
| front/index.html| -------------------------> |  API FastAPI     |
| (page statique) |                            |  app/main.py     |
+-----------------+                            +--------+---------+
                                                        |
                                                SQLAlchemy (app/db.py)
                                                        |
                                          +-------------v-------------+
                                          | SQLite (défaut, zéro conf)|
                                          | ou PostgreSQL via         |
                                          | DATABASE_URL              |
                                          +---------------------------+
```

## Endpoints

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/sante` | Health check (API + base de données) |
| GET | `/produits` | Liste des produits |
| POST | `/produits` | Création d'un produit (référence unique) |
| GET | `/produits/{id}` | Détail d'un produit |
| GET | `/mouvements` | Liste des mouvements |
| POST | `/mouvements` | Entrée ou sortie de stock (sortie ≤ stock courant) |
| GET | `/stocks/{produit_id}` | Stock courant + indicateur d'alerte |

## Lancer en local

```bash
# 1. Environnement virtuel
python3 -m venv .venv
source .venv/bin/activate        # Windows : .venv\Scripts\activate

# 2. Dépendances
pip install -r requirements.txt

# 3. Démarrage (SQLite créée automatiquement : stockline.db)
uvicorn app.main:app --reload
```

L'API écoute sur `http://127.0.0.1:8000`. Documentation interactive :
`http://127.0.0.1:8000/docs`.

### Front statique

Dans un second terminal :

```bash
cd front
python3 -m http.server 8080
```

Puis ouvrez `http://127.0.0.1:8080` : la page liste les produits via `fetch`.

## Tests avec curl

```bash
# Health check
curl http://127.0.0.1:8000/sante

# Créer un produit
curl -X POST http://127.0.0.1:8000/produits \
  -H "Content-Type: application/json" \
  -d '{"reference": "SSD-500", "nom": "Disque SSD 500 Go", "prix_unitaire": 59.90, "seuil_alerte": 5}'

# Lister les produits
curl http://127.0.0.1:8000/produits

# Entrée de stock : +20 unités
curl -X POST http://127.0.0.1:8000/mouvements \
  -H "Content-Type: application/json" \
  -d '{"produit_id": 1, "type": "entree", "quantite": 20}'

# Sortie de stock : -17 unités
curl -X POST http://127.0.0.1:8000/mouvements \
  -H "Content-Type: application/json" \
  -d '{"produit_id": 1, "type": "sortie", "quantite": 17}'

# Stock courant (3 restants < seuil 5 → alerte: true)
curl http://127.0.0.1:8000/stocks/1
```

## Tests automatisés

```bash
pytest tests/ -v
```

## Basculer sur PostgreSQL (blocs suivants)

```bash
# Décommenter psycopg2-binary dans requirements.txt, puis :
pip install -r requirements.txt
export DATABASE_URL="postgresql+psycopg2://stockline:motdepasse@localhost:5432/stockline"
uvicorn app.main:app
```

Aucun changement de code n'est nécessaire : seule `DATABASE_URL` change.

## Structure du projet

```text
stockline/
├── app/
│   ├── __init__.py
│   ├── main.py        # routes FastAPI
│   ├── models.py      # schémas Pydantic (validation)
│   └── db.py          # SQLAlchemy : moteur, tables, sessions
├── front/
│   └── index.html     # front statique minimal
├── tests/
│   └── test_api.py    # tests pytest
├── requirements.txt
├── .env.example       # modèle de configuration (jamais de secrets commités)
└── README.md
```
