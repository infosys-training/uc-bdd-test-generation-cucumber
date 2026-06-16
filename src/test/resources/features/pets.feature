Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ---------- Create ----------

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Rex","status":"available","tags":["dog","friendly"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.tags should be ["dog","friendly"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","tags":["cat"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending

  Scenario: Create a third pet using a fixture file
    When I set http body with file fixtures/buddy-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 10
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Create pet with duplicate id should fail
    When I set http body to {"id":"1","name":"Duplicate","status":"available"}
    And I POST /pets
    Then http response code should not be 201
    And http response code should be 409

  # ---------- Validation errors ----------

  Scenario: Create pet without name should fail
    When I set http body with file fixtures/missing-name-pet.json
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.field should be name
    And http response body path $.message should be Name is required

  Scenario: Create pet without status should fail
    When I set http body with file fixtures/missing-status-pet.json
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.field should be status
    And http response body path $.message should be Status is required

  Scenario: Update pet without name should fail
    When I set http body to {"name":"","status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.field should be name
    And http response body path $.message should be Name is required

  # ---------- Read ----------

  Scenario: Get pet by id
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Rex
    And http response body path $.status should be available

  Scenario: Get pet not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ---------- List / Pagination ----------

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Rex
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].name should be Buddy

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Rex
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Buddy

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0

  Scenario: Filter pets by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Rex
    And http response body path $.content.[1].name should be Buddy

  # ---------- Update ----------

  Scenario: Update a pet successfully
    When I set http body to {"name":"Rex Jr","status":"sold","tags":["dog","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body path $.name should be Rex Jr
    And http response body path $.status should be sold
    And http response body path $.tags should be ["dog","senior"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Rex Jr
    And http response body path $.status should be sold

  Scenario: Update a pet that does not exist
    When I set http body to {"name":"Ghost","status":"available"}
    And I PUT /pets/77777
    Then http response code should be 404
    And http response body path $ should not have content

  # ---------- Delete ----------

  Scenario: Delete a pet that does not exist
    When I DELETE /pets/88888
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete all pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/10
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
