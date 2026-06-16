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
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "10") int size) {

        List<PetDTO> filtered = pets;
        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = Math.min(page * size, totalElements);
        int toIndex = Math.min(fromIndex + size, totalElements);
        List<PetDTO> pageContent = filtered.subList(fromIndex, toIndex);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", pageContent);
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
    public ResponseEntity<Object> addPet(@RequestBody PetDTO pet) {
        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.add("species is required");
        }
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
            return ResponseEntity.badRequest().build();
        }

        if (pet.getStatus() == null) {
            pet.setStatus("available");
        }
        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<Object> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.add("species is required");
        }
        if (!errors.isEmpty()) {
            Map<String, Object> errorBody = new LinkedHashMap<>();
            errorBody.put("error", "Validation failed");
            errorBody.put("messages", errors);
            return ResponseEntity.badRequest().body(errorBody);
        }

        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setSpecies(pet.getSpecies());
            p.setBreed(pet.getBreed());
            p.setAge(pet.getAge());
            p.setStatus(pet.getStatus());
            p.setTags(pet.getTags());
        });

        return ResponseEntity.ok(pet);
    }

    @PatchMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody PartialPetDTO pet, @PathVariable String id) {
        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        if (pet.getName() != null) {
            current.setName(pet.getName());
        }
        if (pet.getStatus() != null) {
            current.setStatus(pet.getStatus());
        }

        return ResponseEntity.ok(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> deletePet(@PathVariable("id") String id) {
        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !current.equals(p))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
