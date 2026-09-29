"""StockLine — couche base de données (SQLAlchemy).

Par défaut, l'application utilise une base SQLite locale (fichier
``stockline.db`` dans le répertoire courant) : aucune configuration
n'est nécessaire pour démarrer.

Pour utiliser PostgreSQL (blocs suivants du cursus), définissez la
variable d'environnement DATABASE_URL, par exemple :

    export DATABASE_URL="postgresql+psycopg2://stockline:motdepasse@localhost:5432/stockline"
"""

import os
from datetime import datetime, timezone

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    create_engine,
)
from sqlalchemy.orm import Session, declarative_base, sessionmaker

# 1. URL de connexion : PostgreSQL si DATABASE_URL est définie, sinon SQLite.
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./stockline.db")

# SQLite impose par défaut un accès mono-thread : on assouplit ce réglage
# car FastAPI peut traiter les requêtes dans plusieurs threads.
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

Base = declarative_base()


def maintenant_utc() -> datetime:
    """Horodatage UTC (les serveurs travaillent toujours en UTC)."""
    return datetime.now(timezone.utc)


class ProduitDB(Base):
    """Table des produits référencés dans l'inventaire."""

    __tablename__ = "produits"

    id = Column(Integer, primary_key=True, index=True)
    reference = Column(String(50), unique=True, index=True, nullable=False)
    nom = Column(String(200), nullable=False)
    prix_unitaire = Column(Float, nullable=False)
    seuil_alerte = Column(Integer, nullable=False, default=5)
    cree_le = Column(DateTime, default=maintenant_utc, nullable=False)


class MouvementDB(Base):
    """Table des mouvements de stock (entrées et sorties)."""

    __tablename__ = "mouvements"

    id = Column(Integer, primary_key=True, index=True)
    produit_id = Column(Integer, ForeignKey("produits.id"), nullable=False, index=True)
    type = Column(String(10), nullable=False)  # "entree" ou "sortie"
    quantite = Column(Integer, nullable=False)
    commentaire = Column(String(300), nullable=True)
    cree_le = Column(DateTime, default=maintenant_utc, nullable=False)


def init_db() -> None:
    """Crée les tables si elles n'existent pas (appelé au démarrage)."""
    Base.metadata.create_all(bind=engine)


def get_session():
    """Fournit une session de base de données à chaque requête (dépendance FastAPI)."""
    session: Session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
