package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.*;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();
    private static final AtomicLong idCounter = new AtomicLong(1);

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName()) && StringUtils.isBlank(pet.getSpecies())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "name and species are required");
            return ResponseEntity.badRequest().body(error);
        }
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

        if (pet.getId() != null) {
            boolean exists = pets.stream().anyMatch(p -> p.getId().equals(pet.getId()));
            if (exists) {
                Map<String, String> error = new LinkedHashMap<>();
                error.put("error", "Validation failed");
                error.put("message", "Pet with this ID already exists");
                return ResponseEntity.badRequest().body(error);
            }
        } else {
            pet.setId(idCounter.getAndIncrement());
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping(value = "/pets/{id}")
    public ResponseEntity<?> getPet(@PathVariable("id") Long id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id))
                .findFirst().orElse(null);
        if (pet == null) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Not found");
            error.put("message", "Pet not found");
            return ResponseEntity.status(404).body(error);
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping(value = "/pets")
    public ResponseEntity<?> listPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = (size > 0) ? (int) Math.ceil((double) totalElements / size) : 0;
        int fromIndex = Math.min(page * size, totalElements);
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content = pets.subList(fromIndex, toIndex);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("content", content);
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", totalElements);
        result.put("totalPages", totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(result);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") Long id) {
        if (StringUtils.isBlank(pet.getName()) && StringUtils.isBlank(pet.getSpecies())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "name and species are required");
            return ResponseEntity.badRequest().body(error);
        }
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

        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id))
                .findFirst().orElse(null);
        if (currentPet == null) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Not found");
            error.put("message", "Pet not found");
            return ResponseEntity.status(404).body(error);
        }

        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setStatus(pet.getStatus());
        currentPet.setTag(pet.getTag());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<?> deletePet(@PathVariable("id") Long id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id))
                .findFirst().orElse(null);
        if (pet == null) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Not found");
            error.put("message", "Pet not found");
            return ResponseEntity.status(404).body(error);
        }

        pets = pets.stream().filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
