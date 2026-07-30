package com.m2i.exercice08.controllers;

import com.m2i.exercice08.dtos.DogRequestPayload;
import com.m2i.exercice08.dtos.DogResponsePayload;
import com.m2i.exercice08.services.DogService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.UUID;

@RestController
@RequestMapping("api/v1/dogs")
@RequiredArgsConstructor
public class DogController {
    private final DogService dogService;

    @Value("${server.port}")
    private String serverPort;

    @GetMapping
    public ResponseEntity<HashSet<DogResponsePayload>> findAll() {
        return ResponseEntity.ok(new HashSet<>(dogService.findAll()));
    }

    @GetMapping("{dogId}")
    public ResponseEntity<DogResponsePayload> findById(@PathVariable UUID dogId) {
        return ResponseEntity.ok(dogService.findById(dogId));
    }

    @PostMapping
    public ResponseEntity<DogResponsePayload> create(@RequestBody DogRequestPayload dogRequestPayload) throws URISyntaxException {
        DogResponsePayload dogResponsePayload = dogService.create(dogRequestPayload);

        URI createdLocation = new URI(String.format("http://localhost:%s/api/v1/dogs/%s", serverPort, dogResponsePayload.id()));

        return ResponseEntity.created(createdLocation).build();
    }

    @PutMapping("{dogID}")
    public ResponseEntity<?> updateById(@PathVariable UUID dogID, @RequestBody DogRequestPayload payload) {
        if (dogService.updateById(dogID, payload)) return ResponseEntity.noContent().build();
        return ResponseEntity.badRequest().build();
    }

    @DeleteMapping("{dogID}")
    public ResponseEntity<?> deleteById(@PathVariable UUID dogID) {
        if (dogService.deleteById(dogID)) return ResponseEntity.noContent().build();
        return ResponseEntity.badRequest().build();
    }
}
