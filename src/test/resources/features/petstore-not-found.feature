@petstore
Feature: Petstore not-found error tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |
    And the petstore is empty

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Patch non-existent pet returns 404
    When I set http body to {"status":"sold"}
    And I PATCH /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Get pet after deletion returns 404
    Given the petstore has the following pets:
      | id | name   | status    | category |
      | 1  | Buddy  | available | dog      |
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404
    And http response body path $ should not have content
