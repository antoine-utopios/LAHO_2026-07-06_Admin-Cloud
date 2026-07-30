package com.m2i.exercice08.dtos;

import java.util.Date;

public record DogRequestPayload(String name, String breed, Date dateOfBirth) {
}
