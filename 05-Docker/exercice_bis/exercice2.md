
**Exercice : Gestion d'images Docker**

En ligne de commande on souhaite :

1. **Téléchargement d'une image :**
   - Recherchez et téléchargez l'image Docker officielle pour le serveur web Nginx.

   ```bash
   docker search nginx
   docker pull nginx
   ```

2. **Liste d'images :**
   - Affichez la liste des images Docker présentes sur votre machine.

   ```bash
   docker images
   ```

3. **Suppression d'une image :**
   - Supprimez l'image Nginx que vous venez de télécharger de votre machine.

   ```bash
   docker rmi nginx
   ```

4. **Téléchargement de plusieurs images :**
   - Téléchargez les images Docker officielles pour MySQL et Redis sur votre machine.

   ```bash
   docker pull mysql
   docker pull redis
   ```

5. **Liste d'images après téléchargement :**
   - Affichez à nouveau la liste des images Docker sur votre machine pour vérifier que les images de MySQL et Redis ont été téléchargées avec succès.

   ```bash
   docker images
   ```

6. **Affichage détaillé d'une image :**
   - Affichez les détails (metadata) de l'image Mysql que vous avez téléchargée précédemment.

   ```bash
   docker inspect mysql
   ```

7. **Historique d'une image :**
   - Affichez l'historique de l'image MySQL pour voir les différentes couches qui la composent.

   ```bash
   docker history mysql
   ```

8. **Recherche d'images :**
   - Rechercher une image Docker liée à un service ou une technologie de votre choix. Choisissez une image intéressante et affichez quelques informations à son sujet.

   ```bash
   docker search node
   docker pull node
   docker history node
   docker inspect node
   ```

Cet exercice devrait vous permettre de vous familiariser avec la manipulation d'images Docker à un niveau basique. N'hésitez pas à consulter la documentation Docker au besoin.



