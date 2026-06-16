package fr.redfroggy.bdd.restapi.petstore;

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
    public PetPageDTO getAll(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, pets.size());

        List<PetDTO> pageContent;
        if (fromIndex >= pets.size()) {
            pageContent = Collections.emptyList();
        } else {
            pageContent = new ArrayList<>(pets.subList(fromIndex, toIndex));
        }

        PetPageDTO pageDTO = new PetPageDTO();
        pageDTO.setContent(pageContent);
        pageDTO.setPage(page);
        pageDTO.setSize(size);
        pageDTO.setTotalElements(pets.size());
        pageDTO.setTotalPages((int) Math.ceil((double) pets.size() / size));

        return pageDTO;
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

        return ResponseEntity
                .ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping("/pets")
    public ResponseEntity<Object> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            return ResponseEntity.badRequest()
                    .body(Collections.singletonMap("error", "name is required"));
        }

        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(pet.getId()))
                .findFirst()
                .orElse(null);

        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<PetDTO> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        PetDTO existing = pets.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        existing.setName(pet.getName());
        existing.setCategory(pet.getCategory());
        existing.setStatus(pet.getStatus());
        existing.setTags(pet.getTags());

        return ResponseEntity.ok(existing);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") String id) {
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
