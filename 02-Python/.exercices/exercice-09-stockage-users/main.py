import json
import sys
from pathlib import Path

FICHIER_UTILISATEURS = Path("utilisateurs.json")


def charger_utilisateurs(chemin: Path) -> list[dict]:
    """Lit le fichier JSON et renvoie la liste des utilisateurs.

    Si le fichier n'existe pas encore (premier lancement), on démarre avec
    une liste vide plutôt que de planter — c'est un cas normal, pas une
    erreur.
    """
    if not chemin.exists():
        return []

    try:
        with chemin.open(encoding="utf-8") as fichier:
            return json.load(fichier)
    except json.JSONDecodeError as erreur:
        print(f"Erreur : JSON invalide dans {chemin} : {erreur}", file=sys.stderr)
        sys.exit(1)


def sauvegarder_utilisateurs(utilisateurs: list[dict], chemin: Path) -> None:
    """Écrit la liste des utilisateurs dans le fichier JSON (accents préservés)."""
    with chemin.open("w", encoding="utf-8") as fichier:
        json.dump(utilisateurs, fichier, indent=2, ensure_ascii=False)


def afficher_utilisateurs(utilisateurs: list[dict]) -> None:
    if not utilisateurs:
        print("Aucun utilisateur enregistré pour le moment.")
        return

    for index, utilisateur in enumerate(utilisateurs, start=1):
        adresse = utilisateur["adresse"]
        print(f"\n[{index}] {utilisateur['prenom']} {utilisateur['nom']}")
        print(f"    Né(e) le  : {utilisateur['date_naissance']}")
        print(
            "    Adresse   : "
            f"{adresse['numero']} {adresse['voie']}, "
            f"{adresse['code_postal']} {adresse['commune']}"
        )
        print(f"    Téléphone : {utilisateur['telephone']}")
        print(f"    Email     : {utilisateur['email']}")


def saisir_utilisateur() -> dict:
    """Demande tous les champs d'un utilisateur et renvoie le dictionnaire."""
    print("\n--- Informations personnelles ---")
    nom = input("Nom : ").strip()
    prenom = input("Prénom : ").strip()
    date_naissance = input("Date de naissance (JJ/MM/AAAA) : ").strip()

    print("--- Adresse ---")
    voie = input("Voie : ").strip()
    numero = input("Numéro de voie : ").strip()
    code_postal = input("Code postal : ").strip()
    commune = input("Commune : ").strip()

    telephone = input("Téléphone : ").strip()
    email = input("Email : ").strip()

    return {
        "nom": nom,
        "prenom": prenom,
        "date_naissance": date_naissance,
        "adresse": {
            "voie": voie,
            "numero": numero,
            "code_postal": code_postal,
            "commune": commune,
        },
        "telephone": telephone,
        "email": email,
    }


def ajouter_utilisateur(utilisateurs: list[dict]) -> None:
    utilisateur = saisir_utilisateur()
    utilisateurs.append(utilisateur)
    sauvegarder_utilisateurs(utilisateurs, FICHIER_UTILISATEURS)
    print(f"\n{utilisateur['prenom']} {utilisateur['nom']} ajouté(e) et sauvegardé(e).")


def choisir_utilisateur(utilisateurs: list[dict]) -> int | None:
    """Affiche la liste numérotée et renvoie l'index choisi, ou None."""
    if not utilisateurs:
        print("Aucun utilisateur enregistré.")
        return None

    afficher_utilisateurs(utilisateurs)
    saisie = input("\nNuméro de l'utilisateur concerné : ").strip()
    try:
        index = int(saisie) - 1
    except ValueError:
        print(f"Erreur : '{saisie}' n'est pas un nombre valide.")
        return None

    if not 0 <= index < len(utilisateurs):
        print("Erreur : numéro hors liste.")
        return None
    return index


def modifier_utilisateur(utilisateurs: list[dict]) -> None:
    index = choisir_utilisateur(utilisateurs)
    if index is None:
        return

    print("\nNouvelles informations (laissez vide pour ne pas changer un champ) :")
    utilisateur = utilisateurs[index]

    for champ in ("nom", "prenom", "date_naissance", "telephone", "email"):
        nouvelle_valeur = input(f"{champ} [{utilisateur[champ]}] : ").strip()
        if nouvelle_valeur:
            utilisateur[champ] = nouvelle_valeur

    for champ in ("voie", "numero", "code_postal", "commune"):
        nouvelle_valeur = input(
            f"adresse.{champ} [{utilisateur['adresse'][champ]}] : "
        ).strip()
        if nouvelle_valeur:
            utilisateur["adresse"][champ] = nouvelle_valeur

    sauvegarder_utilisateurs(utilisateurs, FICHIER_UTILISATEURS)
    print("Utilisateur mis à jour et sauvegardé.")


def supprimer_utilisateur(utilisateurs: list[dict]) -> None:
    index = choisir_utilisateur(utilisateurs)
    if index is None:
        return

    utilisateur = utilisateurs.pop(index)
    sauvegarder_utilisateurs(utilisateurs, FICHIER_UTILISATEURS)
    print(f"{utilisateur['prenom']} {utilisateur['nom']} supprimé(e).")


def afficher_menu() -> None:
    print(
        "\n=== GESTION DES UTILISATEURS ===\n"
        "\n"
        "1. Voir les utilisateurs\n"
        "2. Ajouter un utilisateur\n"
        "3. Modifier un utilisateur\n"
        "4. Supprimer un utilisateur\n"
        "0. Quitter\n"
    )


def main() -> None:
    utilisateurs = charger_utilisateurs(FICHIER_UTILISATEURS)

    while True:
        afficher_menu()
        choix = input("Votre choix : ").strip()

        if choix == "1":
            afficher_utilisateurs(utilisateurs)
        elif choix == "2":
            ajouter_utilisateur(utilisateurs)
        elif choix == "3":
            modifier_utilisateur(utilisateurs)
        elif choix == "4":
            supprimer_utilisateur(utilisateurs)
        elif choix == "0":
            print("Au revoir !")
            break
        else:
            print("Choix invalide, merci de choisir une option du menu.")


if __name__ == "__main__":
    main()
