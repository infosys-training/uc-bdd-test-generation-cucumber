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

    @GetMapping("/pets")
    public ResponseEntity<List<PetDTO>> getAll(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "species", required = false) String species,
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "10") int size) {

        List<PetDTO> filtered = pets;

        if (StringUtils.isNotBlank(status)) {
            filtered = filtered.stream()
                    .filter(p -> status.equalsIgnoreCase(p.getStatus()))
                    .collect(Collectors.toList());
        }

        if (StringUtils.isNotBlank(species)) {
            filtered = filtered.stream()
                    .filter(p -> species.equalsIgnoreCase(p.getSpecies()))
                    .collect(Collectors.toList());
        }

        int total = filtered.size();
        int fromIndex = page * size;
        if (fromIndex >= total) {
            return ResponseEntity.ok()
                    .header("X-Total-Count", String.valueOf(total))
                    .header("X-Page", String.valueOf(page))
                    .header("X-Page-Size", String.valueOf(size))
                    .body(Collections.emptyList());
        }

        int toIndex = Math.min(fromIndex + size, total);
        List<PetDTO> pageResult = filtered.subList(fromIndex, toIndex);

        return ResponseEntity.ok()
                .header("X-Total-Count", String.valueOf(total))
                .header("X-Page", String.valueOf(page))
                .header("X-Page-Size", String.valueOf(size))
                .body(pageResult);
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

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "name is required"));
        }

        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "species is required"));
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existing != null) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "pet with this id already exists"));
        }

        if (pet.getStatus() == null || pet.getStatus().isEmpty()) {
            pet.setStatus("available");
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "name is required"));
        }

        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "species is required"));
        }

        current.setName(pet.getName());
        current.setSpecies(pet.getSpecies());
        current.setBreed(pet.getBreed());
        current.setAge(pet.getAge());
        current.setStatus(pet.getStatus());
        current.setTags(pet.getTags());

        return ResponseEntity.ok(current);
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

        if (pet.getName() != null) {
            current.setName(pet.getName());
        }

        if (pet.getStatus() != null) {
            current.setStatus(pet.getStatus());
        }

        return ResponseEntity.ok(current);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
        PetDTO current = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (current == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
