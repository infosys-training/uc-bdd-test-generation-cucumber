@petstore
Feature: Petstore validation error tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |
    And the petstore is empty

  Scenario: Create pet without name should fail
    When I set http body to {"id":"1","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain name is required

  Scenario: Create pet without status should fail
    When I set http body to {"id":"2","name":"Buddy","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain status is required

  Scenario: Create pet without name and status should fail
    When I set http body to {"id":"3","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain name is required
    And http response body should contain status is required

  Scenario: Create pet with empty name should fail
    When I set http body to {"id":"4","name":"","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body should contain name is required

  Scenario: Update pet with missing required fields should fail
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
    When I set http body to {"id":"1","category":"dog"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body should contain name is required
    And http response body should contain status is required

  Scenario: Create duplicate pet should fail
    When I set http body to {"id":"1","name":"Buddy","status":"available"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"id":"1","name":"Buddy Clone","status":"available"}
    And I POST /pets
    Then http response code should be 400
