@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"3","status":"available","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope
    And http value of scenario variable petId should be 1

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"2","status":"available","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Create a pet with missing name returns validation error
    When I set http body to {"id":"99","species":"dog","breed":"Poodle","age":"1","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.name should be name is required

  Scenario: Create a pet with missing species returns validation error
    When I set http body to {"id":"98","name":"NoSpecies","breed":"Unknown","age":"2","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.species should be species is required

  Scenario: Create a pet with all required fields missing returns validation errors
    When I set http body to {"id":"97","breed":"Unknown","age":"1","status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.name should be name is required
    And http response body path $.species should be species is required

  Scenario: Read a pet by id
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Read a pet that does not exist returns 404
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"4","status":"adopted","tags":["friendly","vaccinated","adopted"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be adopted

  Scenario: Update a pet that does not exist returns 404
    When I set http body to {"id":"888","name":"Ghost","species":"cat","breed":"Persian","age":"3","status":"available"}
    And I PUT /pets/888
    Then http response code should be 404

  Scenario: Update a pet with missing required fields returns validation error
    When I set http body to {"id":"1","breed":"Labrador","age":"4","status":"available"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.name should be name is required
    And http response body path $.species should be species is required

  Scenario: Patch a pet status
    When I set http body to {"status":"pending"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.status should be pending
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.status should be pending

  Scenario: Patch a pet that does not exist returns 404
    When I set http body to {"status":"adopted"}
    And I PATCH /pets/777
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be `$petId`
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].name should be Max
    And http response body should contain Siamese

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Max
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0

  Scenario: Delete a pet that does not exist returns 404
    When I DELETE /pets/999
    Then http response code should be 404

  Scenario: Delete a pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    And I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
