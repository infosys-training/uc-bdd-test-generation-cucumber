Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # --- Validation Errors ---

  Scenario: Create pet with missing name should fail validation
    When I set http body to {"id":"99","species":"cat","breed":"Siamese","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.status should be 400
    And http response body path $.errors.[0] should be name is required

  Scenario: Create pet with missing species should fail validation
    When I set http body to {"id":"98","name":"Whiskers","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.status should be 400
    And http response body path $.errors.[0] should be species is required

  Scenario: Create pet with missing name and species should fail validation
    When I set http body to {"id":"97","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.errors.[0] should be name is required
    And http response body path $.errors.[1] should be species is required

  # --- Successful CRUD Operations ---

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":"5","tags":["playful","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.tags should be ["playful", "vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Persian","age":"3","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.breed should be Persian
    And http response body path $.age should be 3

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.tags should be ["friendly", "trained"]

  Scenario: Create a duplicate pet should fail
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":"5"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Read a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.tags.[0] should be playful
    And http response body path $.tags.[1] should be vaccinated

  Scenario: Read second pet by ID
    When I GET /pets/2
    Then http response code should be 200
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":"6","tags":["playful","vaccinated","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.tags should be ["playful", "vaccinated", "senior"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6

  Scenario: Update a pet with missing required fields should fail
    When I set http body to {"id":"1","breed":"Labrador","age":"6"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.errors.[0] should be name is required
    And http response body path $.errors.[1] should be species is required

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Max
    And http response body path $.[1].id should be 2
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].id should be 3
    And http response body path $.[2].name should be Buddy

  # --- Pagination ---

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
    And http response body path $.content.[0].name should be Max
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Buddy

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0

  # --- Not Found Cases ---

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","species":"unknown","breed":"None","age":"0"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # --- Delete Operations ---

  Scenario: Delete a pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  Scenario: Delete remaining pets
    When I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
