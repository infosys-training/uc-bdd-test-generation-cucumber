package fr.redfroggy.bdd.restapi.glue;

import fr.redfroggy.bdd.restapi.pet.PetController;
import fr.redfroggy.bdd.restapi.pet.PetDTO;
import io.cucumber.java.Before;
import io.cucumber.java.en.Given;

public class PetStoreStepDefinition {

    @Before("@pet")
    public void setUp() {
        PetController.pets.clear();
    }

    @Given("the pet store has a pet with id {string} name {string} and species {string}")
    public void thePetStoreHasPet(String id, String name, String species) {
        PetDTO pet = new PetDTO();
        pet.setId(id);
        pet.setName(name);
        pet.setSpecies(species);
        pet.setStatus("available");
        PetController.pets.add(pet);
    }

    @Given("the pet store has {int} pets")
    public void thePetStoreHasNPets(int count) {
        for (int i = 1; i <= count; i++) {
            PetDTO pet = new PetDTO();
            pet.setId(String.valueOf(i));
            pet.setName("Pet" + i);
            pet.setSpecies(i % 2 == 0 ? "Cat" : "Dog");
            pet.setBreed(i % 2 == 0 ? "Siamese" : "Labrador");
            pet.setAge(i);
            pet.setStatus(i % 3 == 0 ? "sold" : "available");
            PetController.pets.add(pet);
        }
    }
}
