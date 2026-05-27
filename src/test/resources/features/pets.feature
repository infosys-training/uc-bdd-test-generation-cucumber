Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # --- Successful CRUD ---

  Scenario: Create a pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    And I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat

  Scenario: Create a third pet
    And I set http body to {"id":"3","name":"Polly","species":"Parrot","breed":"Macaw","age":5,"status":"adopted"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Polly

  Scenario: Read a pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Update a pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Labrador","age":4,"status":"adopted"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 4

  Scenario: Patch a pet (partial update)
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
    And http response body is typed as array for path $.content
    And http response body path $.totalElements should be 3
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].name should be Polly

  # --- Pagination ---

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
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Polly

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # --- Validation Errors ---

  Scenario: Create pet without name returns 400
    And I set http body to {"id":"99","species":"Dog","breed":"Poodle","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be name is required

  Scenario: Create pet without species returns 400
    And I set http body to {"id":"99","name":"Rex","breed":"Mixed","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be species is required

  Scenario: Update pet with missing name returns 400
    And I set http body to {"id":"1","species":"Dog","breed":"Labrador","age":4,"status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be name is required

  # --- Not Found ---

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    And I set http body to {"id":"99999","name":"Ghost","species":"Unknown","age":0,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Patch non-existent pet returns 404
    And I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # --- Delete ---

  Scenario: Delete a pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  @pet
  Scenario: Delete remaining pets and verify empty list
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body path $.content should not have content
