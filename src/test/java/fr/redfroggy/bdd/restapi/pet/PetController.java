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
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "status", required = false) String status) {

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
        List<PetDTO> content = filtered.subList(fromIndex, toIndex);

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

    @PostMapping("/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "name is required");
            return ResponseEntity.badRequest().body(error);
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "species is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);
        if (existing != null) {
            return ResponseEntity.status(409).build();
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "name is required");
            return ResponseEntity.badRequest().body(error);
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "species is required");
            return ResponseEntity.badRequest().body(error);
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

    @PatchMapping("/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody PartialPetDTO pet, @PathVariable String id) {
        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        if (pet.getName() != null) {
            currentPet.setName(pet.getName());
        }
        if (pet.getSpecies() != null) {
            currentPet.setSpecies(pet.getSpecies());
        }
        if (pet.getBreed() != null) {
            currentPet.setBreed(pet.getBreed());
        }
        if (pet.getAge() != null) {
            currentPet.setAge(pet.getAge());
        }
        if (pet.getStatus() != null) {
            currentPet.setStatus(pet.getStatus());
        }

        return ResponseEntity.ok(currentPet);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
