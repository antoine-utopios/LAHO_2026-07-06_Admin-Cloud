package fr.gharrowbm.springapitestingnosecurity.mappers;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class DogMapperTest {

    @Autowired
    private DogMapper dogMapper;

    private Dog dog;

    private DogRequestPayload dogRequestPayload;

    @BeforeEach
    void setUp() {
        dog = Dog.builder()
                .id(UUID.randomUUID())
                .name("Dog")
                .breed("Breed")
                .birthDate(LocalDate.now().minusYears(1))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        dogRequestPayload = new DogRequestPayload();
        dogRequestPayload.setName(dog.getName());
        dogRequestPayload.setBreed(dog.getBreed());
        dogRequestPayload.setBirthDate(dog.getBirthDate());
    }

    @Test
    @DisplayName("Map to Response DTO")
    void toResponse() {
        DogResponsePayload dogResponsePayload = dogMapper.toResponse(dog);

        assertEquals(dog.getId(), dogResponsePayload.getId());
        assertEquals(dog.getName(), dogResponsePayload.getName());
        assertEquals(dog.getBreed(), dogResponsePayload.getBreed());
        assertEquals(dog.getBirthDate(), dogResponsePayload.getBirthDate());
        assertEquals(dog.getCreatedAt(), dogResponsePayload.getCreatedAt());
        assertEquals(dog.getUpdatedAt(), dogResponsePayload.getUpdatedAt());
    }

    @Test
    @DisplayName("Map to Entity")
    void toDog() {
        Dog dog = dogMapper.toDog(dogRequestPayload);

        assertEquals(dog.getName(), dogRequestPayload.getName());
        assertEquals(dog.getBreed(), dogRequestPayload.getBreed());
        assertEquals(dog.getBirthDate(), dogRequestPayload.getBirthDate());
    }
}