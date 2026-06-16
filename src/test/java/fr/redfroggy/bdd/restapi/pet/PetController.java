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

    private static final List<String> VALID_STATUSES = Arrays.asList("available", "pending", "sold");

    public static List<PetDTO> pets = new ArrayList<>();
    private static final AtomicLong idGenerator = new AtomicLong(1);

    @PostMapping(value = "/pets")
    public ResponseEntity<?> createPet(@RequestBody PetDTO pet) {

        Map<String, String> fieldErrors = validatePet(pet);
        if (!fieldErrors.isEmpty()) {
            return validationErrorResponse(fieldErrors);
        }

        if (pet.getId() == null) {
            pet.setId(idGenerator.getAndIncrement());
        }
        pets.add(pet);

        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
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
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int fromIndex = Math.min(page * size, totalElements);
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> pageContent = filtered.subList(fromIndex, toIndex);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", pageContent);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") Long id) {
        return pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .map(p -> ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                        .body(p))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@PathVariable("id") Long id, @RequestBody PetDTO pet) {

        Map<String, String> fieldErrors = validatePet(pet);
        if (!fieldErrors.isEmpty()) {
            return validationErrorResponse(fieldErrors);
        }

        Optional<PetDTO> existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (!existing.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        PetDTO current = existing.get();
        current.setName(pet.getName());
        current.setStatus(pet.getStatus());
        current.setCategory(pet.getCategory());
        current.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") Long id) {
        Optional<PetDTO> existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (!existing.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    @DeleteMapping(value = "/pets")
    public ResponseEntity<Void> deleteAll() {
        pets.clear();
        idGenerator.set(1);
        return ResponseEntity.ok().build();
    }

    private Map<String, String> validatePet(PetDTO pet) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (pet.getName() == null || pet.getName().trim().isEmpty()) {
            errors.put("name", "Name is required");
        }
        if (pet.getStatus() != null && !VALID_STATUSES.contains(pet.getStatus())) {
            errors.put("status", "Invalid status. Allowed values: available, pending, sold");
        }
        return errors;
    }

    private ResponseEntity<?> validationErrorResponse(Map<String, String> fieldErrors) {
        Map<String, Object> errorResponse = new LinkedHashMap<>();
        errorResponse.put("error", "Validation failed");
        errorResponse.put("fieldErrors", fieldErrors);
        return ResponseEntity.badRequest()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(errorResponse);
    }
}
