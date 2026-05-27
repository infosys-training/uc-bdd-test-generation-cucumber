package fr.redfroggy.bdd.restapi.pet;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import wiremock.org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class PetController {

    public static List<PetDTO> pets = new ArrayList<>();

    private static final AtomicLong idCounter = new AtomicLong(1);

    @PostMapping(value = "/pets")
    public ResponseEntity<?> createPet(@RequestBody PetDTO pet) {
        Map<String, String> error = validatePet(pet);
        if (error != null) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(error);
        }

        pet.setId(idCounter.getAndIncrement());
        pets.add(pet);

        return ResponseEntity.status(201)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets/{id}")
    public ResponseEntity<PetDTO> getPet(@PathVariable("id") long id) {
        PetDTO pet = findPetById(id);
        if (pet == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pet);
    }

    @GetMapping("/pets")
    public ResponseEntity<PetPageDTO> getAllPets(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        int totalElements = pets.size();
        int totalPages = size > 0 ? (int) Math.ceil((double) totalElements / size) : 0;
        int fromIndex = Math.min(page * size, totalElements);
        int toIndex = Math.min(fromIndex + size, totalElements);

        List<PetDTO> content = new ArrayList<>(pets.subList(fromIndex, toIndex));

        PetPageDTO pageDTO = new PetPageDTO();
        pageDTO.setContent(content);
        pageDTO.setPage(page);
        pageDTO.setSize(size);
        pageDTO.setTotalElements(totalElements);
        pageDTO.setTotalPages(totalPages);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(pageDTO);
    }

    @PutMapping("/pets/{id}")
    public ResponseEntity<?> updatePet(@PathVariable("id") long id, @RequestBody PetDTO pet) {
        Map<String, String> error = validatePet(pet);
        if (error != null) {
            return ResponseEntity.badRequest()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(error);
        }

        PetDTO currentPet = findPetById(id);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        currentPet.setName(pet.getName());
        currentPet.setStatus(pet.getStatus());
        currentPet.setCategory(pet.getCategory());
        currentPet.setTags(pet.getTags());

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(currentPet);
    }

    @DeleteMapping("/pets/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable("id") long id) {
        PetDTO currentPet = findPetById(id);
        if (currentPet == null) {
            return ResponseEntity.notFound().build();
        }

        pets = pets.stream()
                .filter(p -> p.getId() != id)
                .collect(Collectors.toCollection(ArrayList::new));

        return ResponseEntity.ok().build();
    }

    private PetDTO findPetById(long id) {
        return pets.stream()
                .filter(p -> p.getId() == id)
                .findFirst()
                .orElse(null);
    }

    private Map<String, String> validatePet(PetDTO pet) {
        if (StringUtils.isBlank(pet.getName())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "Pet name is required");
            return error;
        }
        if (StringUtils.isBlank(pet.getStatus())) {
            Map<String, String> error = new LinkedHashMap<>();
            error.put("error", "Validation failed");
            error.put("message", "Pet status is required");
            return error;
        }
        return null;
    }
}
