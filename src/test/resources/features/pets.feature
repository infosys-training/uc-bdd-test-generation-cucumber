Feature: Petstore REST API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # =========================================
  # CREATE PET - Successful scenarios
  # =========================================

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","status":"available","category":"dog","tags":["friendly","trained"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","status":"pending","category":"cat","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending
    And http response body path $.category should be cat

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Golden Retriever
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","large"]

  # =========================================
  # CREATE PET - Validation error scenarios
  # =========================================

  Scenario: Create a pet without name should fail validation
    When I set http body to {"id":"99","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.status should be 400
    And http response body path $.message should be Validation failed
    And http response body path $.errors.[0] should be name is required

  Scenario: Create a pet without status should fail validation
    When I set http body to {"id":"98","name":"NoStatus","category":"cat"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.status should be 400
    And http response body path $.message should be Validation failed
    And http response body path $.errors.[0] should be status is required

  Scenario: Create a pet without name and status should fail validation
    When I set http body to {"id":"97","category":"bird"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body is typed as array for path $.errors
    And http response body is typed as array using path $.errors with length 2

  # =========================================
  # READ PET - Successful scenarios
  # =========================================

  Scenario: Get a pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.status should be available
    And http response body path $.category should be dog
    And http response body path $.tags should be ["friendly","trained"]
    And I store the value of http body path $.name as petName in scenario scope
    And http value of scenario variable petName should be Buddy

  Scenario: Get the second pet by ID
    When I GET /pets/2
    Then http response code should be 200
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.status should be pending

  # =========================================
  # READ PET - Not found scenarios
  # =========================================

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $.status should be 404
    And http response body path $.message should be Not found
    And http response body path $.errors.[0] should be Pet with id 999 not found

  Scenario: Get another non-existent pet returns 404
    When I GET /pets/unknown-id
    Then http response code should be 404
    And http response body path $.message should be Not found

  # =========================================
  # UPDATE PET - Successful scenarios
  # =========================================

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy Updated","status":"sold","category":"dog","tags":["trained"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold
    And http response body path $.tags should be ["trained"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Updated
    And http response body path $.status should be sold

  # =========================================
  # UPDATE PET - Validation error scenarios
  # =========================================

  Scenario: Update a pet without required fields should fail validation
    When I set http body to {"id":"1","category":"dog"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.message should be Validation failed
    And http response body is typed as array using path $.errors with length 2

  # =========================================
  # UPDATE PET - Not found scenarios
  # =========================================

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"888","name":"Ghost","status":"available"}
    And I PUT /pets/888
    Then http response code should be 404
    And http response body path $.status should be 404
    And http response body path $.message should be Not found
    And http response body path $.errors.[0] should be Pet with id 888 not found

  # =========================================
  # LIST PETS - Successful scenarios
  # =========================================

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 3
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[0].name should be Buddy Updated
    And http response body path $.content.[1].id should be 2
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].id should be 3

  # =========================================
  # LIST PETS - Pagination scenarios
  # =========================================

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 3

  Scenario: List pets with pagination - page beyond available data
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 0

  Scenario: List pets filtered by status
    And I set http query parameter status to pending
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 1
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Whiskers
    And http response body path $.content.[0].status should be pending

  # =========================================
  # DELETE PET - Successful scenarios
  # =========================================

  Scenario: Delete a pet successfully
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets/2
    Then http response code should be 404

  # =========================================
  # DELETE PET - Not found scenarios
  # =========================================

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/999
    Then http response code should be 404
    And http response body path $.status should be 404
    And http response body path $.message should be Not found
    And http response body path $.errors.[0] should be Pet with id 999 not found

  # =========================================
  # CLEANUP - Delete remaining pets
  # =========================================

  Scenario: Delete remaining pets and verify empty list
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
