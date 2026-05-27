package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;

import static org.assertj.core.api.Assertions.assertThat;

public class PetStepDefinitions {

    @Given("the petstore is empty")
    public void thePetstoreIsEmpty() {
        PetController.reset();
    }

    @Given("^the petstore has a pet named (.*) of species (.*)$")
    public void addPetToStore(String name, String species) {
        PetDTO pet = new PetDTO();
        pet.setName(name);
        pet.setSpecies(species);
        pet.setStatus("available");
        PetController.addPet(pet);
    }

    @Then("^the total pet count should be (\\d+)$")
    public void verifyPetCount(int expectedCount) {
        assertThat(PetController.pets).hasSize(expectedCount);
    }
}
