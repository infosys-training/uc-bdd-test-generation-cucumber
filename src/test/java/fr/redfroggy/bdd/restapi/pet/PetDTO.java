package fr.redfroggy.bdd.restapi.pet;

public final class PetDTO extends PartialPetDTO {

    private String id;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}
