@pet
Feature: Petstore API tests


  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ──────────────────────────────────────────────
  #  CREATE
  # ──────────────────────────────────────────────

  Scenario: Create a pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"5","status":"available","tags":["friendly","vaccinated"]}
    When I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petBuddyId in scenario scope

  Scenario: Create a second pet
    And I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"3","status":"adopted","tags":["indoor"]}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.status should be adopted

  Scenario: Create a pet from a fixture file
    And I set http body with file fixtures/golden-retriever.pet.json
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Charlie
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Create a fourth pet for pagination
    And I set http body to {"id":"4","name":"Rex","species":"dog","breed":"German Shepherd","age":"2","status":"available","tags":["guard"]}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 4
    And http response body path $.name should be Rex

  Scenario: Create a fifth pet for pagination
    And I set http body to {"id":"5","name":"Nemo","species":"fish","breed":"Clownfish","age":"1","status":"available","tags":["aquatic"]}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 5
    And http response body path $.name should be Nemo

  # ──────────────────────────────────────────────
  #  VALIDATION ERRORS
  # ──────────────────────────────────────────────

  Scenario: Fail to create a pet without a name
    And I set http body to {"id":"99","species":"dog","breed":"Poodle","age":"2","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.message should be Validation failed
    And http response body path $.errors should be ["name is required"]

  Scenario: Fail to create a pet without a species
    And I set http body to {"id":"98","name":"Unknown","age":"1","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body path $.errors should be ["species is required"]

  Scenario: Fail to create a pet without name and species
    And I set http body to {"id":"97","breed":"Mixed","age":"4","status":"pending"}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body is typed as array using path $.errors with length 2

  Scenario: Fail to create a duplicate pet
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"5","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Pet already exists

  # ──────────────────────────────────────────────
  #  READ
  # ──────────────────────────────────────────────

  Scenario: Get a pet by id
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$petBuddyId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.status should be available

  Scenario: Get pet not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ──────────────────────────────────────────────
  #  LIST
  # ──────────────────────────────────────────────

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 5
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].id should be 2
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].id should be 3
    And http response body path $.[2].name should be Charlie
    And http response body should contain Rex
    And http response body should contain Nemo

  Scenario: Filter pets by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $ with length 4
    And http response body path $.[0].name should be Buddy
    And http response body path $.[0].status should be available
    And http response body path $.[1].name should be Charlie
    And http response body path $.[2].name should be Rex
    And http response body path $.[3].name should be Nemo

  Scenario: Filter pets by status with no results
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content

  # ──────────────────────────────────────────────
  #  PAGINATION
  # ──────────────────────────────────────────────

  Scenario: List pets with pagination - first page
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
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.totalElements should be 5
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Charlie
    And http response body path $.content.[1].name should be Rex

  Scenario: List pets with pagination - last page
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 2
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Nemo

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 5
    And http response body is typed as array using path $.content with length 0

  # ──────────────────────────────────────────────
  #  UPDATE (PUT)
  # ──────────────────────────────────────────────

  Scenario: Update a pet
    And I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"7","status":"adopted","tags":["friendly","senior"]}
    When I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 7
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 7
    And http response body path $.status should be adopted

  Scenario: Update pet not found
    And I set http body to {"id":"99999","name":"Ghost","species":"dog","age":"1","status":"available"}
    When I PUT /pets/99999
    Then http response code should be 404

  # ──────────────────────────────────────────────
  #  PARTIAL UPDATE (PATCH)
  # ──────────────────────────────────────────────

  Scenario: Patch a pet status
    And I set http body to {"status":"pending"}
    When I PATCH /pets/2
    Then http response code should be 200
    And http response body path $.status should be pending
    And http response body path $.name should be Whiskers
    When I GET /pets/2
    Then http response code should be 200
    And http response body path $.status should be pending

  Scenario: Patch a pet name
    And I set http body to {"name":"Whiskers Jr."}
    When I PATCH /pets/2
    Then http response code should be 200
    And http response body path $.name should be Whiskers Jr.

  Scenario: Patch pet not found
    And I set http body to {"status":"adopted"}
    When I PATCH /pets/99999
    Then http response code should be 404

  # ──────────────────────────────────────────────
  #  DELETE
  # ──────────────────────────────────────────────

  Scenario: Delete pet not found
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Delete all pets and verify empty list
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I DELETE /pets/4
    Then http response code should be 200
    When I DELETE /pets/5
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
