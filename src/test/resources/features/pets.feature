Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ---- Setup ----

  Scenario: Start with an empty petstore
    Given the petstore is empty
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0

  # ---- Create (successful) ----

  Scenario: Create a pet successfully
    When I set http body to {"name":"Buddy","species":"dog","age":3,"status":"available","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should exists
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"name":"Whiskers","species":"cat","age":2,"status":"pending"}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.age should be 2
    And http response body path $.status should be pending
    And I store the value of http body path $.id as secondPetId in scenario scope

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/pet-fido.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Fido
    And http response body path $.species should be dog
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as thirdPetId in scenario scope

  Scenario: Verify three pets were created
    Then the total pet count should be 3

  # ---- Create (validation errors) ----

  Scenario: Create a pet - missing required name field
    When I set http body to {"species":"dog","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create a pet - missing required species field
    When I set http body to {"name":"Rex","age":5,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be species is required

  Scenario: Create a pet - both required fields missing
    When I set http body to {"age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Verify validation did not add extra pets
    Then the total pet count should be 3

  # ---- Read ----

  Scenario: Get a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.age should be 3

  Scenario: Get the second pet by ID
    When I GET /pets/`$secondPetId`
    Then http response code should be 200
    And http response body path $.id should be `$secondPetId`
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Get a pet - not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ---- Update ----

  Scenario: Update a pet
    When I set http body to {"name":"Buddy Updated","species":"dog","age":4,"status":"sold"}
    And I PUT /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.age should be 4
    And http response body path $.status should be sold
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  Scenario: Update a pet - not found
    When I set http body to {"name":"Ghost","species":"ghost","age":0,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  # ---- List / Pagination ----

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 1
    And http response body path $.page should be 0

  Scenario: List pets - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.content.[0].name should be Buddy Updated
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1
    And http response body path $.content.[0].name should be Fido

  Scenario: List pets - page beyond range
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 3

  # ---- Delete ----

  Scenario: Delete a pet
    When I DELETE /pets/`$petId`
    Then http response code should be 200

  Scenario: Delete a pet - not found
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Verify pet was deleted
    When I GET /pets/`$petId`
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete remaining pets
    When I DELETE /pets/`$secondPetId`
    Then http response code should be 200
    And I DELETE /pets/`$thirdPetId`
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 0
