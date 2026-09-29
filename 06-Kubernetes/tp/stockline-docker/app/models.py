"""StockLine — schémas Pydantic (validation des entrées/sorties de l'API).

Deux familles de modèles :
- les modèles ``...Create`` : ce que le client envoie (POST) ;
- les modèles de lecture : ce que l'API renvoie (avec id et horodatage).
"""

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class TypeMouvement(str, Enum):
    """Un mouvement de stock est soit une entrée, soit une sortie."""

    ENTREE = "entree"
    SORTIE = "sortie"


# ---------------------------------------------------------------------------
# Produits
# ---------------------------------------------------------------------------

class ProduitCreate(BaseModel):
    """Données attendues pour créer un produit."""

    reference: str = Field(min_length=1, max_length=50, examples=["SSD-500"])
    nom: str = Field(min_length=1, max_length=200, examples=["Disque SSD 500 Go"])
    prix_unitaire: float = Field(gt=0, examples=[59.90])
    seuil_alerte: int = Field(default=5, ge=0, description="Stock minimal avant alerte")


class Produit(ProduitCreate):
    """Produit tel que renvoyé par l'API (avec identifiant)."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    cree_le: datetime


# ---------------------------------------------------------------------------
# Mouvements
# ---------------------------------------------------------------------------

class MouvementCreate(BaseModel):
    """Données attendues pour enregistrer un mouvement de stock."""

    produit_id: int = Field(gt=0)
    type: TypeMouvement
    quantite: int = Field(gt=0, examples=[10])
    commentaire: str | None = Field(default=None, max_length=300)


class Mouvement(MouvementCreate):
    """Mouvement tel que renvoyé par l'API."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    cree_le: datetime


# ---------------------------------------------------------------------------
# Stocks et santé
# ---------------------------------------------------------------------------

class Stock(BaseModel):
    """État du stock d'un produit (calculé à partir des mouvements)."""

    produit_id: int
    reference: str
    nom: str
    quantite: int
    seuil_alerte: int
    alerte: bool = Field(description="True si la quantité est sous le seuil d'alerte")


class Sante(BaseModel):
    """Réponse du health check GET /sante."""

    statut: str
    base_de_donnees: str
    version: str
