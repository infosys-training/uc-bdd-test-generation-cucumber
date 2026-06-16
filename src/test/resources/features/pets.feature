Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":5,"status":"available","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Persian","age":2,"status":"pending","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.breed should be Persian
    And http response body path $.age should be 2
    And http response body path $.status should be pending

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Create pet fails with missing name
    When I set http body to {"id":"99","species":"dog","breed":"Poodle","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.message should be Validation failed
    And http response body path $.errors.[0] should be name is required

  Scenario: Create pet fails with missing species
    When I set http body to {"id":"99","name":"Fido","breed":"Unknown","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.message should be Validation failed
    And http response body path $.errors.[0] should be species is required

  Scenario: Create pet fails with missing name and species
    When I set http body to {"id":"99","breed":"Unknown","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.message should be Validation failed
    And http response body is typed as array for path $.errors
    And http response body is typed as array using path $.errors with length 2

  Scenario: Create duplicate pet returns conflict
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":5,"status":"available"}
    And I POST /pets
    Then http response code should be 409

  Scenario: Get pet by id
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be dog

  Scenario: Get pet not found
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":6,"status":"adopted","tags":["friendly","vaccinated","neutered"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.age should be 6
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["friendly","vaccinated","neutered"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be adopted

  Scenario: Update pet fails with missing required fields
    When I set http body to {"id":"1","breed":"Labrador","age":6,"status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.message should be Validation failed

  Scenario: Update pet not found
    When I set http body to {"id":"999","name":"Ghost","species":"dog","breed":"Husky","age":3,"status":"available"}
    And I PUT /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Max
    And http response body path $.[1].id should be 2
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].id should be 3
    And http response body path $.[2].name should be Buddy

  Scenario: List pets filtered by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 1
    And http response body path $.[0].name should be Buddy

  Scenario: List pets filtered by status with no results
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content

  Scenario: Paginated list of pets - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Max
    And http response body path $.content.[1].name should be Whiskers

  Scenario: Paginated list of pets - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Buddy

  Scenario: Paginated list - page beyond available data
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content

  Scenario: Delete a pet successfully
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets/2
    Then http response code should be 404

  Scenario: Delete pet not found
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Verify final state after delete
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 2
    And http response body path $.[0].id should be 1
    And http response body path $.[1].id should be 3

  Scenario: Cleanup - delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
