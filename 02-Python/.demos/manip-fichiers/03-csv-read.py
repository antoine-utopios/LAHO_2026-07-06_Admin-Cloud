import csv

# try:
#   with open("products.csv", encoding="utf-8", mode="r") as fichier:
#     lecteur_csv = csv.reader(fichier)

#     # entete = next(lecteur_csv)
#     # print(entete)

#     next(lecteur_csv)

#     for ligne in lecteur_csv:
#       print(ligne)
# except FileNotFoundError:
#   print("Le fichier products.csv est introuvable...")

try:
  with open("products.csv", encoding="utf-8", mode="r") as fichier:
    lecteur_csv = csv.DictReader(fichier, delimiter=';')

    for ligne in lecteur_csv:
      print(f"L'élément {ligne["name"]} coute {ligne["price"]} euros...")
except FileNotFoundError:
  print("Le fichier products.csv est introuvable...")