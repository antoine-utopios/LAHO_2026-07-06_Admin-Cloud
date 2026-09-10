package fr.gharrowbm.springapitestingnosecurity.payloads;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Data
public class DogRequestPayload {

    @Size(min = 1, max = 100)
    @NotBlank
    private String name;

    @Size(min = 1, max = 100)
    private String breed;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;
}
