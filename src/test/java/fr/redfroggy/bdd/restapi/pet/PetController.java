package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "Pet name is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO existingPet = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existingPet != null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Conflict");
            error.put("message", "Pet with this ID already exists");
            return ResponseEntity.status(409).body(error);
        }

        if (pet.getStatus() == null) {
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
    public ResponseEntity<?> listPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = page * size;

        List<PetDTO> pagedPets;
        if (fromIndex >= totalElements) {
            pagedPets = new ArrayList<>();
        } else {
            int toIndex = Math.min(fromIndex + size, totalElements);
            pagedPets = pets.subList(fromIndex, toIndex);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("content", pagedPets);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {

        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "Pet name is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setStatus(pet.getStatus());
            p.setCategory(pet.getCategory());
            p.setTags(pet.getTags());
        });

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PatchMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody PartialPetDTO pet, @PathVariable("id") String id) {

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        if (pet.getStatus() != null) {
            currentPet.setStatus(pet.getStatus());
        }

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

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
