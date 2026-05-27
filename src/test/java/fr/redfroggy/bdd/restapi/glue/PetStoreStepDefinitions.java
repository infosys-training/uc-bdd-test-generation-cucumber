package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.After;
import io.cucumber.java.en.Given;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class PetStoreStepDefinitions {

    @Given("the petstore is empty")
    public void thePetstoreIsEmpty() {
        PetController.pets.clear();
        PetController.resetIdGenerator();
    }

    @Given("the petstore contains the following pets:")
    public void thePetstoreContainsPets(DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        for (Map<String, String> row : rows) {
            PetDTO pet = new PetDTO();
            pet.setId(Long.parseLong(row.get("id")));
            pet.setName(row.get("name"));
            pet.setStatus(row.get("status"));
            pet.setCategory(row.get("category"));
            if (row.containsKey("tags") && row.get("tags") != null) {
                pet.setTags(Arrays.asList(row.get("tags").split(",")));
            }
            PetController.pets.add(pet);
        }
    }

    @After("@petstore-cleanup")
    public void cleanupPetstore() {
        PetController.pets.clear();
        PetController.resetIdGenerator();
    }
}
