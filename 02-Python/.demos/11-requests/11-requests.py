import requests, sys

try:
  # GET - Récupérer des données
  url = "https://jsonplaceholder.typicode.com/posts/"
  response = requests.get(url)
  if response.status_code == 200:
    data = response.json()
    for element in data: 
      print(element['title'])

  # POST - Ajouter des données
  # url = "https://jsonplaceholder.typicode.com/posts/"

  # fake_post = {
  #   "userId": 10,
  #   "title": "Toto",
  #   "body": "Faux texte"
  # }

  # response = requests.post(url, fake_post)
  # if response.status_code == 201:
  #   data = response.json()
  #   print(data)


  # PUT - Ajouter des données
  # url = "https://jsonplaceholder.typicode.com/posts/"

  # fake_post = {
  #   "userId": 10,
  #   "title": "Toto",
  #   "body": "Faux texte"
  # }

  # response = requests.post(url, fake_post)
  # if response.status_code == 201:
  #   data = response.json()
  #   print(data)

  # PUT - Modifier des données
  # url = "https://jsonplaceholder.typicode.com/posts/"

  # fake_post = {
  #   "id": 10,
  #   "userId": 10,
  # }

  # response = requests.post(url, fake_post)
  # if response.status_code == 201:
  #   data = response.json()
  #   print(data)

  # PATCH - Modifier des données
  # url = "https://jsonplaceholder.typicode.com/posts/10"

  # fake_post = {
  #   "userId": 9
  # }

  # response = requests.post(url, fake_post)
  # if response.status_code == 201:
  #   data = response.json()
  #   print(data)
      
  # DELETE - Supprimer des données
  # url = "https://jsonplaceholder.typicode.com/posts/22"
  # response = requests.delete(url)
  # if response.status_code == 200:
  #   print(response.json())

except requests.exceptions.RequestException as error:
  print(f"Erreur réseau: {error}", file=sys.stderr)