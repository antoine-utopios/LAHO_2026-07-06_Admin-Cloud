# Mon Api python


## test en local de l'appli

# partie 1 

je me place dans le repertoire de mon api

- creation d'en env python

```
python3 -m venv venv
```

- entrer dans le venv

```
source venv/Scripts/activate
```

- installation des dependances

```
pip install -r requirements.txt
```


# partie 2

- lancer l'application

```
python app.py
```


- verifier que l'api tourne

```
curl http://localhost:5000
```

# Partie 3

## sur la machine EC2

- transferer mon api python

exemple :

```
scp -i cd-key-exo2.pem api-python.zip ec2-user@35.181.169.147:/home/ec2-user/
```

- installation de python

```
sudo dnf install -y python3 unzip nano
```

- faire l'installation des dependances et venv sur la machine (voir partie 1)

- unzip et rename du dossier

```
unzip api-python.zip
mv api-python mon-api-python
sudo cp mon-api-python/mon-api.service /etc/systemd/system/mon-api.service
```


```
sudo systemctl daemon-reload
sudo systemctl enable mon-api
sudo systemctl start mon-api
sudo systemctl status mon-api
```