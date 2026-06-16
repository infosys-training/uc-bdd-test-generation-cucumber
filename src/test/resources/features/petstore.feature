Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","category":"dog","status":"available","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.category should be dog
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet using fixture file
    And I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Max
    And http response body path $.category should be dog
    And http response body path $.status should be available
    And http response body path $.tags should be ["golden","retriever"]

  Scenario: Create a third pet
    When I set http body to {"id":"3","name":"Whiskers","category":"cat","status":"pending","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Whiskers
    And http response body path $.category should be cat

  Scenario: Create pet with missing name returns validation error
    When I set http body to {"id":"99","category":"cat","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create duplicate pet returns error
    When I set http body to {"id":"1","name":"Buddy","category":"dog","status":"available"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Get a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.category should be dog
    And http response body path $.status should be available

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet
    When I set http body to {"id":"1","name":"Buddy","category":"dog","status":"sold","tags":["friendly"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"999","name":"Ghost","category":"cat","status":"available"}
    And I PUT /pets/999
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3
    And http response body path $.content.[0].name should be Buddy
    And http response body should contain Whiskers

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Whiskers
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - empty page beyond range
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.page should be 5

  Scenario: Delete a pet
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/999
    Then http response code should be 404

  Scenario: Clean up remaining pets
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
