import json

class User:
  username: str
  firstname: str
  lastname: str

  def __init__(self, username, firstname, lastname):
    self.username = username 
    self.firstname = firstname 
    self.lastname = lastname 

  def __str__(self):
    return f"USER | Username: {self.username}, Firstname: {self.firstname}, Lastname: {self.lastname}"

users_list = [
  User("toto", "Toto", "DUPONT")
]

try:
  with open("bernie.json", encoding="utf-8", mode="r") as fichier:
    donnees_exploitables = json.load(fichier) # Pour exploiter les données dans un format compréhensible pour le Python, on va le charger avec .load()
    print(type(donnees_exploitables))
    print(donnees_exploitables["age"])

    print(type(donnees_exploitables["toys"]))
    for toy in donnees_exploitables["toys"]:
      print(toy)
except FileNotFoundError:
  print("Le fichier bernie.json est introuvable...")

try:
  with open("users.json", encoding="utf-8", mode="r") as fichier:
    users = json.load(fichier)

    for user in users:
      user_obj = User(user['username'],user['firstname'],user['lastname'])
      users_list.append(user_obj)

    for user in users_list:
      print(user)
except FileNotFoundError:
  print("Le fichier users.json est introuvable...")