package com.m2i.exercice08.services;

import com.m2i.exercice08.dtos.DogRequestPayload;
import com.m2i.exercice08.dtos.DogResponsePayload;
import com.m2i.exercice08.entities.Dog;
import com.m2i.exercice08.exceptions.DogNotFoundException;
import com.m2i.exercice08.repositories.DogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DogServiceImpl implements DogService {
    private final DogRepository dogRepository;

    @Override
    public DogResponsePayload findById(UUID id) {
        return toDto(dogRepository.findById(id).orElseThrow(() -> new DogNotFoundException(id)));
    }

    @Override
    public Collection<DogResponsePayload> findAll() {
        return dogRepository.findAll().stream().map(this::toDto).collect(Collectors.toSet());
    }

    @Override
    public DogResponsePayload create(DogRequestPayload payload) {
        return toDto(dogRepository.save(toEntity(payload)));
    }

    @Override
    public boolean updateById(UUID id, DogRequestPayload payload) {
        Dog found = dogRepository.findById(id).orElseThrow(() -> new DogNotFoundException(id));

        found.setName(payload.name());
        found.setBreed(payload.breed());
        found.setDateOfBirth(payload.dateOfBirth());

        dogRepository.save(found);
        return true;
    }

    @Override
    public boolean deleteById(UUID id) {
        if (!dogRepository.existsById(id)) throw new DogNotFoundException(id);
        dogRepository.deleteById(id);
        return true;
    }

    private Dog toEntity(DogRequestPayload payload) {
        return Dog.builder()
                .name(payload.name())
                .breed(payload.breed())
                .dateOfBirth(payload.dateOfBirth())
                .build();
    }

    private DogResponsePayload toDto(Dog entity) {
        return new DogResponsePayload(entity.getId(), entity.getName(), entity.getBreed(), entity.getDateOfBirth());
    }
}
