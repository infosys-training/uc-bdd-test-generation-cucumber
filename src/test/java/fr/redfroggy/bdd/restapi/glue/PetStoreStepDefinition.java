package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import io.cucumber.java.After;
import io.cucumber.java.Before;

/**
 * Step definitions and hooks for Petstore BDD scenarios.
 * Handles test data lifecycle for @petstore-tagged features.
 */
public class PetStoreStepDefinition {

    @Before("@petstore")
    public void setUp() {
        // Ensure clean state at the start of each petstore feature run
    }

    @After("@petstore")
    public void tearDown() {
        // Clean up is handled by the explicit cleanup scenario in the feature file
        // This hook is available for any additional cleanup if needed
    }
}
