# Commandes Git - Cheastsheet

## Création d'un dépot Git

```bash
git init
```

## Ajout de fichiers à la Staging Area

```bash
# Fichier par fichier
git add nom-fichier.extension

# Multiples fichiers
git add nom-fichierA.extension nom-fichierB.extension ...

# Répertoire courant et son contenu
git add .
```

## Sauvegarde la Staging Area dans un Commit

```bash
# Va demander un message par la suite...
git commit

# Ajout du message directement
git commit -m "Contenu du message"

# Ajout à la staging area des fichiers indéxés et de leur modification directement durant le commit
git commit -a
```

## Vérifier le statut actuel de notre working directory et le comparer à l'historique Git

```bash
git status
```

## Obtenir l'historique de nos commits de façon chronologique inversée (du plus récent au plus ancien)

```bash
git log
```

## Déplacement de la tête de visionnage dans l'historique des commits

```bash
git checkout <id-commit>
```

## Déplacement de la tête de visionnage sur une branche spéficique

```bash
git switch <nom-branche>
```

## Déplacement de la branche sur un commit spécifique

```bash
# Va conserver les fichiers et modifications de la staging area...
git reset --soft <id-commit>

# Va conserver les fichiers mais pas les modifications de la staging area...
git reset <id-commit>
git reset --mixed <id-commit>

# Va supprimer les fichiers de la staging area et du working directory...
git reset --hard <id-commit>

# Syntaxe différente via l'utilisation de référence
# X est ici le nombre de commits en arrière...
git reset HEAD~X
```

## Listing des branches

```bash
git branch
```

## Création d'une nouvelle branche

```bash
git branche <branch-name>
git branche <branch-name> <branche-ref | commit-ref> 
```

## Récupération des commits d'une branche annexe

```bash
git merge <branch-name>
```

## Déplacement de l'origine de notre branche vers un autre commit / une autre branche

```bash
git rebase <commit-id | branch-name>
```