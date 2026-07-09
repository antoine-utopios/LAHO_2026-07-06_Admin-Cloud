# mon_texte = "Je suis du texte"

# nb_caracteres_mon_texte = len(mon_texte)

# mon_texte_majuscule = mon_texte.upper()
# mon_texte_minuscule = mon_texte.lower()

# for lettre in mon_texte:
#     print(lettre)

# septieme_lettre = mon_texte[6]

# lettre_input_maj = input("Saisir une lettre: ").upper()

# if lettre_input_maj in "AEIOUY":
#     print("La lettre " + lettre_input_maj + " est une voyelle !")
# else:
#     print(f"La lettre {lettre_input_maj} est une consomne !")

# print(f"Est ce que le nombre 10 est supérieur à 7 ? {10 > 7}") # Est ce que le nombre 10 est supérieur à 7 ? True

# resultat_ternaire = "OUI" if 10 > 7 else "NON" # OUI

# print(f"Est ce que le nombre 10 est supérieur à 7 ? {'OUI' if 10 > 7 else 'NON'}") # Est ce que le nombre 10 est supérieur à 7 ? OUI

# de_la_2e_lettre_a_la_5e_lettre = mon_texte[1:4]

# a_partir_de_la_5e_lettre = mon_texte[4:]

# jusqua_la_6e_lettre = mon_texte[:5]

# prenom_entree_utilisateur = input("Veuillez entrer notre prénom: ")

# prenom_formate = prenom_entree_utilisateur[0].upper() + prenom_entree_utilisateur[1:].lower()

# fruits_texte = "pomme,abricot,mangue,banane,fraise,kiwi"

# print(f"texte brut: {fruits_texte}")

# ensemble_fruits = fruits_texte.split(',')

# for fruit in ensemble_fruits:
#     print(fruit)

nombre_a_virgule = 3.141592653589793

print(f"Valeur de PI : {nombre_a_virgule:.4f}")

prenom = input("Veuillez entrer votre prénom: ")
nom = input("Veuillez entrer votre nom: ")
age = input("Veuillez entrer votre âge: ")

print(f"{'NOM':<10}|{'PRENOM':<10}|{'AGE':<10}")
print("-"*10 + "†" + "-"*10 + "†" + "-"*10)
print(f"{nom:<10}|{prenom:<10}|{age:<10}")