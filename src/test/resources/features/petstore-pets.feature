@petstore
Feature: Petstore API - Pets CRUD operations

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ---------------------------------------------------------------------------
  # Successful CRUD operations
  # ---------------------------------------------------------------------------

  Scenario: Create a pet - available dog
    When I set http body to {"name":"Buddy","status":"available","category":"dog","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId1 in scenario scope

  Scenario: Create a pet - pending cat
    When I set http body to {"name":"Whiskers","status":"pending","category":"cat","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat
    And I store the value of http body path $.id as petId2 in scenario scope

  Scenario: Create a pet - sold bird
    When I set http body to {"name":"Tweety","status":"sold","category":"bird"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Tweety
    And http response body path $.status should be sold
    And I store the value of http body path $.id as petId3 in scenario scope

  Scenario: Create a pet - minimal fields
    When I set http body to {"name":"Rex","status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Rex
    And http response body path $.status should be available
    And http response body path $.category should not exist
    And I store the value of http body path $.id as petId4 in scenario scope

  Scenario: Read a pet by id
    When I GET /pets/`$petId1`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Update a pet
    When I set http body to {"name":"Buddy Jr","status":"sold","category":"dog","tags":["friendly"]}
    And I PUT /pets/`$petId1`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly"]
    When I GET /pets/`$petId1`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold

  Scenario: Delete a pet
    When I DELETE /pets/`$petId4`
    Then http response code should be 200
    And http response body path $.message should be Pet deleted

  Scenario: List all pets after deletion
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Buddy Jr
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].name should be Tweety

  # ---------------------------------------------------------------------------
  # Validation errors - missing required fields
  # ---------------------------------------------------------------------------

  Scenario: Create a pet - missing name returns 400
    When I set http body to {"status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be name is required

  Scenario: Create a pet - empty name returns 400
    When I set http body to {"name":"","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Create a pet - missing status returns 400
    When I set http body to {"name":"Fido"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be status is required

  Scenario: Update a pet - missing name returns 400
    When I set http body to {"status":"available"}
    And I PUT /pets/`$petId1`
    Then http response code should be 400
    And http response body path $.error should be name is required

  # ---------------------------------------------------------------------------
  # Not-found cases
  # ---------------------------------------------------------------------------

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body should be valid json
    And http response body path $.error should be Pet not found

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"name":"Ghost","status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $.error should be Pet not found

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $.error should be Pet not found

  # ---------------------------------------------------------------------------
  # Pagination
  # ---------------------------------------------------------------------------

  Scenario: List pets - default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 1
    And http response body is typed as array using path $.content with length 3

  Scenario: List pets - custom page size
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Buddy Jr
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets - second page
    And I set http query parameter size to 2
    And I set http query parameter page to 1
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Tweety

  Scenario: List pets - page beyond available data
    And I set http query parameter page to 5
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0

  Scenario: List pets - filter by status
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Buddy Jr
    And http response body path $.content.[1].name should be Tweety

  Scenario: List pets - filter by status with no results
    And I set http query parameter status to unknown
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0

  # ---------------------------------------------------------------------------
  # Cleanup
  # ---------------------------------------------------------------------------

  Scenario: Cleanup - delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
