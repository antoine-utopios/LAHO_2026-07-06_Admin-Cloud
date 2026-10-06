package com.utopios.rickandmorty.controller;

import com.utopios.rickandmorty.model.ApiPage;
import com.utopios.rickandmorty.model.Character;
import com.utopios.rickandmorty.service.RickAndMortyService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/debug")
public class DebugController {

    private final RickAndMortyService service;

    public DebugController(RickAndMortyService service) {
        this.service = service;
    }

    @GetMapping("/characters")
    public Map<String, Object> debugCharacters() {
        try {
            ApiPage<Character> result = service.findCharacters(1, null, null, null, null, null);
            return Map.of(
                    "ok", true,
                    "count", result.info() != null ? result.info().count() : -1,
                    "pages", result.info() != null ? result.info().pages() : -1,
                    "resultsSize", result.results() != null ? result.results().size() : -1,
                    "firstName", result.results() != null && !result.results().isEmpty()
                            ? result.results().get(0).name() : "EMPTY"
            );
        } catch (Exception e) {
            return Map.of(
                    "ok", false,
                    "error", e.getClass().getSimpleName(),
                    "message", e.getMessage() != null ? e.getMessage() : "no message",
                    "cause", e.getCause() != null ? e.getCause().toString() : "none"
            );
        }
    }
}
