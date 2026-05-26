Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ──────────────────────────────────────────────
  # Successful CRUD operations
  # ──────────────────────────────────────────────

  Scenario: Create a pet with inline JSON
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/whiskers-cat.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat
    And http response body path $.breed should be Siamese
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["calm"]

  Scenario: Create a third pet for list and pagination tests
    When I set http body to {"id":"3","name":"Charlie","species":"Dog","breed":"Labrador","age":2,"status":"pending","tags":["playful"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Charlie

  Scenario: Create a duplicate pet should fail
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Get pet by id
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Update a pet
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":4,"status":"adopted","tags":["friendly","trained","vaccinated"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["friendly","trained","vaccinated"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Patch a pet
    When I set http body to {"name":"Buddy Jr.","status":"available"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.name should be Buddy Jr.
    And http response body path $.status should be available
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr.

  # ──────────────────────────────────────────────
  # List and filter
  # ──────────────────────────────────────────────

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be 1
    And http response body path $.[1].id should be 2
    And http response body path $.[2].id should be 3

  Scenario: Filter pets by status
    And I set http query parameter status to pending
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $ with length 1
    And http response body path $.[0].name should be Charlie

  # ──────────────────────────────────────────────
  # Pagination
  # ──────────────────────────────────────────────

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 3

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # ──────────────────────────────────────────────
  # Validation errors
  # ──────────────────────────────────────────────

  Scenario: Create pet without name should fail validation
    When I set http body to {"id":"99","species":"Dog","breed":"Poodle","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required

  Scenario: Create pet without species should fail validation
    When I set http body to {"id":"99","name":"NoSpecies","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.species should be Species is required

  Scenario: Create pet without name and species should fail validation
    When I set http body to {"id":"99","breed":"Unknown","age":1}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required
    And http response body path $.fields.species should be Species is required

  Scenario: Update pet with missing required fields should fail validation
    When I set http body to {"id":"1","breed":"Golden Retriever","age":4}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required

  # ──────────────────────────────────────────────
  # Not-found cases
  # ──────────────────────────────────────────────

  Scenario: Get non-existent pet should return 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet should return 404
    When I set http body to {"id":"99999","name":"Ghost","species":"Unknown","age":0,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Patch non-existent pet should return 404
    When I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet should return 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ──────────────────────────────────────────────
  # Delete operations (cleanup)
  # ──────────────────────────────────────────────

  Scenario: Delete a pet
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    And I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
