package com.utopios.rickandmorty.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record Character(
        Long id,
        String name,
        String status,
        String species,
        String type,
        String gender,
        OriginRef origin,
        LocationRef location,
        String image,
        List<String> episode,
        String url,
        String created
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record OriginRef(String name, String url) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record LocationRef(String name, String url) {}

    /**
     * Extrait l'ID de location depuis l'URL si elle existe.
     * URL format: https://rickandmortyapi.com/api/location/3
     */
    public Long locationId() {
        return extractIdFromUrl(location != null ? location.url() : null);
    }

    public Long originId() {
        return extractIdFromUrl(origin != null ? origin.url() : null);
    }

    private static Long extractIdFromUrl(String url) {
        if (url == null || url.isBlank()) return null;
        try {
            String[] parts = url.split("/");
            return Long.parseLong(parts[parts.length - 1]);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public int episodeCount() {
        return episode != null ? episode.size() : 0;
    }
}
