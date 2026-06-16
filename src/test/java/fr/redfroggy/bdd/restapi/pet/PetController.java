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
            error.put("field", "name");
            error.put("message", "Name is required");
            return ResponseEntity.badRequest().body(error);
        }

        if (StringUtils.isBlank(pet.getStatus())) {
            Map<String, String> error = new HashMap<>();
            error.put("field", "status");
            error.put("message", "Status is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO existing = pets.stream().filter(p -> p.getId()
                .equals(pet.getId())).findFirst()
                .orElse(null);
        if (existing != null) {
            return ResponseEntity.status(409).build();
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        List<PetDTO> filtered = pets;
        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> pageContent;
        if (fromIndex >= totalElements) {
            pageContent = new ArrayList<>();
        } else {
            pageContent = filtered.subList(fromIndex, toIndex);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("content", pageContent);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", (int) Math.ceil((double) totalElements / size));

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {

        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new HashMap<>();
            error.put("field", "name");
            error.put("message", "Name is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        currentPet.setName(pet.getName());
        currentPet.setStatus(pet.getStatus());
        currentPet.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {

        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream().filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
