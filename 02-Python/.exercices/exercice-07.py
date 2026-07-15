from random import randint

vie_joueur = 100
vie_creature = 20
nombre_creature_vaincues = 0
somme_piece_or = 0

def lancer_d20():
    return randint(1, 20)

while True:
    resultat_lancer_joueur = lancer_d20()
    resultat_lancer_creature = lancer_d20()
    print(f"J'attaque la créature ! {resultat_lancer_joueur}")

    vie_creature -= resultat_lancer_joueur

    if vie_creature <= 0:
        nombre_creature_vaincues += 1
        somme_piece_or += 50
        vie_creature = 20

    print(f"La créature nous attaque ! {resultat_lancer_creature}")

    vie_joueur -= resultat_lancer_creature

    if vie_joueur <= 0:
        print("On a perdu !")
        print(f"On a vaincu {nombre_creature_vaincues} créature(s)...")
        print(f"La somme de pièce d'or trouvée sur notre cadavre (après pillage) est de {somme_piece_or / 2:.1f} pièces d'or...")
        break