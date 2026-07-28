contenu = [
  "Ligne A",
  "Ligne B",
  "Ligne C",
  "Ligne D",
  "Ligne E"
]

try:
  with open("test.txt", encoding="utf-8", mode="w") as fichier:
    # fichier.writelines(contenu)
    for ligne in contenu:
      # fichier.write(ligne)
      fichier.write(f"{ligne}\n") # On écrit la ligne en ajoutant le retour à la ligne à sa fin
except FileNotFoundError:
  print("Le fichier test.txt est introuvable...")