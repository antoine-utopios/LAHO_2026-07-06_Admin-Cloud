# Exercice Docker #4

Réaliser, via Docker, le déploiement de deux conteneurs pouvant communiquer entre eux: 

* Pour cela, vous créerez dans un premier temps un réseau qui sera utilisé par les deux conteneurs
* Vous créerez ensuite un conteneur sur lequel vous devrez installer la commande servant à la réalisation du ping
* Sauvegardez ensuite l'image issue de cette installation pour pouvoir créer un second conteneur directement pourvu de ping
* Vérifier / connecter les deux conteneurs au même réseau virtuel
* Dans chacun des conteneur, vérifier la capacité de communiquer avec son voisin via le nom du conteneur (tester la résolution DNS interne à Docker)

---

## Correction

* Pour cela, vous créerez dans un premier temps un réseau qui sera utilisé par les deux conteneurs

```bash
docker network create exercice-04
```

* Vous créerez ensuite un conteneur sur lequel vous devrez installer la commande servant à la réalisation du ping

```bash
# On lance le conteneur A (conteneur ubuntu) 
docker run -it --name exo-04-ubuntu-a ubuntu

# Dedans, on y installe les bonnes dépendances
apt update && apt install -y iputils-ping
```

* Sauvegardez ensuite l'image issue de cette installation pour pouvoir créer un second conteneur directement pourvu de ping

```bash
# On créé l'image pour sauvegarder une version d'ubuntu avec ping pré-installé
docker commit exo-04-ubuntu-a ubuntu-ping 

# On s'en sert pour lancer un nouveau conteneur et ne pas avoir à refaire l'installation une seconde fois
docker run -ti --name exo-04-ubuntu-b ubuntu-ping
```

* Vérifier / connecter les deux conteneurs au même réseau virtuel

```bash
# Connecter les conteneurs au réseau virtuel
docker network connect exercice-04 exo-04-ubuntu-a
docker network connect exercice-04 exo-04-ubuntu-b

# Vérifier leur état de connexion
docker inspect exo-04-ubuntu-a
docker inspect exo-04-ubuntu-b
```

* Dans chacun des conteneurs, vérifier la capacité de communiquer avec son voisin via le nom du conteneur (tester la résolution DNS interne à Docker)

```bash
# Dans le conteneur A
ping exo-04-ubuntu-b

# Dans le conteneur B
ping exo-04-ubuntu-a
```