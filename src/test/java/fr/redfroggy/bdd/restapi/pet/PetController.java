package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @GetMapping("/pets")
    public ResponseEntity<?> getAll(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", required = false) Integer page,
            @RequestParam(value = "size", required = false) Integer size) {

        List<PetDTO> filtered = pets;

        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        if (page != null && size != null) {
            int totalElements = filtered.size();
            int totalPages = (int) Math.ceil((double) totalElements / size);
            int fromIndex = page * size;
            int toIndex = Math.min(fromIndex + size, totalElements);

            List<PetDTO> pageContent;
            if (fromIndex >= totalElements) {
                pageContent = Collections.emptyList();
            } else {
                pageContent = filtered.subList(fromIndex, toIndex);
            }

            PetPageDTO pageDTO = new PetPageDTO(pageContent, page, size, totalElements, totalPages);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(pageDTO);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(filtered);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (pet == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        List<String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            ValidationErrorDTO error = new ValidationErrorDTO("Validation failed", errors);
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(error);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existing != null) {
            return ResponseEntity.status(409)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(existing);
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {

        List<String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            ValidationErrorDTO error = new ValidationErrorDTO("Validation failed", errors);
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(error);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        existing.setName(pet.getName());
        existing.setSpecies(pet.getSpecies());
        existing.setBreed(pet.getBreed());
        existing.setAge(pet.getAge());
        existing.setStatus(pet.getStatus());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(existing);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    private List<String> validatePet(PetDTO pet) {
        List<String> errors = new ArrayList<>();

        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.add("species is required");
        }

        return errors;
    }
}
