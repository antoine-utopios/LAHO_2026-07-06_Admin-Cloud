package com.m2i.exercice08.dtos;

import java.util.Date;
import java.util.UUID;

public record DogResponsePayload(UUID id, String name, String breed, Date dateOfBirth) {
}
