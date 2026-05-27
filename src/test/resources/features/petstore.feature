@petstore
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |

  # ---------- Setup ----------

  Scenario: Reset petstore
    Given the petstore is empty

  # ---------- Successful CRUD operations ----------

  Scenario: Create a pet successfully
    When I set http body to {"name":"Buddy","status":"available","category":"dog","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response header Content-Type should be application/json
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
    And http response body path $.name should be Luna
    And http response body path $.status should be available
    And http response body path $.category should be cat
    And http response body path $.tags should be ["gentle","indoor"]
    And I store the value of http body path $.id as petId2 in scenario scope

  Scenario: Create a third pet
    When I set http body to {"name":"Rex","status":"pending","category":"dog","tags":["guard"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Rex
    And http response body path $.status should be pending
    And I store the value of http body path $.id as petId3 in scenario scope

  Scenario: Read a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Update a pet successfully
    When I set http body to {"name":"Buddy Jr","status":"sold","category":"dog","tags":["friendly"]}
    And I PUT /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly"]

  Scenario: Verify pet update persisted
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be sold

  # ---------- Validation errors ----------

  Scenario: Create pet without name returns validation error
    When I set http body to {"status":"available","category":"cat"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be name is required

  Scenario: Create pet with empty name returns validation error
    When I set http body to {"name":"","status":"available","category":"bird"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Update pet without name returns validation error
    When I set http body to {"status":"pending","category":"dog"}
    And I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body path $.error should be name is required

  # ---------- Not-found cases ----------

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    When I set http body to {"name":"Ghost","status":"available","category":"cat"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  # ---------- Pagination ----------

  Scenario: List pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalPages should be 1
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Buddy Jr

  Scenario: List pets with custom page size
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2

  Scenario: List pets on second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1

  Scenario: List pets beyond last page returns empty content
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  # ---------- Delete ----------

  Scenario: Delete a pet successfully
    When I DELETE /pets/`$petId`
    Then http response code should be 200
    When I GET /pets/`$petId`
    Then http response code should be 404

  @petstore-cleanup
  Scenario: Cleanup remaining pets
    When I DELETE /pets/`$petId2`
    Then http response code should be 200
    When I DELETE /pets/`$petId3`
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body path $.content should not have content
