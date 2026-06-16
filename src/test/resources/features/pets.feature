Feature: Petstore api tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ==========================================
  # CREATE PET SCENARIOS
  # ==========================================

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Rex","species":"Dog","breed":"German Shepherd","age":"5","status":"available","tags":["guard","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.species should be Dog
    And http response body path $.breed should be German Shepherd
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["guard", "trained"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":"3","status":"adopted","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat
    And http response body path $.breed should be Siamese
    And http response body path $.age should be 3
    And http response body path $.status should be adopted

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/pet-golden-retriever.json
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly", "trained"]

  Scenario: Create a pet with default status
    When I set http body to {"id":"4","name":"Polly","species":"Bird","breed":"Parrot","age":"2"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.status should be available

  # ==========================================
  # VALIDATION ERROR SCENARIOS
  # ==========================================

  Scenario: Fail to create a pet without name
    When I set http body to {"id":"99","species":"Dog","breed":"Poodle","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be Name is required

  Scenario: Fail to create a pet without species
    When I set http body to {"id":"99","name":"NoSpecies","breed":"Unknown","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.species should be Species is required

  Scenario: Fail to create a pet without name and species
    When I set http body to {"id":"99","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be Name is required
    And http response body path $.species should be Species is required

  Scenario: Fail to update a pet with missing required fields
    When I set http body to {"id":"1","breed":"Labrador","age":"6"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be Name is required
    And http response body path $.species should be Species is required

  # ==========================================
  # READ PET SCENARIOS
  # ==========================================

  Scenario: Get an existing pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.species should be Dog
    And http response body path $.breed should be German Shepherd
    And http response body path $.age should be 5

  Scenario: Get another existing pet
    When I GET /pets/2
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat

  # ==========================================
  # NOT FOUND SCENARIOS
  # ==========================================

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","species":"Unknown","age":"1"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  # ==========================================
  # UPDATE PET SCENARIOS
  # ==========================================

  Scenario: Update an existing pet successfully
    When I set http body to {"id":"1","name":"Rex","species":"Dog","breed":"German Shepherd","age":"6","status":"adopted","tags":["guard","trained","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.age should be 6
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["guard", "trained", "senior"]

  Scenario: Verify update persisted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be adopted

  # ==========================================
  # LIST PETS WITH PAGINATION
  # ==========================================

  Scenario: List all pets returns paginated response
    When I GET /pets
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.totalElements should be 4
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalPages should be 1
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 4
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[0].name should be Rex

  Scenario: List pets with custom page size
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 4
    And http response body path $.size should be 2
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 1
    And http response body path $.totalElements should be 4
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 3
    And http response body path $.content.[1].id should be 4

  Scenario: List pets with page beyond available data
    And I set http query parameter page to 99
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 99
    And http response body path $.totalElements should be 4
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # ==========================================
  # DELETE PET SCENARIOS
  # ==========================================

  Scenario: Delete an existing pet
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  Scenario: Delete another pet and verify list updated
    When I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    And I DELETE /pets/4
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
    And http response body path $.content should not have content
