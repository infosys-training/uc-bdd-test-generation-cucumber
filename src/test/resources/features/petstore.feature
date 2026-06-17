Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # -------------------------------------------------------------------
  # CRUD - Create
  # -------------------------------------------------------------------

  Scenario: Create a new pet successfully
    When I set http body to {"name":"Buddy","category":"dog","status":"available","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should exists
    And http response body path $.name should be Buddy
    And http response body path $.category should be dog
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet using a fixture file
    When I set http body with file fixtures/new-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Rex
    And http response body path $.category should be dog
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as secondPetId in scenario scope

  Scenario: Create a pet with minimal fields
    When I set http body to {"name":"Whiskers","category":"cat","status":"sold"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.name should be Whiskers
    And http response body path $.category should be cat
    And http response body path $.status should be sold
    And I store the value of http body path $.id as thirdPetId in scenario scope

  # -------------------------------------------------------------------
  # CRUD - Read
  # -------------------------------------------------------------------

  Scenario: Get a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.category should be dog
    And http response body path $.status should be available

  Scenario: Get the second pet by ID
    When I GET /pets/`$secondPetId`
    Then http response code should be 200
    And http response body path $.name should be Rex
    And http response body path $.category should be dog

  # -------------------------------------------------------------------
  # CRUD - Update
  # -------------------------------------------------------------------

  Scenario: Update a pet successfully
    When I set http body to {"name":"Buddy Updated","category":"dog","status":"sold","tags":["friendly","senior"]}
    And I PUT /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold
    And http response body path $.tags should be ["friendly","senior"]
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  # -------------------------------------------------------------------
  # CRUD - List
  # -------------------------------------------------------------------

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Buddy Updated
    And http response body path $.content.[1].name should be Rex
    And http response body path $.content.[2].name should be Whiskers
    And http response body path $.totalElements should be 3

  Scenario: List pets filtered by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Rex
    And http response body path $.totalElements should be 1

  # -------------------------------------------------------------------
  # Pagination
  # -------------------------------------------------------------------

  Scenario: Paginate pets - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].name should be Buddy Updated
    And http response body path $.content.[1].name should be Rex

  Scenario: Paginate pets - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].name should be Whiskers

  Scenario: Paginate pets - empty page beyond data
    And I set http query parameter page to 5
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body path $.content should not have content
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 1

  # -------------------------------------------------------------------
  # Validation errors
  # -------------------------------------------------------------------

  Scenario: Create a pet without a name returns validation error
    When I set http body to {"category":"bird","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be Name is required

  Scenario: Create a pet without a status returns validation error
    When I set http body to {"name":"Polly","category":"bird"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.status should be Status is required

  Scenario: Create a pet with no required fields returns multiple errors
    When I set http body to {"category":"fish"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be Name is required
    And http response body path $.status should be Status is required

  Scenario: Update a pet with missing name returns validation error
    When I set http body to {"category":"dog","status":"available"}
    And I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body path $.name should be Name is required

  Scenario: Update a pet with missing status returns validation error
    When I set http body to {"name":"Buddy","category":"dog"}
    And I PUT /pets/`$petId`
    Then http response code should be 400
    And http response body path $.status should be Status is required

  # -------------------------------------------------------------------
  # Not found cases
  # -------------------------------------------------------------------

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"name":"Ghost","category":"unknown","status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # -------------------------------------------------------------------
  # CRUD - Delete
  # -------------------------------------------------------------------

  Scenario: Delete a pet successfully
    When I DELETE /pets/`$petId`
    Then http response code should be 204
    When I GET /pets/`$petId`
    Then http response code should be 404

  Scenario: Delete remaining pets
    When I DELETE /pets/`$secondPetId`
    Then http response code should be 204
    When I DELETE /pets/`$thirdPetId`
    Then http response code should be 204
    When I GET /pets
    Then http response code should be 200
    And http response body path $.content should not have content
    And http response body path $.totalElements should be 0
