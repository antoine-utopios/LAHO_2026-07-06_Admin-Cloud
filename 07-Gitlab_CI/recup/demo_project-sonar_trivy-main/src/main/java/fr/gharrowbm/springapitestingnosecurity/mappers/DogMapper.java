package fr.gharrowbm.springapitestingnosecurity.mappers;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import org.springframework.stereotype.Component;

@Component
public class DogMapper {
    public DogResponsePayload toResponse(Dog dog) {
        return DogResponsePayload.builder()
                .id(dog.getId())
                .name(dog.getName())
                .breed(dog.getBreed())
                .birthDate(dog.getBirthDate())
                .createdAt(dog.getCreatedAt())
                .updatedAt(dog.getUpdatedAt())
                .build();
    }

    public Dog toDog(DogRequestPayload dogRequestPayload) {
        return Dog.builder()
                .name(dogRequestPayload.getName())
                .breed(dogRequestPayload.getBreed())
                .birthDate(dogRequestPayload.getBirthDate())
                .build();
    }
}
