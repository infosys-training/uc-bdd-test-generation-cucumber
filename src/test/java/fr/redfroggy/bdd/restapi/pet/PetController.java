package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/api")
public class PetController {

    private static final AtomicLong idGenerator = new AtomicLong(1);

    public static List<PetDTO> pets = new ArrayList<>();

    public static void resetIdGenerator() {
        idGenerator.set(1);
    }

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int start = page * size;
        int end = Math.min(start + size, totalElements);

        List<PetDTO> content = (start < totalElements)
                ? new ArrayList<>(pets.subList(start, end))
                : Collections.emptyList();

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", content);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok(response);
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

    @PostMapping("/pets")
    public ResponseEntity<?> create(@RequestBody PetDTO pet) {
        if (pet.getName() == null || pet.getName().trim().isEmpty()) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "name is required");
            return ResponseEntity.badRequest().body(error);
        }

        pet.setId(idGenerator.getAndIncrement());
        pets.add(pet);

        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> update(@PathVariable("id") Long id, @RequestBody PetDTO pet) {
        if (pet.getName() == null || pet.getName().trim().isEmpty()) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "name is required");
            return ResponseEntity.badRequest().body(error);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        existing.setName(pet.getName());
        existing.setStatus(pet.getStatus());
        existing.setCategory(pet.getCategory());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok(existing);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        boolean removed = pets.removeIf(p -> p.getId().equals(id));
        if (removed) {
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
