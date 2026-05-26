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
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size) {

        List<PetDTO> filtered = pets;

        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        if (page != null && size != null && size > 0) {
            int totalElements = filtered.size();
            int totalPages = (int) Math.ceil((double) totalElements / size);
            int start = page * size;
            int end = Math.min(start + size, totalElements);
            List<PetDTO> content = start < totalElements
                    ? filtered.subList(start, end)
                    : Collections.emptyList();

            Map<String, Object> paginated = new LinkedHashMap<>();
            paginated.put("content", content);
            paginated.put("page", page);
            paginated.put("size", size);
            paginated.put("totalElements", totalElements);
            paginated.put("totalPages", totalPages);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(paginated);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(filtered);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<?> get(@PathVariable("id") String id) {
        PetDTO pet = findById(id);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("message", "name is required"));
        }

        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("message", "species is required"));
        }

        PetDTO existing = findById(pet.getId());
        if (existing != null) {
            return ResponseEntity.status(409)
                    .body(Collections.singletonMap("message", "pet already exists"));
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        PetDTO current = findById(id);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        current.setName(pet.getName());
        current.setSpecies(pet.getSpecies());
        current.setBreed(pet.getBreed());
        current.setAge(pet.getAge());
        current.setStatus(pet.getStatus());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(current);
    }

    @PatchMapping(value = "/pets/{id}")
    public ResponseEntity<?> patchPet(@RequestBody PetDTO updates, @PathVariable String id) {
        PetDTO current = findById(id);
        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        if (updates.getName() != null) {
            current.setName(updates.getName());
        }
        if (updates.getSpecies() != null) {
            current.setSpecies(updates.getSpecies());
        }
        if (updates.getBreed() != null) {
            current.setBreed(updates.getBreed());
        }
        if (updates.getAge() != 0) {
            current.setAge(updates.getAge());
        }
        if (updates.getStatus() != null) {
            current.setStatus(updates.getStatus());
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<?> deletePet(@PathVariable("id") String id) {
        PetDTO pet = findById(id);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !id.equals(p.getId()))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    private PetDTO findById(String id) {
        return pets.stream()
                .filter(p -> id.equals(p.getId()))
                .findFirst()
                .orElse(null);
    }
}
