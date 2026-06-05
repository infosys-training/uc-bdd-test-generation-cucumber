@petstore
Feature: Petstore REST API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Rex","status":"available","tags":["labrador","playful"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.tags should be ["labrador", "playful"]

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","tags":["cat","indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/pet-golden-retriever.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.tags should be ["golden-retriever", "friendly"]

  Scenario: Get a pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Rex","status":"sold","tags":["labrador","trained"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold
    And http response body path $.tags should be ["labrador", "trained"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"88888","name":"Ghost","status":"available"}
    And I PUT /pets/88888
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2
    And http response body path $.content.[2].id should be 3

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
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 3

  Scenario: List pets with pagination - empty page beyond range
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  Scenario: Validation error - missing pet name
    When I set http body to {"id":"10","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet name is required

  Scenario: Validation error - missing pet id
    When I set http body to {"name":"NoId","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet id is required

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Delete a pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete remaining pets and verify empty list
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
