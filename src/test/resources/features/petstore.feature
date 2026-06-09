Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","status":"available","category":"dog","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","status":"available","category":"cat","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.category should be cat

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 10
    And http response body path $.name should be Golden
    And http response body path $.status should be available
    And http response body path $.tags should be ["gentle","family-friendly"]

  Scenario: Validation error - missing required name field
    When I set http body to {"id":"4","status":"available","category":"bird"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Validation error - duplicate pet ID
    When I set http body to {"id":"1","name":"Duplicate","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Retrieve pet details by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","vaccinated"]

  Scenario: Get non-existent pet returns not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update an existing pet
    When I set http body to {"id":"1","name":"Buddy","status":"sold","category":"dog","tags":["friendly","vaccinated","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly","vaccinated","senior"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Update non-existent pet returns not found
    When I set http body to {"id":"99999","name":"Ghost","status":"available","category":"unknown"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be `$petId`
    And http response body path $.[0].name should be Buddy
    And http response body should contain Whiskers

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $ with length 2
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 1
    And http response body path $.[0].name should be Golden

  Scenario: List pets with pagination - beyond available pages
    And I set http query parameter page to 10
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content

  Scenario: Delete a pet
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets/2
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete non-existent pet returns not found
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Cleanup remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/10
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
