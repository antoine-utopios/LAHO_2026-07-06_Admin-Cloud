# TP — Déployer un serveur web Nginx sur une instance EC2

## Objectif

L'objectif de ce TP est de mettre en pratique les notions vues lors de la démonstration précédente :

* créer une instance Amazon EC2 ;
* rendre cette instance accessible en SSH ;
* se connecter à l'instance depuis un terminal ;
* installer et démarrer Nginx ;
* autoriser l'accès HTTP à l'instance ;
* vérifier que le serveur web est accessible depuis un navigateur.

À la fin du TP, vous devrez pouvoir afficher la page par défaut de Nginx depuis votre poste.

---

## 1. Créer une instance EC2

Depuis la console AWS, créez une nouvelle instance EC2.

Contraintes :

* utilisez une instance de type `t3.micro` ;
* choisissez une image Amazon Linux adaptée ;
* configurez l'instance afin de pouvoir vous y connecter en SSH ;
* assurez-vous que l'instance possède une adresse IPv4 publique ;
* utilisez ou créez une paire de clés permettant la connexion SSH.

Une fois l'instance démarrée, récupérez son **adresse IPv4 publique**.

---

## 2. Se connecter à l'instance en SSH

Depuis votre terminal, connectez-vous à l'instance EC2 en utilisant SSH.

Vous devrez utiliser la clé privée associée à l'instance.

Une fois connecté, vous devez obtenir un terminal distant sur votre machine EC2.

---

## 3. Installer Nginx

Depuis le terminal SSH de votre instance, installez Nginx :

```bash
sudo dnf install nginx -y
```

Démarrez ensuite le service :

```bash
sudo systemctl start nginx
```

Configurez Nginx pour qu'il démarre automatiquement lors du démarrage de l'instance :

```bash
sudo systemctl enable nginx
```

Vérifiez son état :

```bash
sudo systemctl status nginx
```

Vous devez notamment constater :

```text
Active: active (running)
```

---

## 4. Vérifier Nginx depuis l'instance

Avant d'essayer d'accéder au serveur depuis Internet, vérifiez que Nginx fonctionne localement :

```bash
curl http://localhost
```

Vous devez obtenir le contenu HTML de la page d'accueil de Nginx.

---

## 5. Autoriser l'accès HTTP

Pour l'instant, votre instance a été configurée principalement pour permettre la connexion SSH.

Depuis la console AWS :

* retrouvez le **Security Group** associé à votre instance EC2 ;
* ajoutez une règle permettant l'accès HTTP sur le port `80` depuis Internet.

Ne modifiez pas inutilement les autres règles.

---

## 6. Tester le site depuis votre navigateur

Depuis votre poste, ouvrez un navigateur et utilisez l'adresse IPv4 publique de votre instance.

Utilisez explicitement le protocole **HTTP** :

```text
http://ADRESSE_IP_PUBLIQUE
```

Par exemple :

```text
http://15.236.xxx.xxx
```

Attention : n'utilisez pas `https://`.

À ce stade, vous n'avez configuré ni certificat TLS ni serveur HTTPS sur le port `443`.

---


## Validation du TP

Le TP est terminé lorsque vous pouvez confirmer les trois points suivants :

* la connexion SSH à l'instance fonctionne ;
* Nginx est en état `active (running)` ;
* `http://IP_PUBLIQUE` affiche correctement la page **Welcome to nginx!**.


# TP — Suite : déployer un site web sur votre instance EC2

## Objectif

Votre instance EC2 est maintenant accessible en SSH et Nginx fonctionne correctement.

L’objectif de cette deuxième partie est de remplacer la page par défaut de Nginx par un véritable site web fourni sous la forme d’une archive ZIP.

Vous devrez :

* transférer le fichier ZIP depuis votre poste vers l’instance EC2 ;
* décompresser l’archive sur l’instance ;
* placer les fichiers du site dans le répertoire utilisé par Nginx ;
* vérifier que le site est accessible depuis votre navigateur.

---

## 1. Récupérer le site fourni

Un fichier ZIP contenant le site web vous est fourni.

Par exemple :

```text
site-web.zip
```

Ne modifiez pas son contenu pour l’instant.

Votre objectif est d’abord de réussir à le déployer tel quel sur votre instance EC2.

---

## 2. Transférer le fichier ZIP vers l’instance EC2

Depuis votre poste local, utilisez la commande `scp` pour copier le fichier ZIP vers votre instance.

La syntaxe générale est :

```bash
scp -i CHEMIN_VERS_LA_CLE.pem CHEMIN_VERS_LE_FICHIER.zip ec2-user@ADRESSE_IP_PUBLIQUE:/home/ec2-user/
```

Vous devrez adapter cette commande en recherchant vous-même :

* le nom ou le chemin de votre clé privée `.pem` ;
* l’adresse IPv4 publique de votre instance EC2 ;
* le chemin local vers le fichier ZIP fourni.

Une fois la commande exécutée, vérifiez que le fichier est bien présent sur l’instance.

---

## 3. Se connecter à l’instance

Connectez-vous ensuite à votre instance EC2 en SSH.

Une fois connecté, placez-vous dans votre répertoire personnel et vérifiez la présence du fichier ZIP.

Vous pouvez notamment utiliser :

```bash
ls
```

---

## 4. Installer l’outil de décompression

Si la commande `unzip` n’est pas encore disponible, installez-la :

```bash
sudo dnf install unzip -y
```

Décompressez ensuite l’archive.

Exemple de syntaxe :

```bash
unzip NOM_DU_FICHIER.zip
```

Vérifiez le contenu obtenu avec :

```bash
ls
```

ou :

```bash
ls NOM_DU_REPERTOIRE
```

---

## 5. Déployer le site dans Nginx

Le répertoire web utilisé par défaut par Nginx sur cette instance est :

```text
/usr/share/nginx/html
```

Votre objectif est de faire en sorte que les fichiers du site fourni se retrouvent dans ce répertoire.

Avant de copier les nouveaux fichiers, observez éventuellement son contenu :

```bash
ls /usr/share/nginx/html
```

Vous devrez ensuite remplacer le contenu actuel par celui du site fourni.

Attention : ce répertoire appartient au système. Vous devrez donc utiliser `sudo` pour les opérations de suppression ou de copie.

---

## 6. Vérifier le résultat

Une fois les fichiers placés dans :

```text
/usr/share/nginx/html
```

ouvrez votre navigateur depuis votre poste local.

Utilisez l’adresse IPv4 publique de votre instance avec le protocole HTTP :

```text
http://ADRESSE_IP_PUBLIQUE
```

Le site fourni doit maintenant apparaître à la place de la page :

```text
Welcome to nginx!
```

---

