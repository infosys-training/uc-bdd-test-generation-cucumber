@petstore
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Rex","status":"available","category":"dog","tags":["loyal","guard"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["loyal","guard"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","category":"cat","tags":["playful"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat

  Scenario: Create a pet using a fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Validation error when creating a pet without a name
    When I set http body to {"id":"99","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet name is required

  Scenario: Validation error when creating a pet with an empty name
    When I set http body to {"id":"100","name":"","status":"available","category":"cat"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed

  Scenario: Retrieve a pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["loyal","guard"]

  Scenario: Retrieve a non-existent pet returns 404
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update an existing pet
    When I set http body to {"id":"1","name":"Rex","status":"sold","category":"dog","tags":["loyal","guard","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body path $.status should be sold
    And http response body path $.tags should be ["loyal","guard","senior"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"888","name":"Ghost","status":"available","category":"fish"}
    And I PUT /pets/888
    Then http response code should be 404

  Scenario: Patch an existing pet status
    When I set http body to {"status":"pending"}
    And I PATCH /pets/2
    Then http response code should be 200
    And http response body path $.status should be pending
    And http response body path $.name should be Whiskers

  Scenario: List pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 3
    And http response body path $.page should be 0
    And http response body path $.size should be 10

  Scenario: List pets with custom page size
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 3
    And http response body path $.page should be 1

  Scenario: List pets beyond available pages returns empty content
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0

  Scenario: Delete a pet
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets/3
    Then http response code should be 404

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/999
    Then http response code should be 404

  Scenario: Cleanup remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
