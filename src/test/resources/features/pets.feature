@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept       | application/json |
      | Content-Type | application/json |

  # --- Successful CRUD Operations ---

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Labrador","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And I store the value of http body path $.id as petId in scenario scope
    And http value of scenario variable petId should be 1

  Scenario: Create a pet with default status
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":2}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.status should be available

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/new-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Max
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3

  Scenario: Get a pet by ID
    Given the pet store has a pet with id "1" name "Buddy" and species "Dog"
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog

  Scenario: Update a pet successfully
    Given the pet store has a pet with id "1" name "Buddy" and species "Dog"
    When I set http body to {"name":"Buddy Updated","species":"Dog","breed":"Labrador","age":4,"status":"sold"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.age should be 4
    And http response body path $.status should be sold
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated

  Scenario: Delete a pet successfully
    Given the pet store has a pet with id "1" name "Buddy" and species "Dog"
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  Scenario: List all pets
    Given the pet store has 3 pets
    And I set http query parameter page to 0
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[0].name should be Pet1

  # --- Validation Errors ---

  Scenario: Create a pet with missing name
    When I set http body to {"species":"Cat","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.message should be Validation failed
    And http response body should contain name is required

  Scenario: Create a pet with missing species
    When I set http body to {"name":"Whiskers","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body should contain species is required

  Scenario: Create a pet with missing name and species
    When I set http body to {"breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body is typed as array using path $.errors with length 2

  Scenario: Update a pet with missing required fields
    Given the pet store has a pet with id "1" name "Buddy" and species "Dog"
    When I set http body to {"breed":"Labrador","age":4}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body is typed as array using path $.errors with length 2

  # --- Not Found Cases ---

  Scenario: Get a non-existent pet
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet
    When I set http body to {"name":"Ghost","species":"Cat"}
    And I PUT /pets/999
    Then http response code should be 404

  Scenario: Delete a non-existent pet
    When I DELETE /pets/999
    Then http response code should be 404

  # --- Pagination ---

  Scenario: List pets with default pagination
    Given the pet store has 3 pets
    And I set http query parameter page to 0
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 3
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 1

  Scenario: List pets with custom page size
    Given the pet store has 5 pets
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3

  Scenario: List pets second page
    Given the pet store has 5 pets
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 1
    And http response body path $.content.[0].id should be 3

  Scenario: List pets beyond last page
    Given the pet store has 3 pets
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3

  Scenario: List pets filtered by status
    Given the pet store has 5 pets
    And I set http query parameter status to available
    And I set http query parameter page to 0
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body is typed as array using path $.content with length 4
