package fr.gharrowbm.springapitestingnosecurity.repositories;

import fr.gharrowbm.springapitestingnosecurity.entities.Dog;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@DataJpaTest
class DogRepositoryTest {
    @Autowired
    DogRepository dogRepository;

    @Test
    @DisplayName("Should save a dog and generate an ID")
    void saveDog() {
        Dog dog = Dog.builder()
                .name("Toto")
                .breed("Labrador")
                .birthDate(LocalDate.now().minusYears(2))
                .build();

        Dog saved = dogRepository.saveAndFlush(dog);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getUpdatedAt()).isNotNull();
    }

    @Test
    @DisplayName("Should find a dog by ID")
    void findById() {
        Dog dog = Dog.builder()
                .name("Caramel")
                .breed("Beagle")
                .birthDate(LocalDate.now().minusYears(3))
                .build();

        Dog saved = dogRepository.saveAndFlush(dog);

        Optional<Dog> found = dogRepository.findById(saved.getId());

        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("Caramel");
    }

    @Test
    @DisplayName("Should return all dogs")
    void findAllDogs() {
        Dog dog1 = dogRepository.save(Dog.builder().name("Shoupette").breed("Bulldog").birthDate(LocalDate.now()).build());
        Dog dog2 = dogRepository.save(Dog.builder().name("Rex").breed("Doberman").birthDate(LocalDate.now()).build());

        List<Dog> allDogs = dogRepository.findAll();

        assertThat(allDogs.size()).isEqualTo(2);
        assertThat(allDogs.get(0).getName()).isEqualTo("Shoupette");
        assertThat(allDogs.get(1).getName()).isEqualTo("Rex");
    }

    @Test
    @DisplayName("Should delete a dog")
    void deleteDog() {
        Dog dog = dogRepository.save(Dog.builder().name("Ghost").breed("Husky").birthDate(LocalDate.now()).build());

        dogRepository.delete(dog);

        Optional<Dog> found = dogRepository.findById(dog.getId());

        assertThat(found).isEmpty();
    }

}