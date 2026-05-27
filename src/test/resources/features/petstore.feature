Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # === CRUD: Create ===

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":"3","status":"available","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId in scenario scope
    And http value of scenario variable petId should be 1

  Scenario: Create a second pet from fixture file
    And I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 2
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 5
    And http response body path $.tags should be ["playful"]

  Scenario: Create a third pet
    When I set http body to {"id":"3","name":"Whiskers","species":"cat","breed":"Siamese","age":"5","status":"available","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Create a fourth pet
    When I set http body to {"id":"4","name":"Polly","species":"bird","breed":"Parrot","age":"2","status":"pending","tags":["talks"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Polly
    And http response body path $.species should be bird
    And http response body path $.status should be pending

  # === Validation errors ===

  Scenario: Fail to create pet without name
    When I set http body to {"id":"90","species":"dog","breed":"Labrador","age":"2","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Name is required

  Scenario: Fail to create pet without species
    When I set http body to {"id":"91","name":"Rex","breed":"German Shepherd","age":"4","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Species is required

  Scenario: Fail to create duplicate pet
    When I set http body to {"id":"1","name":"Buddy Duplicate","species":"dog"}
    And I POST /pets
    Then http response code should be 409
    And http response body should be valid json
    And http response body path $.error should be Conflict
    And http response body path $.message should be Pet with id 1 already exists

  # === CRUD: Read ===

  Scenario: Read a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3

  Scenario: Read another pet by ID
    When I GET /pets/3
    Then http response code should be 200
    And http response body path $.id should be 3
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Fail to read non-existent pet
    When I GET /pets/999
    Then http response code should be 404
    And http response body should be valid json
    And http response body path $.error should be Not found
    And http response body path $.message should be Pet with id 999 not found

  # === CRUD: Update ===

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy Updated","species":"dog","breed":"Golden Retriever","age":"4","status":"adopted","tags":["friendly"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.name should be Buddy Updated
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["friendly"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be adopted

  Scenario: Fail to update non-existent pet
    When I set http body to {"id":"999","name":"Ghost","species":"cat"}
    And I PUT /pets/999
    Then http response code should be 404
    And http response body path $.error should be Not found
    And http response body path $.message should be Pet with id 999 not found

  Scenario: Fail to update pet with missing required name
    When I set http body to {"id":"1","species":"dog"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Name is required

  Scenario: Fail to update pet with missing required species
    When I set http body to {"id":"1","name":"Buddy"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Species is required

  # === CRUD: List with Pagination ===

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 4
    And http response body path $.totalElements should be 4
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[0].name should be Buddy Updated

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 1
    And http response body path $.content.[0].id should be 3
    And http response body path $.content.[1].id should be 4

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 5

  Scenario: List pets filtered by status
    And I set http query parameter status to adopted
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Buddy Updated
    And http response body path $.content.[0].status should be adopted

  Scenario: List pets filtered by species
    And I set http query parameter species to cat
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Whiskers
    And http response body path $.content.[0].species should be cat

  Scenario: List pets filtered by species with no results
    And I set http query parameter species to hamster
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0

  # === CRUD: Delete ===

  Scenario: Delete a pet successfully
    When I DELETE /pets/4
    Then http response code should be 200
    When I GET /pets/4
    Then http response code should be 404

  Scenario: Fail to delete non-existent pet
    When I DELETE /pets/999
    Then http response code should be 404
    And http response body should be valid json
    And http response body path $.error should be Not found
    And http response body path $.message should be Pet with id 999 not found

  Scenario: Cleanup - delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
