@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ===================== SUCCESSFUL CRUD =====================

  Scenario: Create a new pet
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"3","status":"available","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petBuddyId in scenario scope

  Scenario: Create a second pet
    And I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"2","status":"available","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Create a third pet for pagination
    And I set http body to {"id":"3","name":"Rex","species":"dog","breed":"German Shepherd","age":"5","status":"adopted","tags":["guard"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Rex

  Scenario: Get pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Update a pet with PUT
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"4","status":"adopted","tags":["friendly","trained"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Partially update a pet with PATCH
    And I set http body to {"status":"available"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.status should be available
    And http response body path $.name should be Buddy
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be available

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array for path $.content

  Scenario: Delete a pet
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets/2
    Then http response code should be 404

  # ===================== VALIDATION ERRORS =====================

  Scenario: Create pet without name should fail
    And I set http body to {"id":"99","species":"dog","breed":"Poodle","age":"1","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create pet without species should fail
    And I set http body to {"id":"98","name":"NoSpecies","breed":"Unknown","age":"1","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be species is required

  Scenario: Update pet without name should fail
    And I set http body to {"id":"1","species":"dog","breed":"Golden Retriever","age":"4","status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Update pet without species should fail
    And I set http body to {"id":"1","name":"Buddy","breed":"Golden Retriever","age":"4","status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be species is required

  # ===================== NOT FOUND CASES =====================

  Scenario: Get non-existent pet
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet
    And I set http body to {"id":"99999","name":"Ghost","species":"cat","age":"1","status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Patch non-existent pet
    And I set http body to {"status":"adopted"}
    And I PATCH /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not exist
    And http response body path $ should not have content

  # ===================== PAGINATION =====================

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 1

  Scenario: List pets with pagination - page beyond range
    And I set http query parameter page to 100
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0

  Scenario: Filter pets by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.content.[0].status should be available

  # ===================== CLEANUP =====================

  Scenario: Delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
