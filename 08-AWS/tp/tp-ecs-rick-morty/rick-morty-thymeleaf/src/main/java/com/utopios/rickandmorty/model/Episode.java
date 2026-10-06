package com.utopios.rickandmorty.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record Episode(
        Long id,
        String name,
        @JsonProperty("air_date") String airDate,
        String episode,
        List<String> characters,
        String url,
        String created
) {
    public int characterCount() {
        return characters != null ? characters.size() : 0;
    }
}
