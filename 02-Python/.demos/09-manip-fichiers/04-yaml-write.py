import yaml

bernie_edit = {
  "name": "Réel",
  "age": 6,
  "isSterilized": False,
  "toys": [
    "Ball"
  ]
}

try:
  with open("users.yaml", encoding="utf-8", mode="w") as fichier:
    yaml.safe_dump(bernie_edit, fichier, allow_unicode=True, sort_keys=True)
    
except FileNotFoundError:
  print("Le fichier users.yaml est introuvable...")