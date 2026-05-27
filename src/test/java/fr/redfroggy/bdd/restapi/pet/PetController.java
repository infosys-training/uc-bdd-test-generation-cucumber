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

    public static void reset() {
        pets.clear();
        idCounter.set(1);
    }

    public static PetDTO addPet(PetDTO pet) {
        pet.setId(idCounter.getAndIncrement());
        if (pet.getStatus() == null) {
            pet.setStatus("available");
        }
        pets.add(pet);
        return pet;
    }

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {

        int total = pets.size();
        int start = page * size;
        int end = Math.min(start + size, total);
        List<PetDTO> pageContent = start < total
                ? pets.subList(start, end)
                : Collections.emptyList();

        int totalPages = size > 0 ? (int) Math.ceil((double) total / size) : 0;

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", pageContent);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", total);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") Long id) {
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

    @PostMapping("/pets")
    public ResponseEntity<?> create(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Collections.singletonMap("error", "species is required"));
        }

        pet.setId(idCounter.getAndIncrement());
        if (pet.getStatus() == null) {
            pet.setStatus("available");
        }
        pets.add(pet);

        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> update(@PathVariable("id") Long id, @RequestBody PetDTO pet) {
        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        existing.setName(pet.getName());
        existing.setSpecies(pet.getSpecies());
        existing.setAge(pet.getAge());
        existing.setStatus(pet.getStatus());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(existing);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
