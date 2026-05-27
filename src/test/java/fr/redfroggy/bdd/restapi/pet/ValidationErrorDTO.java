package fr.redfroggy.bdd.restapi.pet;

import java.util.List;

public class ValidationErrorDTO {

    private String message;

    private List<String> errors;

    public ValidationErrorDTO() {
    }

    public ValidationErrorDTO(String message, List<String> errors) {
        this.message = message;
        this.errors = errors;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<String> getErrors() {
        return errors;
    }

    public void setErrors(List<String> errors) {
        this.errors = errors;
    }
}
