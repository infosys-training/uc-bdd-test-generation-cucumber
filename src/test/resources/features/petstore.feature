Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ── Successful CRUD operations ──────────────────────────────────────

  Scenario: Reset pet store
    When I DELETE /pets
    Then http response code should be 200

  Scenario: Create a pet with inline JSON
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
    And I store the value of http body path $.id as buddyPetId in scenario scope

  Scenario: Create a pet from fixture file
    And I set http body with file fixtures/new-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Charlie
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as charliePetId in scenario scope

  Scenario: Create a third pet
    When I set http body to {"name":"Whiskers","status":"pending","category":"cat","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat
    And I store the value of http body path $.id as whiskersPetId in scenario scope

  Scenario: Read a pet by ID
    When I GET /pets/`$buddyPetId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$buddyPetId`
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.totalElements should be 3

  Scenario: Update a pet
    When I set http body to {"name":"Buddy Updated","status":"sold","category":"dog","tags":["friendly","trained","senior"]}
    And I PUT /pets/`$buddyPetId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly","trained","senior"]
    When I GET /pets/`$buddyPetId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  Scenario: Update a pet from fixture file
    And I set http body with file fixtures/update-pet.json
    And I PUT /pets/`$charliePetId`
    Then http response code should be 200
    And http response body path $.name should be Charlie Senior
    And http response body path $.status should be sold

  Scenario: Delete a pet
    When I DELETE /pets/`$whiskersPetId`
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 2

  # ── Validation errors ───────────────────────────────────────────────

  Scenario: Create a pet without name should fail validation
    When I set http body to {"status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fieldErrors.name should be Name is required

  Scenario: Create a pet with empty name should fail validation
    When I set http body to {"name":"","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fieldErrors.name should be Name is required

  Scenario: Create a pet with invalid status should fail validation
    When I set http body to {"name":"Rex","status":"unknown","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fieldErrors.status should be Invalid status. Allowed values: available, pending, sold

  Scenario: Update a pet without name should fail validation
    When I set http body to {"status":"available","category":"dog"}
    And I PUT /pets/`$buddyPetId`
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fieldErrors.name should be Name is required

  # ── Not-found cases ─────────────────────────────────────────────────

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"name":"Ghost","status":"available","category":"dog"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ── Cleanup ─────────────────────────────────────────────────────────

  Scenario: Clean up all remaining pets
    When I DELETE /pets/`$buddyPetId`
    Then http response code should be 200
    And I DELETE /pets/`$charliePetId`
    Then http response code should be 200
    When I GET /pets
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
