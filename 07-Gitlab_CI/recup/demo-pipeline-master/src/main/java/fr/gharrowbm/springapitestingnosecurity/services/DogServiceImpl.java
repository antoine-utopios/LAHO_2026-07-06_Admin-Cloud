package fr.gharrowbm.springapitestingnosecurity.services;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import fr.gharrowbm.springapitestingnosecurity.exceptions.ElementNotFoundException;
import fr.gharrowbm.springapitestingnosecurity.mappers.DogMapper;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import fr.gharrowbm.springapitestingnosecurity.repositories.DogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DogServiceImpl implements DogService {

    private final DogMapper dogMapper;
    private final DogRepository dogRepository;

    @Override
    public DogResponsePayload getById(UUID id) {
        return dogMapper.toResponse(dogRepository.findById(id).orElseThrow(() -> new ElementNotFoundException("Dog", id)));
    }

    @Override
    public Set<DogResponsePayload> getAll() {
        return dogRepository.findAll().stream()
                .map(dogMapper::toResponse)
                .collect(Collectors.toSet());
    }

    @Override
    public DogResponsePayload save(DogRequestPayload dog) {
        return dogMapper.toResponse(dogRepository.save(dogMapper.toDog(dog)));
    }

    @Override
    public DogResponsePayload update(UUID dogId, DogRequestPayload dog) {
        Dog dogFound = dogRepository.findById(dogId).orElseThrow(() -> new ElementNotFoundException("Dog", dogId));

        if (dog.getName() != null) dogFound.setName(dog.getName());
        if (dog.getBreed() != null) dogFound.setBreed(dog.getBreed());
        if (dog.getBirthDate() != null) dogFound.setBirthDate(dog.getBirthDate());

        dogRepository.save(dogFound);

        return dogMapper.toResponse(dogFound);
    }

    @Override
    public Boolean deleteById(UUID id) {
        if (dogRepository.existsById(id)) {
            dogRepository.deleteById(id);
            return true;
        } else return false;
    }
}
