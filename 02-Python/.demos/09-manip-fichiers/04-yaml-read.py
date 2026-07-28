import yaml

try:
  with open("users.yaml", encoding="utf-8", mode="r") as fichier:
    donnees = yaml.safe_load(fichier)
    
except FileNotFoundError:
  print("Le fichier users.yaml est introuvable...")