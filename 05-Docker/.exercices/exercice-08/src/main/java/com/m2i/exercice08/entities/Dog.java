package com.m2i.exercice08.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "dogs")
@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Dog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    @Column(name = "dog_id")
    private UUID id;

    @Column(name = "dog_name", length = 100, nullable = false)
    private String name;

    @Column(name = "dog_breed", length = 100)
    private String breed;

    @Column(name = "dog_dob")
    private Date dateOfBirth;
}
