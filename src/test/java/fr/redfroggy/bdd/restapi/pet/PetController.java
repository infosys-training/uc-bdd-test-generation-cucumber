package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @GetMapping("/pets")
    public ResponseEntity<?> getAll(
            @RequestParam(value = "page", required = false) Integer page,
            @RequestParam(value = "size", required = false) Integer size) {

        if (page != null && size != null) {
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
            response.put("totalElements", totalElements);
            response.put("totalPages", totalPages);
            response.put("page", page);
            response.put("size", size);

            return ResponseEntity.ok(response);
        }

        return ResponseEntity.ok(pets);
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

    @PostMapping("/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorBody = new LinkedHashMap<>();
            errorBody.put("error", "Validation failed");
            errorBody.put("messages", errors);
            return ResponseEntity.badRequest().body(errorBody);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existing != null) {
            Map<String, Object> errorBody = new LinkedHashMap<>();
            errorBody.put("error", "Validation failed");
            errorBody.put("messages", Collections.singletonList("Pet with id " + pet.getId() + " already exists"));
            return ResponseEntity.badRequest().body(errorBody);
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {
        List<String> errors = validate(pet);
        if (!errors.isEmpty()) {
            Map<String, Object> errorBody = new LinkedHashMap<>();
            errorBody.put("error", "Validation failed");
            errorBody.put("messages", errors);
            return ResponseEntity.badRequest().body(errorBody);
        }

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setBreed(pet.getBreed());
        currentPet.setAge(pet.getAge());
        currentPet.setStatus(pet.getStatus());

        return ResponseEntity.ok(currentPet);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (pet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.equals(pet))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    private List<String> validate(PetDTO pet) {
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
