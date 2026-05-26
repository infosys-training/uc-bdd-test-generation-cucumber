Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # --- Validation error scenarios ---

  Scenario: Create pet with missing name returns validation error
    And I set http body to {"id":"99","status":"available","category":"dog"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.errors should exists
    And http response body is typed as array using path $.errors with length 1

  Scenario: Create pet with missing status returns validation error
    And I set http body to {"id":"99","name":"NoStatus","category":"cat"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.errors should exists
    And http response body is typed as array using path $.errors with length 1

  Scenario: Create pet with all required fields missing returns validation errors
    And I set http body to {"id":"99","category":"bird"}
    When I POST /pets
    Then http response code should be 400
    And http response body is typed as array using path $.errors with length 2

  # --- Not-found scenarios ---

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not exist
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    And I set http body to {"name":"Ghost","status":"available"}
    When I PUT /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # --- Successful CRUD scenarios ---

  Scenario: Create first pet - Buddy the dog
    And I set http body to {"id":"1","name":"Buddy","status":"available","category":"dog","tags":["friendly","trained"]}
    When I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as buddyPetId in scenario scope
    And http value of scenario variable buddyPetId should be 1

  Scenario: Create second pet - Whiskers the cat
    And I set http body to {"id":"2","name":"Whiskers","status":"pending","category":"cat","tags":["indoor"]}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat

  Scenario: Create third pet using fixture file
    And I set http body with file fixtures/goldie.pet.json
    When I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Goldie
    And http response body path $.status should be available
    And http response body path $.category should be fish
    And http response body path $.tags should be ["aquatic"]

  Scenario: Create duplicate pet returns error
    And I set http body to {"id":"1","name":"Buddy Clone","status":"available","category":"dog"}
    When I POST /pets
    Then http response code should be 400

  Scenario: Get pet by ID
    When I GET /pets/`$buddyPetId`
    Then http response code should be 200
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be `$buddyPetId`
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body should contain Buddy

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be `$buddyPetId`
    And http response body path $.[0].name should be Buddy
    And http response body path $.[0].name should not be Whiskers
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].name should be Goldie
    And http response body path $.[1].id should exists
    And http response body path $.[4].id should not exist
    And http response body should contain Whiskers

  Scenario: Update pet successfully
    And I set http body to {"name":"Buddy Jr","status":"sold","category":"dog","tags":["friendly"]}
    When I PUT /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold

  # --- Pagination scenarios ---

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Buddy Jr
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Goldie

  Scenario: List pets with pagination - beyond last page returns empty content
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # --- Delete and cleanup ---

  Scenario: Delete pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
