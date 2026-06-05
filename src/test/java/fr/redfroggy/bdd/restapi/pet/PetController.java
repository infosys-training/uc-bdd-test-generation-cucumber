package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content;
        if (fromIndex >= totalElements) {
            content = Collections.emptyList();
        } else {
            content = pets.subList(fromIndex, toIndex);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", content);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok(response);
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
        return ResponseEntity.ok(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("errors", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);
        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("errors", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        current.setName(pet.getName());
        current.setStatus(pet.getStatus());
        current.setTags(pet.getTags());

        return ResponseEntity.ok(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    private List<String> validate(PetDTO pet) {
        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            errors.add("status is required");
        }
        return errors;
    }
}
