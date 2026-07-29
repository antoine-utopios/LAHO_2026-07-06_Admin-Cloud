"""Exercice 8 — e-Kennel : hiérarchie des animaux du refuge.

Une classe de base `Animal` porte tout ce qui est commun (nom, âge, statut
d'adoption, affichage) ; chaque espèce est une sous-classe qui ne fait que
préciser son attribut `espece`. C'est le motif d'héritage le plus simple :
factoriser le comportement commun, spécialiser juste ce qui change.
"""


class Animal:
    """Un animal générique du refuge."""

    espece = "Animal"

    def __init__(self, nom: str, age: int, adopte: bool = False):
        self.nom = nom
        self.age = age
        self.adopte = adopte

    def ligne_tableau(self) -> str:
        """Renvoie une ligne formatée à largeur fixe (colonnes alignées)."""
        statut = "Adopté" if self.adopte else "Disponible"
        return f"{self.nom:<15}{self.espece:<12}{self.age:>4} an(s)   {statut}"

    def __str__(self) -> str:
        return self.ligne_tableau()


class Chat(Animal):
    """Un chat du refuge."""

    espece = "Chat"


class Chien(Animal):
    """Un chien du refuge."""

    espece = "Chien"


class Rongeur(Animal):
    """Un rongeur du refuge (lapin, hamster, cochon d'Inde...)."""

    espece = "Rongeur"


class Reptile(Animal):
    """Un reptile du refuge."""

    espece = "Reptile"


# Registre des types disponibles : sert à construire le bon animal depuis
# le choix (texte) saisi par l'utilisateur dans le menu, sans un gros
# if/elif dans main.py.
TYPES_DISPONIBLES = {
    "1": ("Chat", Chat),
    "2": ("Chien", Chien),
    "3": ("Rongeur", Rongeur),
    "4": ("Reptile", Reptile),
}
