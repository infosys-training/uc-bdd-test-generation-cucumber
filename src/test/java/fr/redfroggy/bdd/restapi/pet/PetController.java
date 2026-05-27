package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "species", required = false) String species) {

        List<PetDTO> filtered = new ArrayList<>(pets);
        if (status != null && !status.isEmpty()) {
            filtered = filtered.stream()
                    .filter(p -> status.equals(p.getStatus()))
                    .collect(Collectors.toList());
        }
        if (species != null && !species.isEmpty()) {
            filtered = filtered.stream()
                    .filter(p -> species.equals(p.getSpecies()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int fromIndex = Math.min(page * size, totalElements);
        int toIndex = Math.min(fromIndex + size, totalElements);
        List<PetDTO> content = filtered.subList(fromIndex, toIndex);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", content);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);
        response.put("page", page);
        response.put("size", size);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<?> get(@PathVariable("id") String id) {
        return pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> notFound(id));
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> create(@RequestBody PetDTO pet) {
        String validationError = validate(pet);
        if (validationError != null) {
            return badRequest(validationError);
        }

        boolean exists = pets.stream().anyMatch(p -> p.getId().equals(pet.getId()));
        if (exists) {
            return conflict(pet.getId());
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> update(@RequestBody PetDTO pet, @PathVariable("id") String id) {
        String validationError = validate(pet);
        if (validationError != null) {
            return badRequest(validationError);
        }

        Optional<PetDTO> existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (existing.isEmpty()) {
            return notFound(id);
        }

        PetDTO current = existing.get();
        current.setName(pet.getName());
        current.setSpecies(pet.getSpecies());
        current.setBreed(pet.getBreed());
        current.setAge(pet.getAge());
        current.setStatus(pet.getStatus());
        current.setTags(pet.getTags());

        return ResponseEntity.ok(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<?> delete(@PathVariable("id") String id) {
        Optional<PetDTO> existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (existing.isEmpty()) {
            return notFound(id);
        }

        pets.removeIf(p -> p.getId().equals(id));
        return ResponseEntity.ok().build();
    }

    private String validate(PetDTO pet) {
        if (pet.getName() == null || pet.getName().isEmpty()) {
            return "Name is required";
        }
        if (pet.getSpecies() == null || pet.getSpecies().isEmpty()) {
            return "Species is required";
        }
        return null;
    }

    private ResponseEntity<Map<String, String>> badRequest(String message) {
        Map<String, String> error = new LinkedHashMap<>();
        error.put("error", "Validation failed");
        error.put("message", message);
        return ResponseEntity.badRequest().body(error);
    }

    private ResponseEntity<Map<String, String>> notFound(String id) {
        Map<String, String> error = new LinkedHashMap<>();
        error.put("error", "Not found");
        error.put("message", "Pet with id " + id + " not found");
        return ResponseEntity.status(404).body(error);
    }

    private ResponseEntity<Map<String, String>> conflict(String id) {
        Map<String, String> error = new LinkedHashMap<>();
        error.put("error", "Conflict");
        error.put("message", "Pet with id " + id + " already exists");
        return ResponseEntity.status(409).body(error);
    }
}
