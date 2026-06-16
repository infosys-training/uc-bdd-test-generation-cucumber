package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            errors.add("status is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(400, "Validation failed", errors));
        }

        PetDTO existing = pets.stream().filter(p -> p.getId().equals(pet.getId())).findFirst().orElse(null);
        if (existing != null) {
            return ResponseEntity.status(409)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(409, "Pet already exists", Collections.singletonList("Pet with id " + pet.getId() + " already exists")));
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<?> getPet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(404, "Not found", Collections.singletonList("Pet with id " + id + " not found")));
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {

        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            errors.add("status is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(400, "Validation failed", errors));
        }

        PetDTO existing = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (existing == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(404, "Not found", Collections.singletonList("Pet with id " + id + " not found")));
        }

        existing.setName(pet.getName());
        existing.setStatus(pet.getStatus());
        existing.setCategory(pet.getCategory());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(existing);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<?> deletePet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(new ErrorDTO(404, "Not found", Collections.singletonList("Pet with id " + id + " not found")));
        }

        pets = pets.stream().filter(p -> !p.getId().equals(id)).collect(Collectors.toList());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    @GetMapping("/pets")
    public ResponseEntity<?> listPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "status", required = false) String status) {

        List<PetDTO> filtered = pets;
        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream().filter(p -> status.equals(p.getStatus())).collect(Collectors.toList());
        }

        int totalElements = filtered.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> pageContent = (fromIndex >= totalElements)
                ? Collections.emptyList()
                : filtered.subList(fromIndex, toIndex);

        PetPageDTO pageDTO = new PetPageDTO(pageContent, page, size, totalElements, totalPages);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pageDTO);
    }
}
