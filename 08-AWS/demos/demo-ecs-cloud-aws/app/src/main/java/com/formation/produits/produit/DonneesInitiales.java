package com.formation.produits.produit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

/** Insère quelques produits au premier démarrage (table vide). */
@Component
public class DonneesInitiales implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DonneesInitiales.class);

    private final ProduitRepository repository;

    public DonneesInitiales(ProduitRepository repository) {
        this.repository = repository;
    }

    @Override
    public void run(String... args) {
        if (repository.count() > 0) {
            return;
        }
        repository.saveAll(List.of(
                new Produit("Clavier mécanique", "Switches rouges, rétroéclairé", new BigDecimal("89.90"), 15),
                new Produit("Souris sans fil", "Capteur 16000 DPI", new BigDecimal("39.50"), 42),
                new Produit("Écran 27 pouces", "QHD 165 Hz", new BigDecimal("279.00"), 7)));
        log.info("Base vide : 3 produits de démonstration insérés");
    }
}
