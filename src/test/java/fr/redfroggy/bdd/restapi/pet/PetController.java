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

    @GetMapping("/pets")
    public ResponseEntity<Map<String, Object>> getAll(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content = fromIndex >= totalElements
                ? Collections.emptyList()
                : new ArrayList<>(pets.subList(fromIndex, toIndex));

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", content);
        response.put("page", page);
        response.put("size", size);
        response.put("totalElements", totalElements);
        response.put("totalPages", totalPages);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        return pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/pets")
    public ResponseEntity<?> create(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "species is required"));
        }

        boolean exists = pets.stream().anyMatch(p -> p.getId().equals(pet.getId()));
        if (exists) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "pet with this ID already exists"));
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> update(@PathVariable("id") String id, @RequestBody PetDTO pet) {
        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        existing.setName(pet.getName());
        existing.setSpecies(pet.getSpecies());
        existing.setStatus(pet.getStatus());
        existing.setAge(pet.getAge());

        return ResponseEntity.ok(existing);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") String id) {
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
