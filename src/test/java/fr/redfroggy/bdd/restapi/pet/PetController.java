package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    private static final AtomicLong idCounter = new AtomicLong(0);

    @PostMapping("/pets")
    public ResponseEntity<?> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest().body(Map.of("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest().body(Map.of("error", "species is required"));
        }

        if (StringUtils.isBlank(pet.getId())) {
            pet.setId(String.valueOf(idCounter.incrementAndGet()));
        }

        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<?> getPet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (pet == null) {
            return ResponseEntity.status(404).body(Map.of("error", "Pet not found"));
        }

        return ResponseEntity.ok(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> updatePet(@RequestBody PetDTO pet, @PathVariable("id") String id) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest().body(Map.of("error", "name is required"));
        }
        if (StringUtils.isBlank(pet.getSpecies())) {
            return ResponseEntity.badRequest().body(Map.of("error", "species is required"));
        }

        PetDTO currentPet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (currentPet == null) {
            return ResponseEntity.status(404).body(Map.of("error", "Pet not found"));
        }

        currentPet.setName(pet.getName());
        currentPet.setSpecies(pet.getSpecies());
        currentPet.setBreed(pet.getBreed());
        currentPet.setAge(pet.getAge());
        currentPet.setStatus(pet.getStatus());

        return ResponseEntity.ok(currentPet);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<?> deletePet(@PathVariable("id") String id) {
        PetDTO pet = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (pet == null) {
            return ResponseEntity.status(404).body(Map.of("error", "Pet not found"));
        }

        pets = pets.stream()
                .filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }

    @GetMapping("/pets")
    public ResponseEntity<?> listPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content;
        if (fromIndex >= totalElements) {
            content = new ArrayList<>();
        } else {
            content = new ArrayList<>(pets.subList(fromIndex, toIndex));
        }

        Map<String, Object> response = Map.of(
                "content", content,
                "page", page,
                "size", size,
                "totalElements", totalElements,
                "totalPages", totalPages
        );

        return ResponseEntity.ok(response);
    }
}
