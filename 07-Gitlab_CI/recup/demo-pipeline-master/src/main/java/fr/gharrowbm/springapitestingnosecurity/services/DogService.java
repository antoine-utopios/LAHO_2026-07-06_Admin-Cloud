package fr.gharrowbm.springapitestingnosecurity.services;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;

import java.util.Set;
import java.util.UUID;

public interface DogService {
    DogResponsePayload getById(UUID id);
    Set<DogResponsePayload> getAll();
    DogResponsePayload save(DogRequestPayload dog);
    DogResponsePayload update(UUID dogId, DogRequestPayload dog);
    Boolean deleteById(UUID id);
}
