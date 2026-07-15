# liste_notes = list()
liste_notes = []

affichage_menu = """
=== PROGRAMME NOTES ===
1. Entrer une nouvelle note
2. Consulter l'ensemble des notes
3. Connaître la plus petite note
4. Connaître la plus grande note
5. Connaître la moyenne des notes
0. Quitter
"""

def ajouter_nouvelle_note():
    nouvelle_note = int(input("Veuillez entrer la nouvelle note: "))
    liste_notes.append(nouvelle_note)
    print("Note ajoutée au listing !")

def consulter_ensemble_notes():
    print(f"Liste de notes: {liste_notes}")

def connaitre_note_minimale():
    note_minimale = liste_notes[0]

    for n in liste_notes[1:]:
        if n < note_minimale:
            note_minimale = n
    
    print(f"Note minimale: {note_minimale}")

def connaitre_note_maximale():
    note_maximale, *le_reste = liste_notes

    for n in le_reste:
        if n > note_maximale:
            note_maximale = n

    print(f"Note maximale: {note_maximale}")

def connaitre_moyenne_notes():
    nombre_elements = max(1, len(liste_notes))

    somme = 0

    for n in liste_notes:
        somme += n

    print(f"Moyenne des notes: {somme / nombre_elements:.2f}")
    

while True:
    print(affichage_menu)
    choix_utilisateur = input("Votre choix: ")

    match choix_utilisateur:
        case "1":
            ajouter_nouvelle_note()
        case "2":
            consulter_ensemble_notes()
        case "3":
            connaitre_note_minimale()
        case "4":
            connaitre_note_maximale()
        case "5":
            connaitre_moyenne_notes()
        case "0":
            break
        case _:
            print("Choix invalide...")