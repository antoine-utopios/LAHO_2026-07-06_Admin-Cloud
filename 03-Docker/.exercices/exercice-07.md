# Exercice Docker #7

Via Docker, créer un conteneur de base de données (de type MySQL) possédant déjà plusieurs tables et données à son lancement.
* Ce conteneur devra être initialisé via un script de type sql contenant l'initialisation de la base de données
* Ce conteneur devra être instancié via une image construite par vos soins

Concernant le contenu de la base de données, celle-ci devra se nommer kennelDB et comporter:
* Des clients (nom, prénom, date de naissance, pseudonymme)
* Des adresses (numéro, rue, code postal, commune)
* Des associations clients-adresses
* Des chiens (nom, date de naissance, race, statut de stérilisation)
* Des chats (nom, date de naissance, race, statut de stérilisation)

---

## Correction 

* Ecrire le script d'initialisation de la base de données:

```sql
CREATE DATABASE IF NOT EXISTS kennelDB;

USE kennelDB;

CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS clients_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    breed VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    sterilized BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS cats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    breed VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    sterilized BOOLEAN NOT NULL
);

INSERT INTO clients (first_name, last_name, date_of_birth, username) VALUES
('John', 'Doe', '1985-06-15', 'johndoe'),
('Jane', 'Smith', '1990-08-22', 'janesmith'),
('Alice', 'Johnson', '1982-12-01', 'alicej');

INSERT INTO addresses (street, city, state, zip_code) VALUES
('123 Main St', 'Springfield', 'IL', '62701'),
('456 Elm St', 'Shelbyville', 'IL', '62565'),
('789 Oak St', 'Capital City', 'IL', '62704');

INSERT INTO clients_addresses (client_id, address_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO dogs (name, breed, date_of_birth, sterilized) VALUES
('Buddy', 'Golden Retriever', '2015-05-20', TRUE),
('Max', 'Beagle', '2018-03-15', FALSE),
('Bella', 'Bulldog', '2016-07-30', TRUE);

INSERT INTO cats (name, breed, date_of_birth, sterilized) VALUES
('Whiskers', 'Siamese', '2017-02-10', TRUE),
('Mittens', 'Persian', '2019-11-05', FALSE),
('Shadow', 'Maine Coon', '2018-08-25', TRUE); 
```

* Ecrire le fichier `Dockerfile` placé à la racine d'un dossier où se trouve le sous-dossier `init-scripts` (qui doit contenir notre fichier `.sql`):

```dockerfile
FROM mysql:9

COPY ./init-scripts/* /docker-entrypoint-initdb.d/

EXPOSE 3306
EXPOSE 33060
```

* Créer une image de conteneur via la commande: 

```bash
docker build -t exercice-07 .
```

* Lancer un conteneur à partir de notre image:

```bash
docker run -d --name exercice-07 -p 3306:3306 --rm -e MYSQL_ROOT_PASSWORD=password exercice-07
```