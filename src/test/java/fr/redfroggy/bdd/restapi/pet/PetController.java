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

    @GetMapping("/pets")
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size) {

        if (page != null && size != null && size > 0) {
            int start = page * size;
            int end = Math.min(start + size, pets.size());
            List<PetDTO> content = (start < pets.size())
                    ? new ArrayList<>(pets.subList(start, end))
                    : Collections.emptyList();

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("content", content);
            response.put("page", page);
            response.put("size", size);
            response.put("totalElements", pets.size());
            response.put("totalPages", (int) Math.ceil((double) pets.size() / size));

            return ResponseEntity.ok(response);
        }

        return ResponseEntity.ok(pets);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity
                    .notFound().build();
        }

        return ResponseEntity
                .ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("errors", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(pet.getId())).findFirst()
                .orElse(null);
        if (currentPet != null) {
            return ResponseEntity
                    .badRequest()
                    .build();
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity
                    .notFound().build();
        }

        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("errors", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        currentPet.setName(pet.getName());
        currentPet.setStatus(pet.getStatus());
        currentPet.setCategory(pet.getCategory());
        currentPet.setTags(pet.getTags());

        return ResponseEntity
                .ok(currentPet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity
                    .notFound().build();
        }

        pets = pets.stream().filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity
                .ok().build();
    }

    private List<String> validate(PetDTO pet) {
        List<String> errors = new ArrayList<>();
        if (pet.getName() == null || pet.getName().trim().isEmpty()) {
            errors.add("name is required");
        }
        if (pet.getStatus() == null || pet.getStatus().trim().isEmpty()) {
            errors.add("status is required");
        }
        return errors;
    }
}
