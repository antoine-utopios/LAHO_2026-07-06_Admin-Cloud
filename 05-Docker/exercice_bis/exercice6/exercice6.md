# Exercice dockerfile

On souhaite cree une image docker d'un projet web Github, si vous n'avez pas de repo public contenant un projet web vous pouvez utiliser https://github.com/withaarzoo/3D-Rotate-Tube

- Choisir une image de serveur web nginx

- Cree un dockerfile a partir de cette image qui a la place de sa page par défaut montrera votre projet

- lancer un conteneur à partir de cette image et vérifier le bon fonctionnement

la commande à utiliser à la fin du dockerfile : CMD ["nginx","-g","daemon off;"]
 