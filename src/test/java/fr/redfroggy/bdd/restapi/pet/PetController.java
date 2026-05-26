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

    @GetMapping("/pets")
    public ResponseEntity<?> getAll(
            @RequestParam(value = "page", required = false) Integer page,
            @RequestParam(value = "size", required = false) Integer size) {

        if (page != null && size != null) {
            int fromIndex = page * size;
            int toIndex = Math.min(fromIndex + size, pets.size());
            if (fromIndex >= pets.size()) {
                Map<String, Object> result = new HashMap<>();
                result.put("content", new ArrayList<>());
                result.put("page", page);
                result.put("size", size);
                result.put("totalElements", pets.size());
                result.put("totalPages", (int) Math.ceil((double) pets.size() / size));
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                        .body(result);
            }
            List<PetDTO> pagedPets = pets.subList(fromIndex, toIndex);
            Map<String, Object> result = new HashMap<>();
            result.put("content", pagedPets);
            result.put("page", page);
            result.put("size", size);
            result.put("totalElements", pets.size());
            result.put("totalPages", (int) Math.ceil((double) pets.size() / size));
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(result);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pets);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {

        Map<String, String> errors = new HashMap<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.put("name", "name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.put("species", "species is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest().body(errors);
        }

        PetDTO existing = pets.stream().filter(p -> p.getId()
                .equals(pet.getId())).findFirst()
                .orElse(null);
        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {

        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        Map<String, String> errors = new HashMap<>();
        if (StringUtils.isBlank(pet.getName())) {
            errors.put("name", "name is required");
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            errors.put("species", "species is required");
        }
        if (!errors.isEmpty()) {
            return ResponseEntity.badRequest().body(errors);
        }

        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setSpecies(pet.getSpecies());
            p.setBreed(pet.getBreed());
            p.setAge(pet.getAge());
            p.setStatus(pet.getStatus());
            p.setTags(pet.getTags());
        });

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PatchMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> patchPet(@RequestBody Map<String, Object> updates, @PathVariable String id) {

        PetDTO currentPet = pets.stream().filter(p -> p.getId()
                .equals(id)).findFirst()
                .orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        if (updates.containsKey("status")) {
            currentPet.setStatus((String) updates.get("status"));
        }
        if (updates.containsKey("name")) {
            currentPet.setName((String) updates.get("name"));
        }

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
