package com.formation.produits.web;

import com.formation.produits.produit.Produit;
import com.formation.produits.produit.ProduitRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/produits")
public class ProduitController {

    private final ProduitRepository repository;

    public ProduitController(ProduitRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public String liste(Model model) {
        model.addAttribute("produits", repository.findAllByOrderByIdAsc());
        return "produits/liste";
    }

    @GetMapping("/nouveau")
    public String nouveau(Model model) {
        model.addAttribute("produit", new Produit());
        return "produits/formulaire";
    }

    @GetMapping("/{id}/modifier")
    public String modifier(@PathVariable Long id, Model model) {
        model.addAttribute("produit", trouver(id));
        return "produits/formulaire";
    }

    @PostMapping
    public String enregistrer(@Valid @ModelAttribute Produit produit, BindingResult result,
                              RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return "produits/formulaire";
        }
        repository.save(produit);
        redirect.addFlashAttribute("message", "Produit « " + produit.getNom() + " » enregistré");
        return "redirect:/produits";
    }

    @PostMapping("/{id}/supprimer")
    public String supprimer(@PathVariable Long id, RedirectAttributes redirect) {
        Produit produit = trouver(id);
        repository.delete(produit);
        redirect.addFlashAttribute("message", "Produit « " + produit.getNom() + " » supprimé");
        return "redirect:/produits";
    }

    private Produit trouver(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Produit introuvable"));
    }
}
