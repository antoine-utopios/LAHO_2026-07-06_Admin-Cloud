import json

bernie_edit = {
  "name": "Réel",
  "age": 6,
  "isSterilized": False,
  "toys": [
    "Ball"
  ]
}

users_list = [
  {
    "username": "jdupont",
    "firstname": "Jane",
    "lastname": "DUPONT"
  },
  {
    "username": "msmith",
    "firstname": "Martha",
    "lastname": "SMITH"
  }
]

try:
  with open("bernie.json", encoding="utf-8", mode="w") as fichier:
    json.dump(bernie_edit, fichier, indent= 2, ensure_ascii=False) # Pour écrire, on va passer par la méthode .dump() en indiquant quel objet écrire, dans quel fichier, une indentation pour le rendre lisible pour un humain, et l'encodage ASCII pour préserver les accents
except FileNotFoundError:
  print("Le fichier bernie.json est introuvable...")

try:
  with open("users.json", encoding="utf-8", mode="w") as fichier:
    json.dump(users_list, fichier, indent= 2)
except FileNotFoundError:
  print("Le fichier users.json est introuvable...")