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

TYPES_DISPONIBLES = {
    "1": ("Chat", Chat),
    "2": ("Chien", Chien),
    "3": ("Rongeur", Rongeur),
    "4": ("Reptile", Reptile),
}

animaux: list[Animal] = []


def afficher_menu() -> None:
    print(
        "\n=== MENU PRINCIPAL ===\n"
        "\n"
        "1. Voir les animaux\n"
        "2. Faire l'inventaire des espèces animales\n"
        "3. Ajouter un animal\n"
        "4. Retirer un animal\n"
        "5. Changer le statut d'adoption d'un animal\n"
        "0. Quitter\n"
    )


def voir_animaux() -> None:
    """Affiche tous les animaux dans un tableau aux colonnes alignées."""
    if not animaux:
        print("Aucun animal enregistré pour le moment.")
        return

    print(f"{'Nom':<15}{'Espèce':<12}{'Âge':>4}         Statut")
    print("-" * 50)
    for animal in animaux:
        print(animal.ligne_tableau())


def inventaire_especes() -> None:
    """Compte les animaux par espèce (motif compteur par dictionnaire)."""
    if not animaux:
        print("Aucun animal enregistré pour le moment.")
        return

    compteur = {}
    for animal in animaux:
        compteur[animal.espece] = compteur.get(animal.espece, 0) + 1

    print("\n--- Inventaire des espèces ---")
    for espece, total in compteur.items():
        print(f"{espece:<12} : {total}")
    print(f"{'Total':<12} : {len(animaux)}")


def demander_type() -> type[Animal] | None:
    """Affiche les types disponibles et renvoie la classe choisie (ou None)."""
    print("\nQuel type d'animal ?")
    for cle, (libelle, _classe) in TYPES_DISPONIBLES.items():
        print(f"  {cle}. {libelle}")

    choix = input("Votre choix : ").strip()
    if choix not in TYPES_DISPONIBLES:
        print("Choix invalide : type d'animal inconnu.")
        return None
    return TYPES_DISPONIBLES[choix][1]


def ajouter_animal() -> None:
    """Crée un animal du type choisi et l'ajoute à la liste."""
    classe_animal = demander_type()
    if classe_animal is None:
        return

    nom = input("Nom de l'animal : ").strip()
    if not nom:
        print("Erreur : le nom ne peut pas être vide.")
        return

    saisie_age = input("Âge (en années) : ").strip()
    try:
        age = int(saisie_age)
    except ValueError:
        print(f"Erreur : '{saisie_age}' n'est pas un nombre entier valide.")
        return

    animaux.append(classe_animal(nom=nom, age=age))
    print(f"{nom} ({classe_animal.espece}) ajouté au refuge.")


def trouver_animal_par_nom(nom: str) -> Animal | None:
    """Renvoie le premier animal portant ce nom (insensible à la casse)."""
    for animal in animaux:
        if animal.nom.lower() == nom.lower():
            return animal
    return None


def retirer_animal() -> None:
    if not animaux:
        print("Aucun animal à retirer.")
        return

    nom = input("Nom de l'animal à retirer : ").strip()
    animal = trouver_animal_par_nom(nom)
    if animal is None:
        print(f"Aucun animal nommé '{nom}' trouvé.")
        return

    animaux.remove(animal)
    print(f"{animal.nom} a été retiré du refuge.")


def changer_statut_adoption() -> None:
    if not animaux:
        print("Aucun animal enregistré.")
        return

    nom = input("Nom de l'animal : ").strip()
    animal = trouver_animal_par_nom(nom)
    if animal is None:
        print(f"Aucun animal nommé '{nom}' trouvé.")
        return

    animal.adopte = not animal.adopte
    nouveau_statut = "adopté" if animal.adopte else "disponible à l'adoption"
    print(f"{animal.nom} est maintenant {nouveau_statut}.")


def main() -> None:
    while True:
        afficher_menu()
        choix = input("Votre choix : ").strip()

        if choix == "1":
            voir_animaux()
        elif choix == "2":
            inventaire_especes()
        elif choix == "3":
            ajouter_animal()
        elif choix == "4":
            retirer_animal()
        elif choix == "5":
            changer_statut_adoption()
        elif choix == "0":
            print("Au revoir !")
            break
        else:
            print("Choix invalide, merci de choisir une option du menu.")


if __name__ == "__main__":
    main()
