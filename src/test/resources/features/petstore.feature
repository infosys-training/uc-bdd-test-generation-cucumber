Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ---------- CREATE ----------

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"3"}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"5","status":"adopted"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.breed should be Siamese
    And http response body path $.age should be 5
    And http response body path $.status should be adopted

  Scenario: Create a third pet successfully
    When I set http body to {"id":"3","name":"Tweety","species":"bird","breed":"Canary","age":"1"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Tweety
    And http response body path $.species should be bird

  Scenario: Create a fourth pet for pagination tests
    When I set http body to {"id":"4","name":"Rex","species":"dog","breed":"German Shepherd","age":"2"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 4
    And http response body path $.name should be Rex

  Scenario: Create a fifth pet for pagination tests
    When I set http body to {"id":"5","name":"Nemo","species":"fish","breed":"Clownfish","age":"1"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 5
    And http response body path $.name should be Nemo

  # ---------- VALIDATION ERRORS ----------

  Scenario: Create a pet with missing name should fail validation
    When I set http body to {"id":"99","species":"dog","breed":"Poodle","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be name is required

  Scenario: Create a pet with missing species should fail validation
    When I set http body to {"id":"98","name":"NoSpecies","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.species should be species is required

  Scenario: Create a pet with all required fields missing should fail validation
    When I set http body to {"id":"97","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be name is required
    And http response body path $.fields.species should be species is required

  Scenario: Update a pet with missing required fields should fail validation
    When I set http body to {"id":"1","breed":"Labrador","age":"4"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be name is required
    And http response body path $.fields.species should be species is required

  # ---------- READ ----------

  Scenario: Get all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 5
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].id should be 2
    And http response body path $.[1].name should be Whiskers

  Scenario: Get a single pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Get a pet that was created with explicit status
    When I GET /pets/2
    Then http response code should be 200
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be adopted

  # ---------- NOT FOUND ----------

  Scenario: Get a pet that does not exist
    When I GET /pets/9999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet that does not exist
    When I set http body to {"id":"9999","name":"Ghost","species":"unknown","breed":"None","age":"0"}
    And I PUT /pets/9999
    Then http response code should be 404

  Scenario: Delete a pet that does not exist
    When I DELETE /pets/9999
    Then http response code should be 404

  # ---------- UPDATE ----------

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"4","status":"adopted"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Verify the update persisted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  # ---------- PAGINATION ----------

  Scenario: Get first page of pets with page size 2
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: Get second page of pets with page size 2
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 3
    And http response body path $.content.[1].id should be 4

  Scenario: Get last page of pets with page size 2
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 2
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 5

  Scenario: Get page beyond available data returns empty content
    And I set http query parameter page to 10
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 10
    And http response body path $.totalElements should be 5
    And http response body is typed as array using path $.content with length 0

  # ---------- DELETE ----------

  Scenario: Delete a pet successfully
    When I DELETE /pets/3
    Then http response code should be 200
    And I GET /pets
    And http response body is typed as array using path $ with length 4

  Scenario: Delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/4
    Then http response code should be 200
    And I DELETE /pets/5
    Then http response code should be 200
    And I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
