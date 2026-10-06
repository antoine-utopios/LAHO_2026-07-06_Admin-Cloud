package com.utopios.rickandmorty.controller;

import com.utopios.rickandmorty.model.ApiPage;
import com.utopios.rickandmorty.model.Character;
import com.utopios.rickandmorty.model.Episode;
import com.utopios.rickandmorty.service.RickAndMortyService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/characters")
public class CharacterController {

    private final RickAndMortyService service;

    public CharacterController(RickAndMortyService service) {
        this.service = service;
    }

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String species,
            @RequestParam(required = false) String gender,
            @RequestParam(required = false) String type,
            Model model) {

        ApiPage<Character> result = service.findCharacters(page, name, status, species, gender, type);

        StringBuilder qs = new StringBuilder();
        appendParam(qs, "name", name);
        appendParam(qs, "status", status);
        appendParam(qs, "species", species);
        appendParam(qs, "gender", gender);
        appendParam(qs, "type", type);

        model.addAttribute("page", page);
        model.addAttribute("result", result);
        model.addAttribute("name", name);
        model.addAttribute("status", status);
        model.addAttribute("species", species);
        model.addAttribute("gender", gender);
        model.addAttribute("type", type);
        model.addAttribute("queryString", qs.toString());
        model.addAttribute("statuses", List.of("alive", "dead", "unknown"));
        model.addAttribute("genders", List.of("female", "male", "genderless", "unknown"));

        return "characters/list";
    }

    private static void appendParam(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append('&').append(key).append('=').append(value);
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Character character = service.findCharacterById(id);
        model.addAttribute("character", character);

        // On charge les 5 premiers épisodes du personnage
        List<Long> episodeIds = RickAndMortyService.extractIds(character.episode());
        if (!episodeIds.isEmpty()) {
            List<Long> firstFive = episodeIds.subList(0, Math.min(5, episodeIds.size()));
            List<Episode> episodes = firstFive.stream()
                    .map(service::findEpisodeById)
                    .toList();
            model.addAttribute("episodes", episodes);
        }

        return "characters/detail";
    }
}
