package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @PostMapping(value = "/pets")
    public ResponseEntity<?> createPet(@RequestBody PetDTO pet) {

        List<String> errors = new ArrayList<>();
        if (pet.getName() == null || pet.getName().isBlank()) {
            errors.add("name is required");
        }
        if (pet.getSpecies() == null || pet.getSpecies().isBlank()) {
            errors.add("species is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ValidationErrorDTO("Validation failed", errors));
        }

        if (pet.getStatus() == null || pet.getStatus().isBlank()) {
            pet.setStatus("available");
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> getPet(@PathVariable("id") String id) {
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

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> listPets(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status) {

        List<PetDTO> filtered = pets;
        if (status != null && !status.isBlank()) {
            filtered = pets.stream()
                    .filter(p -> status.equals(p.getStatus()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int start = page * size;
        int end = Math.min(start + size, totalElements);

        List<PetDTO> pageContent;
        if (start >= totalElements) {
            pageContent = Collections.emptyList();
        } else {
            pageContent = filtered.subList(start, end);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("content", pageContent);
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", totalElements);
        result.put("totalPages", totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(result);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        List<String> errors = new ArrayList<>();
        if (pet.getName() == null || pet.getName().isBlank()) {
            errors.add("name is required");
        }
        if (pet.getSpecies() == null || pet.getSpecies().isBlank()) {
            errors.add("species is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ValidationErrorDTO("Validation failed", errors));
        }

        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setBreed(pet.getBreed());
        currentPet.setAge(pet.getAge());
        currentPet.setStatus(pet.getStatus());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets.removeIf(p -> p.getId().equals(id));

        return ResponseEntity.ok().build();
    }
}
