package com.utopios.rickandmorty.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ApiPage<T>(
        PageInfo info,
        List<T> results
) {}
