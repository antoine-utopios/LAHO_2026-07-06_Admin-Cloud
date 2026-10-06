package com.utopios.rickandmorty.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record Location(
        Long id,
        String name,
        String type,
        String dimension,
        List<String> residents,
        String url,
        String created
) {
    public int residentCount() {
        return residents != null ? residents.size() : 0;
    }
}
