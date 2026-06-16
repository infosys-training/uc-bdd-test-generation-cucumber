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
@RequestMapping("/api/pets")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    private static final AtomicLong idGenerator = new AtomicLong(1);

    @PostMapping
    public ResponseEntity<?> createPet(@RequestBody PetDTO pet) {
        Map<String, String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(errors);
        }

        pet.setId(idGenerator.getAndIncrement());
        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getPet(@PathVariable("id") Long id) {
        PetDTO pet = findById(id);
        if (pet == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "Pet not found"));
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping
    public ResponseEntity<?> listPets(
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

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updatePet(@PathVariable("id") Long id, @RequestBody PetDTO pet) {
        PetDTO existing = findById(id);
        if (existing == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "Pet not found"));
        }

        Map<String, String> errors = validatePet(pet);
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(errors);
        }

        existing.setName(pet.getName());
        existing.setStatus(pet.getStatus());
        existing.setCategory(pet.getCategory());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(existing);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePet(@PathVariable("id") Long id) {
        PetDTO existing = findById(id);
        if (existing == null) {
            return ResponseEntity.status(404)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "Pet not found"));
        }

        pets = pets.stream()
                .filter(p -> !id.equals(p.getId()))
                .collect(Collectors.toList());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(Collections.singletonMap("message", "Pet deleted"));
    }

    public static void resetIdGenerator() {
        idGenerator.set(1);
    }

    private PetDTO findById(Long id) {
        return pets.stream()
                .filter(p -> id.equals(p.getId()))
                .findFirst()
                .orElse(null);
    }

    private Map<String, String> validatePet(PetDTO pet) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.put("error", "name is required");
        } else if (StringUtils.isBlank(pet.getStatus())) {
            errors.put("error", "status is required");
        }
        return errors;
    }
}
