package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;

import java.util.ArrayList;
import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;

public class PetStoreStepDefinition {

    @Given("^the pet store is empty$")
    public void thePetStoreIsEmpty() {
        PetController.pets = new ArrayList<>();
    }

    @Given("^the pet store has a pet with id (.*) and name (.*)$")
    public void thePetStoreHasAPet(String id, String name) {
        PetDTO pet = new PetDTO();
        pet.setId(id);
        pet.setName(name);
        pet.setSpecies("dog");
        pet.setStatus("available");
        PetController.pets.add(pet);
    }

    @Given("^the pet store has (\\d+) pets$")
    public void thePetStoreHasNPets(int count) {
        PetController.pets = new ArrayList<>();
        for (int i = 1; i <= count; i++) {
            PetDTO pet = new PetDTO();
            pet.setId(String.valueOf(i));
            pet.setName("Pet-" + i);
            pet.setSpecies(i % 2 == 0 ? "cat" : "dog");
            pet.setBreed("Breed-" + i);
            pet.setAge(i);
            pet.setStatus(i % 3 == 0 ? "pending" : "available");
            pet.setTags(Arrays.asList("tag-" + i));
            PetController.pets.add(pet);
        }
    }

    @Then("^the pet store should contain (\\d+) pets$")
    public void thePetStoreShouldContainNPets(int expectedCount) {
        assertThat(PetController.pets).hasSize(expectedCount);
    }

    @Then("^the pet store should not contain a pet with id (.*)$")
    public void thePetStoreShouldNotContainPetWithId(String id) {
        boolean exists = PetController.pets.stream().anyMatch(p -> p.getId().equals(id));
        assertThat(exists).isFalse();
    }

    @Then("^the pet store should contain a pet with id (.*)$")
    public void thePetStoreShouldContainPetWithId(String id) {
        boolean exists = PetController.pets.stream().anyMatch(p -> p.getId().equals(id));
        assertThat(exists).isTrue();
    }
}
