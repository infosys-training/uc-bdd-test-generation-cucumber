Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # --- Successful CRUD operations ---

  Scenario: Create a pet
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":3}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":2}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Create a third pet using fixture file
    When I set http body with file fixtures/pet-charlie.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Charlie
    And http response body path $.species should be dog
    And http response body path $.breed should be Beagle
    And http response body path $.age should be 5

  Scenario: Create a fourth pet
    When I set http body to {"id":"4","name":"Goldie","species":"fish","breed":"Goldfish","age":1}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 4

  Scenario: Create a fifth pet
    When I set http body to {"id":"5","name":"Rex","species":"dog","breed":"German Shepherd","age":4}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 5

  Scenario: Read a pet by id
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 5
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: Update a pet
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Golden Retriever","age":4}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.name should be Buddy

  Scenario: Patch a pet
    When I set http body to {"name":"Buddy Jr"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.species should be dog
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr

  Scenario: Delete a pet
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 4

  # --- Validation error scenarios ---

  Scenario: Create a pet without required name field
    When I set http body to {"id":"99","species":"dog","breed":"Labrador","age":2}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be name is required

  Scenario: Create a pet without required species field
    When I set http body to {"id":"98","name":"NoSpecies","breed":"Unknown","age":1}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be species is required

  Scenario: Create a duplicate pet
    When I set http body to {"id":"1","name":"Duplicate","species":"dog","breed":"Poodle","age":1}
    And I POST /pets
    Then http response code should be 400

  # --- Not-found scenarios ---

  Scenario: Get a pet that does not exist
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet that does not exist
    When I set http body to {"id":"99999","name":"Ghost","species":"cat","breed":"Unknown","age":1}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Patch a pet that does not exist
    When I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete a pet that does not exist
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # --- Pagination scenarios ---

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
    And http response body path $.content.[0].name should be Buddy Jr

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 1

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 10
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content
    And http response body path $.totalElements should be 4

  # --- Cleanup ---

  Scenario: Delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    And I DELETE /pets/4
    Then http response code should be 200
    And I DELETE /pets/5
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content
