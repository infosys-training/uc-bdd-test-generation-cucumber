package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
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

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        Map<String, String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(errors);
        }

        PetDTO existing = pets.stream().filter(p -> p.getId().equals(pet.getId())).findFirst().orElse(null);
        if (existing != null) {
            return ResponseEntity.status(409)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "Pet with this ID already exists"));
        }

        if (StringUtils.isBlank(pet.getStatus())) {
            pet.setStatus("available");
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {

        Map<String, String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(errors);
        }

        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setBreed(pet.getBreed());
        currentPet.setAge(pet.getAge());
        currentPet.setStatus(pet.getStatus());
        currentPet.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        pets = pets.stream().filter(p -> !p.getId().equals(id)).collect(Collectors.toList());
        return ResponseEntity.ok().build();
    }

    private Map<String, String> validatePet(PetDTO pet) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.put("name", "Name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.put("species", "Species is required");
        }
        return errors;
    }
}
