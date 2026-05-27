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

    @PostMapping("/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest().body(Map.of("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest().body(Map.of("error", "species is required"));
        }
        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
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
        return ResponseEntity.ok(pet);
    }

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAllPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "status", required = false) String status) {

        List<PetDTO> filtered = pets;
        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equals(p.getStatus()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content;
        if (fromIndex >= totalElements) {
            content = Collections.emptyList();
        } else {
            content = filtered.subList(fromIndex, toIndex);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("content", content);
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", totalElements);
        result.put("totalPages", totalPages);

        return ResponseEntity.ok(result);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {
        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest().body(Map.of("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest().body(Map.of("error", "species is required"));
        }
        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setBreed(pet.getBreed());
        currentPet.setAge(pet.getAge());
        currentPet.setStatus(pet.getStatus());
        currentPet.setTags(pet.getTags());
        return ResponseEntity.ok(currentPet);
    }

    @PatchMapping("/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody Map<String, Object> updates, @PathVariable("id") String id) {
        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }
        if (updates.containsKey("name")) {
            currentPet.setName((String) updates.get("name"));
        }
        if (updates.containsKey("species")) {
            currentPet.setSpecies((String) updates.get("species"));
        }
        if (updates.containsKey("breed")) {
            currentPet.setBreed((String) updates.get("breed"));
        }
        if (updates.containsKey("age")) {
            currentPet.setAge(((Number) updates.get("age")).intValue());
        }
        if (updates.containsKey("status")) {
            currentPet.setStatus((String) updates.get("status"));
        }
        if (updates.containsKey("tags")) {
            @SuppressWarnings("unchecked")
            List<String> tags = (List<String>) updates.get("tags");
            currentPet.setTags(tags);
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
