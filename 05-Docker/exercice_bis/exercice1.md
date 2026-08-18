**Exercice : Manipulation de Docker avec une image Alpine et GitHub**

**Objectif :** 
Ce exercice vise à évaluer votre compréhension et votre maîtrise des commandes de base de Docker, en particulier sur l'utilisation d'une image Alpine, la récupération d'un dépôt public depuis GitHub, la modification des fichiers dans le container et la copie des résultats sur la machine locale.

**Sujet :**

1. **Prérequis :**
   - Assurez-vous d'avoir Docker installé sur votre machine.
   - Ouvrez un terminal.

2. **Création d'un container Alpine :**
   - Utilisez la commande Docker pour créer un container basé sur l'image Alpine.
   - Connectez-vous au shell du container nouvellement créé.

3. **Récupération d'un dépôt GitHub :**
   - À l'intérieur du container, utilisez la commande `git` pour cloner un dépôt public depuis GitHub (par exemple, https://github.com/votre-utilisateur/exemple-repo.git).
   - Allez dans le répertoire du dépôt cloné.

4. **Modification du contenu :**
   - À l'intérieur du container, ouvrez un fichier texte (par exemple, README.md) à l'aide d'un éditeur de texte disponible dans l'image Alpine.
   - Ajoutez une ligne de texte à votre choix et enregistrez le fichier.

5. **Copie du résultat sur la machine locale :**
   - Depuis votre terminal local, utilisez la commande Docker pour copier le fichier modifié depuis le container vers votre machine locale, dans un répertoire de votre choix.

