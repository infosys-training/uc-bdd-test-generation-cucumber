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
    public ResponseEntity<Object> getAll(
            @RequestParam(value = "page", required = false) Integer page,
            @RequestParam(value = "size", required = false) Integer size) {

        if (page != null && size != null) {
            int fromIndex = page * size;
            int toIndex = Math.min(fromIndex + size, pets.size());
            if (fromIndex > pets.size()) {
                fromIndex = pets.size();
            }
            List<PetDTO> pageContent = pets.subList(fromIndex, toIndex);

            Map<String, Object> pagedResponse = new HashMap<>();
            pagedResponse.put("content", pageContent);
            pagedResponse.put("page", page);
            pagedResponse.put("size", size);
            pagedResponse.put("totalElements", pets.size());
            pagedResponse.put("totalPages", (int) Math.ceil((double) pets.size() / size));

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(pagedResponse);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pets);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> get(@PathVariable("id") String id) {
        PetDTO pet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PostMapping(value = "/pets")
    public ResponseEntity<Object> addPet(@RequestBody PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "Pet name is required");
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(error);
        }

        PetDTO existing = pets.stream().filter(p -> p.getId().equals(pet.getId())).findFirst().orElse(null);
        if (existing != null) {
            return ResponseEntity.badRequest().build();
        }

        pets.add(pet);
        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @PutMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> updatePet(@RequestBody PetDTO pet, @PathVariable String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets.stream().filter(p -> id.equals(p.getId())).forEach(p -> {
            p.setName(pet.getName());
            p.setStatus(pet.getStatus());
            p.setCategory(pet.getCategory());
            p.setTags(pet.getTags());
        });

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @DeleteMapping(value = "/pets/{id}")
    public ResponseEntity<PetDTO> deletePet(@PathVariable("id") String id) {
        PetDTO currentPet = pets.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream().filter(p -> !p.getId().equals(id)).collect(Collectors.toList());

        return ResponseEntity.ok().build();
    }
}
