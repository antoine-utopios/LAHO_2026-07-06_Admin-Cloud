# Exercice Docker #3


Réaliser le déploiement d'un site web customisé via Docker: 

* Ce site web doit être desservi via le serveur web NGINX
* Ce site web doit avoir une page d'accueil personnalisée (contenant par exemple un message du style "Hello World" ou "Exercice 03")
* Le site web doit être accessible dans l'ordinateur hôte via une adresse telle que http://localhost:8080 (par exemple)
 
---

## Correction

* Ce site web doit être desservi via le serveur web NGINX

```bash
docker run -d -p 8090:80 --name nginx nginx:alpine 
```

* Ce site web doit avoir une page d'accueil personnalisée (contenant par exemple un message du style "Hello World" ou "Exercice 03")


```bash
docker exec -it nginx sh


# On entre dans le conteneur, les commandes suivantes de font donc directement depuis ce dernier
echo "<h1>Exercice 03</h1>" > /usr/share/nginx/html/index.html 
```

* Le site web doit être accessible dans l'ordinateur hôte via une adresse telle que http://localhost:8080 (par exemple)

```bash
# Pour vérifier le contenu du fichier
cat /usr/share/nginx/html/index.html 

# Pour vérifier via un appel HTTP local
curl localhost

# Ensuite, on part du conteneur via la commande d'arret
exit

# En dehors du conteneur, on peut ouvrir notre navigateur et naviguer vers http://localhost:8090, sinon, via une commande
curl http://localhost:8090
```