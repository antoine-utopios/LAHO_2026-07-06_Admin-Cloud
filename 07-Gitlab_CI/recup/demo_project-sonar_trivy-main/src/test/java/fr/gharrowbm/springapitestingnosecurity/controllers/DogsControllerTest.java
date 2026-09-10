package fr.gharrowbm.springapitestingnosecurity.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import fr.gharrowbm.springapitestingnosecurity.exceptions.ElementNotFoundException;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import fr.gharrowbm.springapitestingnosecurity.services.DogService;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DogsController.class)
@TestMethodOrder(MethodOrderer.DisplayName.class)
class DogsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DogService dogService;

    private static String asJsonString(final Object obj) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            return mapper.writeValueAsString(obj);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    @DisplayName("Get all dogs")
    void getDogs() throws Exception {
        mockMvc.perform(get("/api/v1/dogs").contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Get dog by ID")
    void getDogById() throws Exception {
        DogResponsePayload toto = DogResponsePayload
                .builder()
                .id(UUID.randomUUID())
                .name("Toto")
                .breed("Labrador")
                .birthDate(LocalDate.now())
                .build();

        when(dogService.getById(toto.getId())).thenReturn(toto);

        mockMvc.perform(get("/api/v1/dogs/{id}", toto.getId())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.name").value(toto.getName()))
                .andExpect(jsonPath("$.breed").value(toto.getBreed()));
    }

    @Test
    @DisplayName("Get dog by ID not found")
    void getDogByName() throws Exception {
        when(dogService.getById(any(UUID.class))).thenThrow(ElementNotFoundException.class);

        mockMvc.perform(get("/api/v1/dogs/{id}", UUID.randomUUID())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Add new Dog")
    void addNewDog() throws Exception {
        DogRequestPayload request = new DogRequestPayload();
        request.setName("Toto");
        request.setBreed("Labrador");
        request.setBirthDate(LocalDate.now().minusYears(1));

        DogResponsePayload response = DogResponsePayload
                .builder()
                .id(UUID.randomUUID())
                .name(request.getName())
                .breed(request.getBreed())
                .birthDate(request.getBirthDate())
                .build();

        when(dogService.save(any(DogRequestPayload.class))).thenReturn(response);

        mockMvc.perform(post("/api/v1/dogs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(request)))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", Matchers.endsWith("/api/v1/dogs/" + response.getId())));
    }

    @Test
    @DisplayName("Add new Dog - Invalid Request Payload")
    void addNewDogInvalidPayload() throws Exception {
        DogRequestPayload request = new DogRequestPayload();

        mockMvc.perform(post("/api/v1/dogs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(asJsonString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Edit dog")
    void editDog() throws Exception {
        DogRequestPayload request = new DogRequestPayload();
        request.setName("Toto edited");
        request.setBreed("Labrador");
        request.setBirthDate(LocalDate.now().minusYears(1));

        DogResponsePayload response = DogResponsePayload
                .builder()
                .id(UUID.randomUUID())
                .name(request.getName())
                .breed(request.getBreed())
                .birthDate(request.getBirthDate())
                .build();

        when(dogService.update(response.getId(), request)).thenReturn(response);

        mockMvc.perform(patch("/api/v1/dogs/{id}", response.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(request)))
                .andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("Edit dog - Not Found")
    void editDogNotFound() throws Exception {
        DogRequestPayload request = new DogRequestPayload();
        request.setName("Toto edited");
        request.setBreed("Labrador");
        request.setBirthDate(LocalDate.now().minusYears(1));

        when(dogService.update(any(UUID.class), eq(request))).thenThrow(ElementNotFoundException.class);

        mockMvc.perform(patch("/api/v1/dogs/{id}", UUID.randomUUID())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(asJsonString(request)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Edit dog - Invalid Payload")
    void editDogInvalidPayload() throws Exception {
        DogRequestPayload request = new DogRequestPayload();

        mockMvc.perform(patch("/api/v1/dogs/{id}", UUID.randomUUID())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(asJsonString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Delete Dog by Id")
    void deleteDogById() throws Exception {
        when(dogService.deleteById(any(UUID.class))).thenReturn(true);

        mockMvc.perform(delete("/api/v1/dogs/{id}", UUID.randomUUID()))
                .andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("Delete Dog by Id - Not Found")
    void deleteDogByIdNotFound() throws Exception {
        when(dogService.deleteById(any(UUID.class))).thenThrow(ElementNotFoundException.class);

        mockMvc.perform(delete("/api/v1/dogs/{id}", UUID.randomUUID()))
                .andExpect(status().isNotFound());
    }
}