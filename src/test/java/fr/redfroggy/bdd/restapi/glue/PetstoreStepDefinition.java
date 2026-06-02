package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class PetstoreStepDefinition {

    @Given("^the petstore is empty$")
    public void thePetstoreIsEmpty() {
        PetController.pets.clear();
    }

    @Given("^the petstore has the following pets:$")
    public void thePetstoreHasTheFollowingPets(List<Map<String, String>> pets) {
        PetController.pets.clear();
        pets.forEach(row -> {
            PetDTO pet = new PetDTO();
            pet.setId(row.get("id"));
            pet.setName(row.get("name"));
            pet.setStatus(row.get("status"));
            if (row.containsKey("category")) {
                pet.setCategory(row.get("category"));
            }
            PetController.pets.add(pet);
        });
    }

    @Then("^the petstore should contain (\\d+) pets$")
    public void thePetstoreShouldContainPets(int count) {
        assertThat(PetController.pets).hasSize(count);
    }

    @Then("^the petstore should be empty$")
    public void thePetstoreShouldBeEmpty() {
        assertThat(PetController.pets).isEmpty();
    }
}
