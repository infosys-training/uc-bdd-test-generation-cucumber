@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ── CREATE ──────────────────────────────────────────────

  Scenario: Create a pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"3","status":"available"}
    When I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Create a second pet
    And I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"5","status":"available"}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers

  Scenario: Create a third pet for pagination tests
    And I set http body to {"id":"3","name":"Tweety","species":"bird","breed":"Canary","age":"1","status":"adopted"}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3

  Scenario: Create pet with duplicate id should fail
    And I set http body to {"id":"1","name":"Duplicate","species":"dog","breed":"Poodle","age":"2","status":"available"}
    When I POST /pets
    Then http response code should be 400

  # ── VALIDATION ERRORS ──────────────────────────────────

  Scenario: Create pet without name should return validation error
    And I set http body to {"id":"10","species":"dog","breed":"Labrador","age":"2","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain name

  Scenario: Create pet without species should return validation error
    And I set http body to {"id":"11","name":"Rex","breed":"Unknown","age":"4","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain species

  Scenario: Create pet without name and species should return validation error
    And I set http body to {"id":"12","breed":"Unknown","age":"1","status":"pending"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed

  # ── READ ────────────────────────────────────────────────

  Scenario: Get pet by id
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog

  Scenario: Get pet not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be 1
    And http response body path $.[1].id should be 2
    And http response body path $.[2].id should be 3

  # ── PAGINATION ──────────────────────────────────────────

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body is typed as array using path $.content with length 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 1
    And http response body is typed as array using path $.content with length 1

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # ── UPDATE ──────────────────────────────────────────────

  Scenario: Update pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"4","status":"adopted"}
    When I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Update pet not found
    And I set http body to {"id":"99999","name":"Ghost","species":"cat","breed":"Unknown","age":"1","status":"available"}
    When I PUT /pets/99999
    Then http response code should be 404

  Scenario: Update pet with missing required fields should return validation error
    And I set http body to {"id":"1","breed":"Golden Retriever","age":"4","status":"adopted"}
    When I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed

  # ── DELETE ──────────────────────────────────────────────

  Scenario: Delete pet not found
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Delete pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  @petCleanup
  Scenario: Delete remaining pets and verify empty list
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
