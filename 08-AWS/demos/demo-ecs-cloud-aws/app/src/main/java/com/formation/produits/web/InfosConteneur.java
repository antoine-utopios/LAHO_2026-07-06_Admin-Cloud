package com.formation.produits.web;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Infos affichées en pied de page : permettent de voir, pendant la démo,
 * quel conteneur (tâche ECS) a répondu et quelle version est déployée.
 */
@ControllerAdvice
public class InfosConteneur {

    @Value("${app.version}")
    private String version;

    @Value("${app.couleur}")
    private String couleur;

    @Value("${app.db-host}")
    private String dbHost;

    @ModelAttribute("version")
    public String version() {
        return version;
    }

    @ModelAttribute("couleur")
    public String couleur() {
        return couleur;
    }

    @ModelAttribute("dbHost")
    public String dbHost() {
        return dbHost;
    }

    @ModelAttribute("conteneur")
    public String conteneur() {
        try {
            InetAddress local = InetAddress.getLocalHost();
            return local.getHostName() + " (" + local.getHostAddress() + ")";
        } catch (UnknownHostException e) {
            return "inconnu";
        }
    }
}
