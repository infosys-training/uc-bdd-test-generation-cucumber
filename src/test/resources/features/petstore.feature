@pet
Feature: Petstore API CRUD tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ===== CREATE (Happy Path) =====

  Scenario: Create a new pet successfully
    When I set http body to {"id":"1","name":"Buddy","status":"available","tags":["dog","friendly"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.tags should be ["dog","friendly"]

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","tags":["cat"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending

  Scenario: Create a third pet for pagination tests
    When I set http body to {"id":"3","name":"Goldie","status":"sold","tags":["fish"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Goldie

  # ===== CREATE (Validation Errors) =====

  Scenario: Create pet without name should fail validation
    When I set http body to {"id":"10","name":"","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.errors should be ["name is required"]

  Scenario: Create pet without status should fail validation
    When I set http body to {"id":"11","name":"Rex","status":""}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.errors should be ["status is required"]

  Scenario: Create pet without name and status should fail validation
    When I set http body to {"id":"12","name":"","status":""}
    And I POST /pets
    Then http response code should be 400
    And http response body is typed as array using path $.errors with length 2

  # ===== READ (Happy Path) =====

  Scenario: Get an existing pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.tags should be ["dog","friendly"]

  # ===== READ (Not Found) =====

  Scenario: Get a non-existent pet should return 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ===== UPDATE (Happy Path) =====

  Scenario: Update an existing pet successfully
    When I set http body to {"id":"1","name":"Buddy Updated","status":"sold","tags":["dog","trained"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold
    And http response body path $.tags should be ["dog","trained"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  # ===== UPDATE (Validation Errors) =====

  Scenario: Update pet with missing name should fail validation
    When I set http body to {"id":"1","name":"","status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.errors should be ["name is required"]

  # ===== UPDATE (Not Found) =====

  Scenario: Update a non-existent pet should return 404
    When I set http body to {"id":"88888","name":"Ghost","status":"available"}
    And I PUT /pets/88888
    Then http response code should be 404
    And http response body path $ should not have content

  # ===== LIST (Happy Path) =====

  Scenario: List all pets returns paginated results
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalPages should be 1

  # ===== LIST (Pagination) =====

  Scenario: List pets with page size of 2 returns first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with page size of 2 returns second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].id should be 3

  Scenario: List pets beyond last page returns empty content
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # ===== DELETE (Happy Path) =====

  Scenario: Delete an existing pet successfully
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets/2
    Then http response code should be 404

  # ===== DELETE (Not Found) =====

  Scenario: Delete a non-existent pet should return 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ===== Cleanup =====

  Scenario: Delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
