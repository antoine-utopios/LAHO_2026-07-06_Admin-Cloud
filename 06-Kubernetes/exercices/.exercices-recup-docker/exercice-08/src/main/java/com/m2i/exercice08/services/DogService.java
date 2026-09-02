package com.m2i.exercice08.services;

import com.m2i.exercice08.dtos.DogRequestPayload;
import com.m2i.exercice08.dtos.DogResponsePayload;

import java.util.Collection;
import java.util.UUID;

public interface DogService {
    public DogResponsePayload findById(UUID id);
    public Collection<DogResponsePayload> findAll();
    public DogResponsePayload create(DogRequestPayload payload);
    public boolean updateById(UUID id, DogRequestPayload payload);
    public boolean deleteById(UUID id);
}
