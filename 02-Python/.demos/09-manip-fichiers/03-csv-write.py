import csv

products = [
  {
    "id": 1,
    "name": "Banane",
    "price": 0.95,
    "category": "Fruit",
    "stock": 500
  },
  {
    "id": 2,
    "name": "iPhone",
    "price": 1299.95,
    "category": "Electronics",
    "stock": 50
  },
]

try:
  with open("products.csv", encoding="utf-8", mode="w") as fichier:
    writer_csv = csv.DictWriter(fichier, fieldnames=["id", "name", "price", "category", "stock"], delimiter=';', lineterminator="\n")

    writer_csv.writeheader()
    writer_csv.writerows(products)

except FileNotFoundError:
  print("Le fichier products.csv est introuvable...")