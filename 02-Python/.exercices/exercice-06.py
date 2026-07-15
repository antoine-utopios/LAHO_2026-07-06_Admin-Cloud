from random import randint

mots_disponibles = [
    "ZEBRE",
    "CHIEN",
    "CHAT",
    "RAGONDIN",
    "GIRAFFE",
    "CROCODILE",
    "KOALA",
    "LION",
    "MOUSTIQUE",
    "HAMSTER"
]

index_aleatoire = randint(0, len(mots_disponibles) - 1)
mot_a_trouver = mots_disponibles[index_aleatoire]
nombre_vies = 7
lettres_essayees = set()

def generer_masque():
    mask = ""

    *lettres_du_mots, derniere_lettre = mot_a_trouver

    for lettre in lettres_du_mots:
        if lettre in lettres_essayees:
            mask += f"{lettre} "
        else:
            mask += "_ "

    if derniere_lettre in lettres_essayees:
        mask += f"{derniere_lettre}"
    else:
        mask += "_"

    return mask

while True:
    print(f"Nombre de vies restantes: {nombre_vies}")
    print(f"Lettres déjà essayées: {list(lettres_essayees)}")
    print("")
    print("")
    print(f"Mot à trouver : {generer_masque()}")
    print("")

    if "_" not in generer_masque():
        print("Gagné !")
        break

    choix_utilisateur = input("Quelle lettre voulez_vous essayer? ").upper()
    lettres_essayees.add(choix_utilisateur)

    # if choix_utilisateur not in mot_a_trouver and choix_utilisateur not in lettres_essayees:
    if choix_utilisateur not in mot_a_trouver:
        nombre_vies -= 1

    if nombre_vies < 0:
        print("Perdu !")
        break
