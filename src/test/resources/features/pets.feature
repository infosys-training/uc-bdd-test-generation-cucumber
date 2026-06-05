@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept       | application/json |
      | Content-Type | application/json |

  # ── CREATE ──────────────────────────────────────────────

  Scenario: Create a pet successfully
    And I set http body to {"name":"Buddy","species":"dog","status":"available","tag":"golden-retriever"}
    When I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should exists
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.status should be available
    And http response body path $.tag should be golden-retriever
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    And I set http body to {"name":"Whiskers","species":"cat","status":"available","tag":"tabby"}
    When I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And I store the value of http body path $.id as petId2 in scenario scope

  Scenario: Create pet fails - missing name
    And I set http body to {"species":"dog","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body should contain name

  Scenario: Create pet fails - missing species
    And I set http body to {"name":"Rex","status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body should contain species

  Scenario: Create pet fails - missing name and species
    And I set http body to {"status":"available"}
    When I POST /pets
    Then http response code should be 400
    And http response body should be valid json

  # ── READ ────────────────────────────────────────────────

  Scenario: Get pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog

  Scenario: Get pet returns 404 for unknown ID
    When I GET /pets/999999
    Then http response code should be 404
    And http response body should be valid json
    And http response body should contain not found

  # ── UPDATE ──────────────────────────────────────────────

  Scenario: Update pet successfully
    And I set http body to {"name":"Buddy Jr","species":"dog","status":"adopted","tag":"golden-retriever"}
    When I PUT /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be adopted
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.status should be adopted

  Scenario: Update pet fails - not found
    And I set http body to {"name":"Ghost","species":"dog","status":"available"}
    When I PUT /pets/999999
    Then http response code should be 404

  Scenario: Update pet fails - missing required fields
    And I set http body to {"status":"adopted"}
    When I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body should contain name

  # ── LIST / PAGINATION ───────────────────────────────────

  Scenario: List all pets (default pagination)
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 2
    And http response body is typed as array for path $.content

  Scenario: List pets with page size 1 - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 1
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1

  Scenario: List pets with page size 1 - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body is typed as array using path $.content with length 1

  Scenario: List pets - page beyond range returns empty
    And I set http query parameter page to 100
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 2

  # ── DELETE ──────────────────────────────────────────────

  Scenario: Delete pet fails - not found
    When I DELETE /pets/999999
    Then http response code should be 404

  Scenario: Delete pet successfully
    When I DELETE /pets/`$petId`
    Then http response code should be 200
    When I GET /pets/`$petId`
    Then http response code should be 404

  Scenario: Delete second pet and verify list is empty
    When I DELETE /pets/`$petId2`
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
