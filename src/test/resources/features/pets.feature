@pet
Feature: Pet api tests

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
    And I store the value of http body path $.id as petRexId in scenario scope

  Scenario: Create a pet with missing required name
    When I set http body to {"id":"99","status":"available","category":"cat"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet name is required

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","category":"cat","tags":["playful"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat

  Scenario: Create a third pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Read an existing pet
    When I GET /pets/`$petRexId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.category should be dog

  Scenario: Read a non-existent pet
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update an existing pet
    When I set http body to {"id":"1","name":"Rex","status":"sold","category":"dog","tags":["loyal","guard","adopted"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.status should be sold
    And http response body path $.tags should be ["loyal","guard","adopted"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Update a non-existent pet
    When I set http body to {"id":"88888","name":"Ghost","status":"available","category":"fish"}
    And I PUT /pets/88888
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be `$petRexId`
    And http response body path $.[0].name should be Rex
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].name should be Buddy

  Scenario: List pets with pagination - first page
    When I set http query parameter page to 0
    And I set http query parameter size to 2
    And I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Rex
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    When I set http query parameter page to 1
    And I set http query parameter size to 2
    And I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Buddy

  Scenario: List pets with pagination - beyond last page
    When I set http query parameter page to 5
    And I set http query parameter size to 2
    And I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0

  Scenario: Delete a non-existent pet
    When I DELETE /pets/77777
    Then http response code should be 404

  Scenario: Delete a pet
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Cleanup remaining pets
    When I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
