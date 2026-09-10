package fr.gharrowbm.springapitestingnosecurity.controllers;

import fr.gharrowbm.springapitestingnosecurity.payloads.DogRequestPayload;
import fr.gharrowbm.springapitestingnosecurity.payloads.DogResponsePayload;
import fr.gharrowbm.springapitestingnosecurity.services.DogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.Set;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/v1/dogs")
public class DogsController {

    private final DogService dogService;

    @GetMapping
    public ResponseEntity<Set<DogResponsePayload>>  getDogs() {
        Set<DogResponsePayload> dogs = dogService.getAll();

        return ResponseEntity.ok(dogs);
    }

    @GetMapping("{id}")
    public ResponseEntity<DogResponsePayload> getDogById(@PathVariable UUID id) {
        DogResponsePayload dog = dogService.getById(id);

        return ResponseEntity.ok(dog);
    }

    @PostMapping
    public ResponseEntity<Void> save(@RequestBody @Valid DogRequestPayload dogRequestPayload) {
        UUID newId = dogService.save(dogRequestPayload).getId();

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(newId)
                .toUri();

        return ResponseEntity.created(location).build();
    }

    @PatchMapping("{id}")
    public ResponseEntity<Void> update(@PathVariable UUID id, @RequestBody @Valid DogRequestPayload dogRequestPayload) {
        dogService.update(id, dogRequestPayload);

        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        dogService.deleteById(id);

        return ResponseEntity.noContent().build();
    }
}
