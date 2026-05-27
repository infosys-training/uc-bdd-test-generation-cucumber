Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept       | application/json |
      | Content-Type | application/json |

  Scenario: Create a pet successfully
    When I set http body to {"name":"Buddy","status":"available","category":"dog","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should exists
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a pet using fixture file
    And I set http body with file fixtures/new-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.name should be Max
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["loyal"]
    And I store the value of http body path $.id as petId2 in scenario scope

  Scenario: Create a third pet for pagination testing
    When I set http body to {"name":"Whiskers","status":"pending","category":"cat","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And I store the value of http body path $.id as petId3 in scenario scope

  Scenario: Create pet with missing name should fail validation
    When I set http body to {"status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet name is required

  Scenario: Create pet with missing status should fail validation
    When I set http body to {"name":"Rex","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.message should be Pet status is required

  Scenario: Get pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update pet successfully
    When I set http body to {"name":"Buddy Updated","status":"sold","category":"dog","tags":["friendly"]}
    And I PUT /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly"]

  Scenario: Verify updated pet persisted
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  Scenario: Update non-existent pet returns 404
    When I set http body to {"name":"Ghost","status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Update pet with missing name should fail validation
    When I set http body to {"status":"available"}
    And I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body path $.message should be Pet name is required

  Scenario: Update pet with missing status should fail validation
    When I set http body to {"name":"Buddy"}
    And I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body path $.message should be Pet status is required

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 3

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

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1

  Scenario: Delete pet successfully
    When I DELETE /pets/`$petId`
    Then http response code should be 200

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Clean up remaining pets
    When I DELETE /pets/`$petId2`
    Then http response code should be 200
    When I DELETE /pets/`$petId3`
    Then http response code should be 200
    When I GET /pets
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
