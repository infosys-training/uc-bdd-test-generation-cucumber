@petstore
Feature: Petstore API tests
  As a petstore administrator
  I want to manage pets through a REST API
  So that I can perform CRUD operations on pet records

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ===== CREATE =====

  Scenario: Create a pet successfully
    And I set http body to {"id":"1","name":"Buddy","species":"dog","status":"available","age":3}
    When I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.status should be available
    And http response body path $.age should be 3

  Scenario: Create another pet successfully
    And I set http body to {"id":"2","name":"Whiskers","species":"cat","status":"pending","age":2}
    When I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.status should be pending
    And http response body path $.age should be 2

  # ===== VALIDATION ERRORS =====

  Scenario: Create a pet with missing name returns validation error
    And I set http body to {"id":"90","species":"dog","status":"available","age":3}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create a pet with missing species returns validation error
    And I set http body to {"id":"91","name":"NoSpecies","status":"available","age":3}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.error should be species is required

  Scenario: Create a pet with duplicate ID returns error
    Given the petstore contains the following pets:
      | id | name  | species | status    | age |
      | 50 | Buddy | dog     | available | 3   |
    And I set http body to {"id":"50","name":"Rex","species":"dog","status":"available","age":5}
    When I POST /pets
    Then http response code should be 400
    And http response body path $.error should be pet with this ID already exists

  # ===== READ =====

  Scenario: Get an existing pet by ID
    Given the petstore contains the following pets:
      | id | name  | species | status    | age |
      | 10 | Buddy | dog     | available | 3   |
    When I GET /pets/10
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 10
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.status should be available
    And http response body path $.age should be 3

  Scenario: Get a second existing pet by ID
    Given the petstore contains the following pets:
      | id | name     | species | status  | age |
      | 20 | Whiskers | cat     | pending | 2   |
    When I GET /pets/20
    Then http response code should be 200
    And http response body path $.id should be 20
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ===== UPDATE =====

  Scenario: Update an existing pet successfully
    Given the petstore contains the following pets:
      | id | name  | species | status    | age |
      | 10 | Buddy | dog     | available | 3   |
    And I set http body to {"id":"10","name":"Buddy","species":"dog","status":"sold","age":4}
    When I PUT /pets/10
    Then http response code should be 200
    And http response body path $.status should be sold
    And http response body path $.age should be 4
    When I GET /pets/10
    Then http response code should be 200
    And http response body path $.status should be sold
    And http response body path $.age should be 4

  Scenario: Update a non-existent pet returns 404
    And I set http body to {"id":"99999","name":"Ghost","species":"cat","status":"available","age":1}
    When I PUT /pets/99999
    Then http response code should be 404

  # ===== DELETE =====

  Scenario: Delete an existing pet
    Given the petstore contains the following pets:
      | id | name  | species | status    | age |
      | 10 | Buddy | dog     | available | 3   |
    When I DELETE /pets/10
    Then http response code should be 200
    When I GET /pets/10
    Then http response code should be 404

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Delete all pets and verify empty list
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 10 | Buddy    | dog     | available | 3   |
      | 20 | Whiskers | cat     | pending   | 2   |
    When I DELETE /pets/10
    Then http response code should be 200
    When I DELETE /pets/20
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0

  # ===== LIST =====

  Scenario: List all pets returns paginated response
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 1  | Buddy    | dog     | available | 3   |
      | 2  | Whiskers | cat     | pending   | 2   |
      | 3  | Goldie   | fish    | available | 1   |
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].name should be Goldie

  Scenario: List pets when petstore is empty
    Given the petstore is empty
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
    And http response body path $.totalPages should be 0

  # ===== PAGINATION =====

  Scenario: List pets with pagination - first page
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 1  | Buddy    | dog     | available | 3   |
      | 2  | Whiskers | cat     | pending   | 2   |
      | 3  | Goldie   | fish    | available | 1   |
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 1  | Buddy    | dog     | available | 3   |
      | 2  | Whiskers | cat     | pending   | 2   |
      | 3  | Goldie   | fish    | available | 1   |
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].name should be Goldie

  Scenario: List pets with pagination - page beyond last returns empty content
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 1  | Buddy    | dog     | available | 3   |
      | 2  | Whiskers | cat     | pending   | 2   |
    And I set http query parameter page to 99
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.page should be 99
    And http response body path $.totalElements should be 2

  Scenario: List pets with page size of one
    Given the petstore contains the following pets:
      | id | name     | species | status    | age |
      | 1  | Buddy    | dog     | available | 3   |
      | 2  | Whiskers | cat     | pending   | 2   |
      | 3  | Goldie   | fish    | available | 1   |
    And I set http query parameter page to 0
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 3
    And http response body path $.content.[0].name should be Buddy
