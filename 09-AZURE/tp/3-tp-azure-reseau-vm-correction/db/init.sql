-- Exécuté automatiquement par l'image mysql au premier démarrage (volume vide)
CREATE TABLE IF NOT EXISTS tasks (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    title      VARCHAR(255) NOT NULL,
    done       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, done) VALUES
    ('Créer le VNet et les 3 sous-réseaux', TRUE),
    ('Configurer les NSG', FALSE),
    ('Déployer les conteneurs sur les VM', FALSE);
