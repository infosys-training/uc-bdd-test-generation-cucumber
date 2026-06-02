@petstore
Feature: Petstore CRUD api tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |
    And the petstore is empty

  Scenario: Create a new pet
    When I set http body to {"id":"1","name":"Buddy","status":"available","category":"dog","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","vaccinated"]
    And the petstore should contain 1 pets

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 10
    And http response body path $.name should be Goldie
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Read a pet by id
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog

  Scenario: Update a pet
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
    When I set http body to {"id":"1","name":"Buddy","status":"sold","category":"dog","tags":["friendly"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Patch a pet status
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
    When I set http body to {"status":"pending"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.status should be pending
    And http response body path $.name should be Buddy

  Scenario: Delete a pet
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
      | 2  | Whiskers | available | cat    |
    When I DELETE /pets/1
    Then http response code should be 200
    And the petstore should contain 1 pets
    When I DELETE /pets/2
    Then http response code should be 200
    And the petstore should be empty

  Scenario: List all pets
    Given the petstore has the following pets:
      | id | name     | status    | category |
      | 1  | Buddy    | available | dog      |
      | 2  | Whiskers | sold      | cat      |
      | 3  | Tweety   | available | bird     |
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3

  Scenario: List pets filtered by status
    Given the petstore has the following pets:
      | id | name     | status    | category |
      | 1  | Buddy    | available | dog      |
      | 2  | Whiskers | sold      | cat      |
      | 3  | Tweety   | available | bird     |
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 2

  Scenario: Store and reuse pet id across steps
    When I set http body to {"id":"42","name":"Rex","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 201
    And I store the value of http body path $.id as petId in scenario scope
    And http value of scenario variable petId should be 42
    When I GET /pets/42
    Then http response code should be 200
    And http response body path $.name should be Rex
