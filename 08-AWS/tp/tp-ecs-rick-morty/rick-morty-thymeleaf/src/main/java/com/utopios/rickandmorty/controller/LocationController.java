package com.utopios.rickandmorty.controller;

import com.utopios.rickandmorty.model.ApiPage;
import com.utopios.rickandmorty.model.Character;
import com.utopios.rickandmorty.model.Location;
import com.utopios.rickandmorty.service.RickAndMortyService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/locations")
public class LocationController {

    private final RickAndMortyService service;

    public LocationController(RickAndMortyService service) {
        this.service = service;
    }

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String dimension,
            Model model) {

        ApiPage<Location> result = service.findLocations(page, name, type, dimension);

        StringBuilder qs = new StringBuilder();
        appendParam(qs, "name", name);
        appendParam(qs, "type", type);
        appendParam(qs, "dimension", dimension);

        model.addAttribute("page", page);
        model.addAttribute("result", result);
        model.addAttribute("name", name);
        model.addAttribute("type", type);
        model.addAttribute("dimension", dimension);
        model.addAttribute("queryString", qs.toString());

        return "locations/list";
    }

    private static void appendParam(StringBuilder sb, String key, String value) {
        if (value != null && !value.isBlank()) {
            sb.append('&').append(key).append('=').append(value);
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        Location location = service.findLocationById(id);
        model.addAttribute("location", location);

        // Charge les résidents (max 20) en un seul appel multi-id
        List<Long> residentIds = RickAndMortyService.extractIds(location.residents());
        if (!residentIds.isEmpty()) {
            List<Long> first = residentIds.subList(0, Math.min(20, residentIds.size()));
            List<Character> residents = service.findCharactersByIds(first);
            model.addAttribute("residents", residents);
            model.addAttribute("totalResidents", residentIds.size());
        }

        return "locations/detail";
    }
}
