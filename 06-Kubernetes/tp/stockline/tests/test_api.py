"""StockLine — tests de l'API avec pytest.

Lancement (depuis code/stockline, venv activé) :
    pytest tests/ -v

Les tests utilisent une base SQLite dédiée (test_stockline.db) pour ne pas
toucher aux données de développement.
"""

import os
import pathlib

# La variable d'environnement DOIT être définie AVANT l'import de l'application,
# car app/db.py lit DATABASE_URL au moment de l'import.
TEST_DB = "test_stockline.db"
os.environ["DATABASE_URL"] = f"sqlite:///./{TEST_DB}"

import pytest
from fastapi.testclient import TestClient

from app.db import Base, engine, init_db
from app.main import app


@pytest.fixture()
def client():
    """Client de test avec une base propre pour chaque test."""
    Base.metadata.drop_all(bind=engine)
    init_db()
    with TestClient(app) as test_client:
        yield test_client


def teardown_module():
    """Supprime le fichier de base de test à la fin du module."""
    engine.dispose()
    pathlib.Path(TEST_DB).unlink(missing_ok=True)


def _creer_produit(client, reference="SSD-500", nom="Disque SSD 500 Go"):
    reponse = client.post(
        "/produits",
        json={"reference": reference, "nom": nom, "prix_unitaire": 59.90, "seuil_alerte": 5},
    )
    assert reponse.status_code == 201
    return reponse.json()


def test_sante(client):
    reponse = client.get("/sante")
    assert reponse.status_code == 200
    corps = reponse.json()
    assert corps["statut"] == "ok"
    assert corps["base_de_donnees"] == "ok"


def test_creer_et_lister_produits(client):
    assert client.get("/produits").json() == []
    produit = _creer_produit(client)
    assert produit["id"] == 1
    assert produit["reference"] == "SSD-500"
    produits = client.get("/produits").json()
    assert len(produits) == 1
    assert produits[0]["nom"] == "Disque SSD 500 Go"


def test_reference_dupliquee_renvoie_409(client):
    _creer_produit(client)
    reponse = client.post(
        "/produits",
        json={"reference": "SSD-500", "nom": "Doublon", "prix_unitaire": 10.0},
    )
    assert reponse.status_code == 409


def test_produit_invalide_renvoie_422(client):
    # prix_unitaire négatif : rejeté par la validation Pydantic.
    reponse = client.post(
        "/produits",
        json={"reference": "KO-1", "nom": "Produit cassé", "prix_unitaire": -3},
    )
    assert reponse.status_code == 422


def test_mouvements_et_stock(client):
    produit = _creer_produit(client)
    produit_id = produit["id"]

    entree = client.post(
        "/mouvements",
        json={"produit_id": produit_id, "type": "entree", "quantite": 20},
    )
    assert entree.status_code == 201

    sortie = client.post(
        "/mouvements",
        json={"produit_id": produit_id, "type": "sortie", "quantite": 17},
    )
    assert sortie.status_code == 201

    stock = client.get(f"/stocks/{produit_id}").json()
    assert stock["quantite"] == 3
    assert stock["alerte"] is True  # 3 < seuil_alerte (5)


def test_sortie_superieure_au_stock_renvoie_400(client):
    produit = _creer_produit(client)
    client.post(
        "/mouvements",
        json={"produit_id": produit["id"], "type": "entree", "quantite": 5},
    )
    reponse = client.post(
        "/mouvements",
        json={"produit_id": produit["id"], "type": "sortie", "quantite": 10},
    )
    assert reponse.status_code == 400
    assert "Stock insuffisant" in reponse.json()["detail"]


def test_mouvement_sur_produit_inexistant_renvoie_404(client):
    reponse = client.post(
        "/mouvements",
        json={"produit_id": 999, "type": "entree", "quantite": 1},
    )
    assert reponse.status_code == 404


def test_stock_produit_inexistant_renvoie_404(client):
    assert client.get("/stocks/999").status_code == 404
