package fr.gharrowbm.springapitestingnosecurity.services;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import fr.gharrowbm.springapitestingnosecurity.exceptions.ElementNotFoundException;
import fr.gharrowbm.springapitestingnosecurity.mappers.DogMapper;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import fr.gharrowbm.springapitestingnosecurity.repositories.DogRepository;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentMatchers;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@TestMethodOrder(MethodOrderer.DisplayName.class)
class DogServiceTest {

    @MockitoBean
    private DogMapper dogMapper;

    @MockitoBean
    private DogRepository dogRepository;

    @Autowired
    private DogService service;

    private Dog dog;
    private DogResponsePayload dogResponsePayload;

    @Autowired
    private DogService dogService;

    @BeforeEach
    void setUp() {
        dogResponsePayload = DogResponsePayload
                .builder()
                .id(UUID.randomUUID())
                .name("Dog")
                .breed("Breed")
                .birthDate(LocalDate.now().minusYears(1))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        dog = Dog
                .builder()
                .id(dogResponsePayload.getId())
                .name(dogResponsePayload.getName())
                .breed(dogResponsePayload.getBreed())
                .birthDate(dogResponsePayload.getBirthDate())
                .createdAt(dogResponsePayload.getCreatedAt())
                .updatedAt(dogResponsePayload.getUpdatedAt())
                .build();
    }

    @Test
    @DisplayName("Get Dog by Id")
    void getById() {
        Mockito.when(dogRepository.findById(dogResponsePayload.getId())).thenReturn(Optional.of(dog));
        Mockito.when(dogMapper.toResponse(dog)).thenReturn(dogResponsePayload);

        DogResponsePayload result = service.getById(dogResponsePayload.getId());

        assertEquals(dog.getId(), result.getId());
        assertEquals(dog.getName(), result.getName());
        assertEquals(dog.getBreed(), result.getBreed());
        assertEquals(dog.getBirthDate(), result.getBirthDate());
        assertEquals(dog.getCreatedAt(), result.getCreatedAt());
        assertEquals(dog.getUpdatedAt(), result.getUpdatedAt());
    }

    @Test
    @DisplayName("Get Dog by Id - Not Found")
    void getByIdNotFound() {
        Mockito.when(dogRepository.findById(ArgumentMatchers.any(UUID.class))).thenReturn(Optional.empty());

        assertThrows(ElementNotFoundException.class,  () -> service.getById(UUID.randomUUID()));
    }

    @Test
    @DisplayName("Get all Dogs")
    void getAll() {
        List<Dog> dogsList = List.of(dog);

        Mockito.when(dogRepository.findAll()).thenReturn(dogsList);
        Mockito.when(dogMapper.toResponse(dog)).thenReturn(dogResponsePayload);

        Set<DogResponsePayload> result = service.getAll();

        assertEquals(dogsList.size(), result.size());
        assertEquals(dogsList.iterator().next().getId(), result.iterator().next().getId());
        assertEquals(dogsList.iterator().next().getName(), result.iterator().next().getName());
        assertEquals(dogsList.iterator().next().getBreed(), result.iterator().next().getBreed());
        assertEquals(dogsList.iterator().next().getBirthDate(), result.iterator().next().getBirthDate());
        assertEquals(dogsList.iterator().next().getCreatedAt(), result.iterator().next().getCreatedAt());
        assertEquals(dogsList.iterator().next().getUpdatedAt(), result.iterator().next().getUpdatedAt());
    }

    @Test
    @DisplayName("Add new Dog")
    void save() {
        DogRequestPayload request =  new DogRequestPayload();
        request.setName(dogResponsePayload.getName());
        request.setBreed(dogResponsePayload.getBreed());
        request.setBirthDate(dogResponsePayload.getBirthDate());

        Dog toSave = Dog
                .builder()
                .name(dogResponsePayload.getName())
                .breed(dogResponsePayload.getBreed())
                .birthDate(dogResponsePayload.getBirthDate())
                .build();

        Mockito.when(dogRepository.save(toSave)).thenReturn(dog);
        Mockito.when(dogMapper.toDog(request)).thenReturn(toSave);
        Mockito.when(dogMapper.toResponse(dog)).thenReturn(dogResponsePayload);

        DogResponsePayload result = dogService.save(request);

        assertEquals(dog.getId(), result.getId());
        assertEquals(dog.getName(), result.getName());
        assertEquals(dog.getBreed(), result.getBreed());
        assertEquals(dog.getBirthDate(), result.getBirthDate());
        assertEquals(dog.getCreatedAt(), result.getCreatedAt());
        assertEquals(dog.getUpdatedAt(), result.getUpdatedAt());
    }

    @Test
    @DisplayName("Update Dog by Id")
    void update() {
        DogRequestPayload request =  new DogRequestPayload();
        request.setName("Dog edited");
        request.setBreed(dogResponsePayload.getBreed());
        request.setBirthDate(dogResponsePayload.getBirthDate());

        DogResponsePayload editedDogResponse = DogResponsePayload
                .builder()
                .id(dogResponsePayload.getId())
                .name(request.getName())
                .breed(request.getBreed())
                .birthDate(request.getBirthDate())
                .createdAt(dogResponsePayload.getCreatedAt())
                .updatedAt(dogResponsePayload.getUpdatedAt())
                .build();

        Mockito.when(dogRepository.findById(dog.getId())).thenReturn(Optional.of(dog));
        Mockito.when(dogMapper.toResponse(dog)).thenReturn(editedDogResponse);

        DogResponsePayload result = service.update(dog.getId(), request);

        assertEquals(editedDogResponse.getId(), result.getId());
        assertEquals(editedDogResponse.getName(), result.getName());
        assertEquals(editedDogResponse.getBreed(), result.getBreed());
        assertEquals(editedDogResponse.getBirthDate(), result.getBirthDate());
        assertEquals(editedDogResponse.getCreatedAt(), result.getCreatedAt());
        assertEquals(editedDogResponse.getUpdatedAt(), result.getUpdatedAt());
    }

    @Test
    @DisplayName("Update Dog by Id - Values unchanged")
    void updateNameUnchanged() {
        DogRequestPayload request =  new DogRequestPayload();

        DogResponsePayload editedDogResponse = DogResponsePayload
                .builder()
                .id(dog.getId())
                .name(dog.getName())
                .breed(dog.getBreed())
                .birthDate(dog.getBirthDate())
                .createdAt(dog.getCreatedAt())
                .updatedAt(dog.getUpdatedAt())
                .build();

        Mockito.when(dogRepository.findById(dog.getId())).thenReturn(Optional.of(dog));
        Mockito.when(dogMapper.toResponse(dog)).thenReturn(editedDogResponse);

        DogResponsePayload result = service.update(dog.getId(), request);

        assertEquals(editedDogResponse.getId(), result.getId());
        assertEquals(editedDogResponse.getName(), result.getName());
        assertEquals(editedDogResponse.getBreed(), result.getBreed());
        assertEquals(editedDogResponse.getBirthDate(), result.getBirthDate());
        assertEquals(editedDogResponse.getCreatedAt(), result.getCreatedAt());
        assertEquals(editedDogResponse.getUpdatedAt(), result.getUpdatedAt());
    }

    @Test
    @DisplayName("Update Dog by Id - Not Found")
    void updateNotFound() {
        Mockito.when(dogRepository.findById(ArgumentMatchers.any(UUID.class))).thenReturn(Optional.empty());

        assertThrows(ElementNotFoundException.class, () -> service.update(UUID.randomUUID(), new DogRequestPayload()));
    }

    @Test
    @DisplayName("Delete Dog by Id")
    void deleteById() {
        Mockito.when(dogRepository.existsById(ArgumentMatchers.any(UUID.class))).thenReturn(true);

        assertTrue(service.deleteById(dogResponsePayload.getId()));
    }

    @Test
    @DisplayName("Delete Dog by Id - Not found")
    void deleteByIdNotFound() {
        Mockito.when(dogRepository.existsById(ArgumentMatchers.any(UUID.class))).thenReturn(false);

        assertFalse(service.deleteById(dogResponsePayload.getId()));
    }
}