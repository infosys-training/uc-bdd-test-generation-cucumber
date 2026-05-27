Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept       | application/json |
      | Content-Type | application/json |

  # --- Successful CRUD ---

  Scenario: Create a new pet
    And I set http body to {"name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.id should exists
    And I store the value of http body path $.id as petId1 in scenario scope

  Scenario: Create a second pet
    And I set http body to {"name":"Whiskers","species":"Cat","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat
    And I store the value of http body path $.id as petId2 in scenario scope

  Scenario: Create a third pet
    And I set http body to {"name":"Rex","species":"Dog","breed":"German Shepherd","age":5,"status":"adopted"}
    And I POST /pets
    Then http response code should be 201
    And I store the value of http body path $.id as petId3 in scenario scope

  Scenario: Read a pet by ID
    When I GET /pets/`$petId1`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId1`
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.age should be 3

  Scenario: Update a pet
    And I set http body to {"name":"Buddy","species":"Dog","breed":"Golden Retriever","age":4,"status":"adopted"}
    And I PUT /pets/`$petId1`
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/`$petId1`
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Delete a pet
    When I DELETE /pets/`$petId3`
    Then http response code should be 200
    When I GET /pets/`$petId3`
    Then http response code should be 404

  # --- Validation errors (missing required fields) ---

  Scenario: Create pet without name returns 400
    And I set http body to {"species":"Dog","breed":"Labrador","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be name is required

  Scenario: Create pet without species returns 400
    And I set http body to {"name":"NoSpecies","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be species is required

  Scenario: Update pet with missing name returns 400
    And I set http body to {"species":"Dog","age":4,"status":"available"}
    And I PUT /pets/`$petId1`
    Then http response code should be 400
    And http response body path $.error should be name is required

  # --- Not-found cases ---

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body should be valid json
    And http response body path $.error should be Pet not found

  Scenario: Update non-existent pet returns 404
    And I set http body to {"name":"Ghost","species":"Cat","age":1,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $.error should be Pet not found

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $.error should be Pet not found

  # --- Pagination ---

  Scenario: List pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 2
    And http response body is typed as array for path $.content
    And http response body path $.page should be 0
    And http response body path $.size should be 10

  Scenario: List pets with custom page size
    And I set http query parameter page to 0
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 0
    And http response body path $.size should be 1

  Scenario: List pets second page
    And I set http query parameter page to 1
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1

  Scenario: List pets beyond last page returns empty content
    And I set http query parameter page to 99
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # --- Cleanup ---

  Scenario: Clean up remaining pets
    When I DELETE /pets/`$petId1`
    Then http response code should be 200
    When I DELETE /pets/`$petId2`
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body path $.content should not have content
