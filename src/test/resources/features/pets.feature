@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept       | application/json |
      | Content-Type | application/json |

  # --- CRUD: Create ---
  Scenario: Create a new pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers

  Scenario: Create a third pet
    When I set http body to {"id":"3","name":"Rex","species":"Dog","breed":"German Shepherd","age":5,"status":"adopted"}
    And I POST /pets
    Then http response code should be 201

  # --- CRUD: Read ---
  Scenario: Get a pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog

  # --- CRUD: Update ---
  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":4,"status":"adopted"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  # --- CRUD: Delete ---
  Scenario: Delete a pet successfully
    When I DELETE /pets/3
    Then http response code should be 200

  # --- Validation errors ---
  Scenario: Create a pet without name should fail
    When I set http body to {"id":"10","species":"Dog","breed":"Poodle","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create a pet without species should fail
    When I set http body to {"id":"11","name":"NoSpecies","breed":"Unknown","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be species is required

  # --- Not Found cases ---
  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","species":"Unknown","age":0,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  # --- Pagination ---
  Scenario: List pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalElements should be 2
    And http response body is typed as array for path $.content

  Scenario: Create pets for pagination test
    When I set http body to {"id":"4","name":"Goldie","species":"Fish","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"id":"5","name":"Polly","species":"Parrot","age":10,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"id":"6","name":"Hammy","species":"Hamster","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 201

  Scenario: List pets with page size of 2
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3

  Scenario: List pets second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body is typed as array using path $.content with length 2

  Scenario: List pets last page with partial results
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 2
    And http response body is typed as array using path $.content with length 1

  # --- Cleanup ---
  Scenario: Clean up all remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/4
    Then http response code should be 200
    When I DELETE /pets/5
    Then http response code should be 200
    When I DELETE /pets/6
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
