package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.en.Given;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpMethod;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Petstore-specific step definitions that extend the base BDD framework.
 * These provide domain-level convenience steps for pet CRUD scenarios.
 */
public class PetStoreStepDefinition extends AbstractBddStepDefinition {

    public PetStoreStepDefinition(TestRestTemplate testRestTemplate) {
        super(testRestTemplate);
    }

    @Given("^the pet store is empty$")
    public void thePetStoreIsEmpty() {
        PetController.pets = new ArrayList<>();
    }

    @Given("^the pet store contains a pet named (.*) with status (.*)$")
    public void thePetStoreContainsPet(String name, String status) throws IOException {
        baseUri = "/api/";
        setBody("{\"name\":\"" + name + "\",\"status\":\"" + status + "\"}");
        request("/pets", HttpMethod.POST);
    }

    @Given("^the pet store contains (\\d+) pets$")
    public void thePetStoreContainsNPets(int count) throws IOException {
        PetController.pets = new ArrayList<>();
        baseUri = "/api/";
        String[] categories = {"dog", "cat", "bird", "fish", "hamster"};
        String[] statuses = {"available", "pending", "sold"};
        for (int i = 1; i <= count; i++) {
            String category = categories[(i - 1) % categories.length];
            String petStatus = statuses[(i - 1) % statuses.length];
            setBody("{\"name\":\"Pet-" + String.format("%02d", i)
                    + "\",\"status\":\"" + petStatus
                    + "\",\"category\":\"" + category + "\"}");
            request("/pets", HttpMethod.POST);
        }
    }
}
