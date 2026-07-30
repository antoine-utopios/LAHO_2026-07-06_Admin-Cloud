# Exercice Docker #5

Via Docker, réaliser le déploiement de deux conteneurs servant à la manipulation de mysql: 

* L'un servira de serveur MySQL,
* L'autre sera utilisé pour se connecter au serveur dans le cadre de l'exercice

Pour cela, vous pouvez très bien utiliser deux fois le même conteneur basé sur une version de mysql, qui possède déjà à la fois le serveur et le client. 

Il faudra également s'assurer que le conteneur du serveur de base de données soit:
* Résilient aux redémarrages
* Résilient à un arret prématuré
* Compatible avec le mécanisme d'auto-scaling

## BONUS

Créer un conteneur ne disposant que du client MySQL et en faire une image pour une utilisation future

---

## Correction

* Création d'un réseau virtuel dans Docker: 

```bash
 docker network create exercice-05
```

* Création d'un conteneur permettant le serveur MySQL:

```bash
docker run -d \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
  -e MYSQL_DATABASE=testDB \
  -e MYSQL_USER=demo \
  -e MYSQL_PASSWORD=password \
  -v exo-05-data:/var/lib/mysql --name exo-05-mysql-server mysql
```

* Création d'un conteneur permettant l'installation de MySQL:

```bash
docker run -it ubuntu

# Dans le conteneur, on va installer les dépendances
apt update && apt install -y mysql-client

# On sort du conteneur
exit

# On sauvegarde l'état du conteneur pour en faire une image future
docker commit id-conteneur ubuntu-mysql

# On fait le ménage...
docker rm id-conteneur
```

* Démarrage du conteneur:

```bash
docker run -it --name exo-05-mysql-client ubuntu-mysql
```

* Connexion des deux conteneurs à notre réseau:

```bash
docker connect exercice-05 exo-05-mysql-server
docker connect exercice-05 exo-05-mysql-client
```

* On entre la commande de connexion dans le conteneur client: 

```bash
mysql -h exo-05-mysql-server -u demo -p 

# Demande du mot de passe...

# On vérifie une fois connecté la présence de la BdD
show databases;
```