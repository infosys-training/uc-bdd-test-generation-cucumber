package fr.redfroggy.bdd.restapi.pet;

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
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", required = false) Integer page,
            @RequestParam(value = "size", required = false) Integer size) {

        List<PetDTO> filtered = pets;

        if (StringUtils.isNotBlank(status)) {
            filtered = pets.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        int totalElements = filtered.size();

        if (page != null && size != null && size > 0) {
            int fromIndex = page * size;
            int toIndex = Math.min(fromIndex + size, totalElements);
            int totalPages = (int) Math.ceil((double) totalElements / size);

            List<PetDTO> pageContent = (fromIndex >= totalElements)
                    ? Collections.emptyList()
                    : filtered.subList(fromIndex, toIndex);

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("content", pageContent);
            response.put("page", page);
            response.put("size", size);
            response.put("totalElements", totalElements);
            response.put("totalPages", totalPages);

            return ResponseEntity.ok(response);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("content", filtered);
        response.put("totalElements", totalElements);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (pet == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<Object> addPet(@RequestBody PetDTO pet) {

        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            errors.add("status is required");
        }
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("error", "Validation failed");
            errorResponse.put("messages", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<Object> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {

        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        List<String> errors = new ArrayList<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.add("name is required");
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            errors.add("status is required");
        }
        if (!errors.isEmpty()) {
            Map<String, Object> errorResponse = new LinkedHashMap<>();
            errorResponse.put("error", "Validation failed");
            errorResponse.put("messages", errors);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setStatus(pet.getStatus());
            p.setCategory(pet.getCategory());
            p.setTags(pet.getTags());
        });

        return ResponseEntity.ok(pet);
    }

    @PatchMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody PartialPetDTO pet, @PathVariable String id) {

        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        if (StringUtils.isNotBlank(pet.getStatus())) {
            current.setStatus(pet.getStatus());
        }

        return ResponseEntity.ok(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> deletePet(@PathVariable("id") String id) {

        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !current.equals(p))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
