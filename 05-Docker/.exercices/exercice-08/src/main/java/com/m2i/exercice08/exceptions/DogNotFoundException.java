package com.m2i.exercice08.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.UUID;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class DogNotFoundException extends RuntimeException{
    public DogNotFoundException(UUID id) {
        super(String.format("Dog with id %s not found", id));
    }
}
