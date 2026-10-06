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
@RequestMapping("/episodes")
public class EpisodeController {

    private final RickAndMortyService service;

    public EpisodeController(RickAndMortyService service) {
        this.service = service;
    }

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(required = false) String name,
            @RequestParam(required = false, name = "episode") String episodeCode,
            Model model) {

        ApiPage<Episode> result = service.findEpisodes(page, name, episodeCode);

        StringBuilder qs = new StringBuilder();
        appendParam(qs, "name", name);
        appendParam(qs, "episode", episodeCode);

        model.addAttribute("page", page);
        model.addAttribute("result", result);
        model.addAttribute("name", name);
        model.addAttribute("episodeCode", episodeCode);
        model.addAttribute("queryString", qs.toString());

        return "episodes/list";
    }

    private static void appendParam(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append('&').append(key).append('=').append(value);
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Episode episode = service.findEpisodeById(id);
        model.addAttribute("episode", episode);

        // Charge les personnages de l'épisode (max 20) en un seul appel
        List<Long> characterIds = RickAndMortyService.extractIds(episode.characters());
        if (!characterIds.isEmpty()) {
            List<Long> first = characterIds.subList(0, Math.min(20, characterIds.size()));
            List<Character> characters = service.findCharactersByIds(first);
            model.addAttribute("characters", characters);
            model.addAttribute("totalCharacters", characterIds.size());
        }

        return "episodes/detail";
    }
}
