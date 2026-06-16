package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class PetstoreStepDefinition {

    private final TestRestTemplate template;

    public PetstoreStepDefinition(TestRestTemplate template) {
        this.template = template;
    }

    @Given("^the petstore is empty$")
    public void clearPetstore() {
        PetController.pets.clear();
    }

    @Given("^the following pets exist:$")
    public void setupPets(DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        PetController.pets.clear();
        for (Map<String, String> row : rows) {
            PetDTO pet = new PetDTO();
            pet.setId(row.get("id"));
            pet.setName(row.get("name"));
            pet.setSpecies(row.get("species"));
            if (row.containsKey("breed")) {
                pet.setBreed(row.get("breed"));
            }
            if (row.containsKey("age")) {
                pet.setAge(Integer.parseInt(row.get("age")));
            }
            pet.setStatus(row.getOrDefault("status", "available"));
            PetController.pets.add(pet);
        }
    }

    @Then("^the petstore should contain (\\d+) pets$")
    public void petstoreShouldContainPets(int count) {
        ResponseEntity<String> response = template.getForEntity("/api/pets", String.class);
        assertThat(response.getStatusCodeValue()).isEqualTo(200);
        assertThat(PetController.pets).hasSize(count);
    }

    @Then("^pet with id (.*) should have status (.*)$")
    public void petShouldHaveStatus(String id, String expectedStatus) {
        PetDTO pet = PetController.pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        assertThat(pet).isNotNull();
        assertThat(pet.getStatus()).isEqualTo(expectedStatus);
    }
}
