package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.After;
import io.cucumber.java.en.Given;

import java.util.List;
import java.util.Map;

public class PetstoreStepDefinitions {

    @After("@petstore")
    public void cleanupPetstore() {
        PetController.pets.clear();
    }

    @Given("the petstore is empty")
    public void thePetstoreIsEmpty() {
        PetController.pets.clear();
    }

    @Given("the petstore contains the following pets:")
    public void thePetstoreContainsTheFollowingPets(List<Map<String, String>> rows) {
        for (Map<String, String> row : rows) {
            PetDTO pet = new PetDTO();
            pet.setId(row.get("id"));
            pet.setName(row.get("name"));
            pet.setSpecies(row.get("species"));
            pet.setStatus(row.get("status"));
            if (row.containsKey("age")) {
                pet.setAge(Integer.parseInt(row.get("age")));
            }
            PetController.pets.add(pet);
        }
    }
}
