package com.utopios.rickandmorty.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record PageInfo(
        Integer count,
        Integer pages,
        String next,
        String prev
) {}
