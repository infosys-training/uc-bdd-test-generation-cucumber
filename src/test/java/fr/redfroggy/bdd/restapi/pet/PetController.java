package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public final class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    @GetMapping("/pets")
    public ResponseEntity<List<PetDTO>> getAll(
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "10") int size) {
        int start = page * size;
        if (start >= pets.size()) {
            return ResponseEntity.ok(new ArrayList<>());
        }
        int end = Math.min(start + size, pets.size());
        return ResponseEntity.ok(pets.subList(start, end));
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity
                .ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<PetDTO> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest().build();
        }
        PetDTO existing = pets.stream().filter(p -> p.getId().equals(pet.getId()))
                .findFirst().orElse(null);
        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }
        pets.add(pet);
        return ResponseEntity.status(201).body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id))
                .findFirst().orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }
        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setStatus(pet.getStatus());
            p.setCategory(pet.getCategory());
            p.setTags(pet.getTags());
        });
        return ResponseEntity.ok(pet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> deletePet(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id))
                .findFirst().orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }
        pets = pets.stream().filter(p -> !p.getId().equals(id))
                .collect(Collectors.toList());
        return ResponseEntity.ok().build();
    }
}
