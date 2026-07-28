# ficher = open("test.txt", encoding="utf-8", mode="r")
# fichier.close()

try:
  with open("test.txt", encoding="utf-8", mode="r") as fichier:
    contenu_brut = fichier.read() # Contenu concaténé directement, avec des \n pour les retours à la ligne
    print(contenu_brut)
except FileNotFoundError:
  print("Le fichier test.txt est introuvable...")

try:
  with open("test.txt", encoding="utf-8", mode="r") as fichier:
    contenu_lignes = fichier.readlines() # Contenu en liste de lignes
    print(contenu_lignes)
except FileNotFoundError:
  print("Le fichier test.txt est introuvable...")

try:
  with open("test.txt", encoding="utf-8", mode="r") as fichier:
    ligne_en_court = next(fichier) # Lignes une par une
    print(ligne_en_court)
except FileNotFoundError:
  print("Le fichier test.txt est introuvable...")

try:
  with open("test.txt", encoding="utf-8", mode="r") as fichier:
    for ligne in fichier:
      ligne = ligne.strip() # Retire le \n de la ligne en court d'itération
      print(ligne)
except FileNotFoundError:
  print("Le fichier test.txt est introuvable...")

