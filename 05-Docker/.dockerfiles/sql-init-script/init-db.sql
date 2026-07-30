CREATE DATABASE testDB;

USE testDB;

CREATE TABLE test_table (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    test_text VARCHAR(100) NOT NULL
);

INSERT INTO test_table (test_text) VALUES ("Toto"), ("Tata"), ("Tutu");