package fr.gharrowbm.springapitestingnosecurity.repositories;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface DogRepository extends JpaRepository<Dog, UUID> {
}
