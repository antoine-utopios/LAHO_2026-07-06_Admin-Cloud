package fr.gharrowbm.springapitestingnosecurity.payloads;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
public class DogResponsePayload {
    private UUID id;
    private String name;
    private String breed;
    private LocalDate birthDate;
    private Instant createdAt;
    private Instant updatedAt;
}
