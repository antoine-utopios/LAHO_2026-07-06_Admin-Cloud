"""StockLine v1 — API de gestion d'inventaire (produits, mouvements, stocks).

Application fil rouge du cursus Administrateur Cloud 2026.

Lancement en local :
    uvicorn app.main:app --reload

Documentation interactive : http://127.0.0.1:8000/docs
"""

from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from app import models
from app.db import MouvementDB, ProduitDB, get_session, init_db

VERSION = "1.0.0"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Au démarrage : création des tables si nécessaire."""
    init_db()
    yield


app = FastAPI(
    title="StockLine",
    description="API d'inventaire — fil rouge du cursus Administrateur Cloud",
    version=VERSION,
    lifespan=lifespan,
)

# Le front statique (front/index.html) est servi depuis une autre origine :
# on autorise les appels cross-origin (CORS). En production, restreindre la liste.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Santé
# ---------------------------------------------------------------------------

@app.get("/sante", response_model=models.Sante, tags=["exploitation"])
def sante(session: Session = Depends(get_session)) -> models.Sante:
    """Health check : l'API répond-elle et la base est-elle joignable ?"""
    try:
        session.execute(text("SELECT 1"))
        etat_bdd = "ok"
    except Exception:  # noqa: BLE001 — on veut un diagnostic, pas un crash
        etat_bdd = "indisponible"
    return models.Sante(statut="ok", base_de_donnees=etat_bdd, version=VERSION)


# ---------------------------------------------------------------------------
# Produits
# ---------------------------------------------------------------------------

@app.get("/produits", response_model=list[models.Produit], tags=["produits"])
def lister_produits(session: Session = Depends(get_session)) -> list[ProduitDB]:
    """Liste tous les produits référencés."""
    return list(session.execute(select(ProduitDB).order_by(ProduitDB.id)).scalars())


@app.post(
    "/produits",
    response_model=models.Produit,
    status_code=status.HTTP_201_CREATED,
    tags=["produits"],
)
def creer_produit(
    produit: models.ProduitCreate, session: Session = Depends(get_session)
) -> ProduitDB:
    """Crée un produit. La référence doit être unique."""
    existant = session.execute(
        select(ProduitDB).where(ProduitDB.reference == produit.reference)
    ).scalar_one_or_none()
    if existant is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"La référence '{produit.reference}' existe déjà (id={existant.id}).",
        )
    nouveau = ProduitDB(**produit.model_dump())
    session.add(nouveau)
    session.commit()
    session.refresh(nouveau)
    return nouveau


@app.get("/produits/{produit_id}", response_model=models.Produit, tags=["produits"])
def lire_produit(produit_id: int, session: Session = Depends(get_session)) -> ProduitDB:
    """Renvoie un produit par son identifiant."""
    produit = session.get(ProduitDB, produit_id)
    if produit is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produit {produit_id} introuvable.",
        )
    return produit


# ---------------------------------------------------------------------------
# Mouvements
# ---------------------------------------------------------------------------

def _quantite_en_stock(session: Session, produit_id: int) -> int:
    """Calcule le stock courant : somme des entrées moins somme des sorties."""
    total = 0
    lignes = session.execute(
        select(MouvementDB.type, func.sum(MouvementDB.quantite))
        .where(MouvementDB.produit_id == produit_id)
        .group_by(MouvementDB.type)
    ).all()
    for type_mouvement, somme in lignes:
        if type_mouvement == models.TypeMouvement.ENTREE.value:
            total += int(somme)
        else:
            total -= int(somme)
    return total


@app.get("/mouvements", response_model=list[models.Mouvement], tags=["mouvements"])
def lister_mouvements(session: Session = Depends(get_session)) -> list[MouvementDB]:
    """Liste tous les mouvements de stock (entrées et sorties)."""
    return list(session.execute(select(MouvementDB).order_by(MouvementDB.id)).scalars())


@app.post(
    "/mouvements",
    response_model=models.Mouvement,
    status_code=status.HTTP_201_CREATED,
    tags=["mouvements"],
)
def creer_mouvement(
    mouvement: models.MouvementCreate, session: Session = Depends(get_session)
) -> MouvementDB:
    """Enregistre un mouvement. Une sortie ne peut pas dépasser le stock courant."""
    produit = session.get(ProduitDB, mouvement.produit_id)
    if produit is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produit {mouvement.produit_id} introuvable.",
        )
    if mouvement.type == models.TypeMouvement.SORTIE:
        stock = _quantite_en_stock(session, mouvement.produit_id)
        if mouvement.quantite > stock:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Stock insuffisant pour '{produit.nom}' : "
                    f"{stock} en stock, sortie demandée de {mouvement.quantite}."
                ),
            )
    nouveau = MouvementDB(
        produit_id=mouvement.produit_id,
        type=mouvement.type.value,
        quantite=mouvement.quantite,
        commentaire=mouvement.commentaire,
    )
    session.add(nouveau)
    session.commit()
    session.refresh(nouveau)
    return nouveau


# ---------------------------------------------------------------------------
# Stocks
# ---------------------------------------------------------------------------

@app.get("/stocks/{produit_id}", response_model=models.Stock, tags=["stocks"])
def lire_stock(produit_id: int, session: Session = Depends(get_session)) -> models.Stock:
    """Renvoie l'état du stock d'un produit, avec indicateur d'alerte."""
    produit = session.get(ProduitDB, produit_id)
    if produit is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produit {produit_id} introuvable.",
        )
    quantite = _quantite_en_stock(session, produit_id)
    return models.Stock(
        produit_id=produit.id,
        reference=produit.reference,
        nom=produit.nom,
        quantite=quantite,
        seuil_alerte=produit.seuil_alerte,
        alerte=quantite < produit.seuil_alerte,
    )
