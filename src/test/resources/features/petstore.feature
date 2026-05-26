Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And http response body path $.status should be available
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat

  Scenario: Create a third pet
    When I set http body to {"id":"3","name":"Rex","species":"Dog","breed":"German Shepherd","age":5,"status":"sold"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Rex
    And http response body path $.status should be sold

  Scenario: Create pet from fixture file
    And I set http body with file fixtures/valid-pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 4
    And http response body path $.name should be Nemo
    And http response body path $.species should be Fish
    And http response body path $.breed should be Clownfish
    And http response body path $.age should be 1
    And http response body path $.status should be available

  Scenario: Create pet with missing name - validation error
    When I set http body to {"id":"99","species":"Dog","breed":"Labrador","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be name is required

  Scenario: Create pet with empty name - validation error
    When I set http body to {"id":"98","name":"","species":"Cat","age":2,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be name is required

  Scenario: Create pet with missing species - validation error
    When I set http body to {"id":"97","name":"NoSpecies","breed":"Unknown","age":1,"status":"available"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.message should be species is required

  Scenario: Create duplicate pet - conflict
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":3,"status":"available"}
    And I POST /pets
    Then http response code should be 409
    And http response body path $.message should be pet already exists

  Scenario: Get pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3

  Scenario: Get non-existent pet
    When I GET /pets/99999
    Then http response code should be 404

  Scenario: Update pet
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":4,"status":"sold"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be sold
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4
    And http response body path $.status should be sold

  Scenario: Update non-existent pet
    When I set http body to {"id":"99999","name":"Ghost","species":"Unknown","age":0,"status":"available"}
    And I PUT /pets/99999
    Then http response code should be 404

  Scenario: Patch pet name
    When I set http body to {"name":"Buddy Jr"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr
    And http response body path $.species should be Dog
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr

  Scenario: Patch non-existent pet
    When I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 4
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Buddy Jr
    And http response body path $.[1].id should be 2
    And http response body path $.[2].id should be 3
    And http response body path $.[3].id should be 4
    And http response body should contain Whiskers

  Scenario: List pets filtered by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 2
    And http response body path $.[0].name should be Whiskers
    And http response body path $.[1].name should be Nemo

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body path $.page should be 1
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 3
    And http response body path $.content.[1].id should be 4

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body is typed as array using path $.content with length 0

  Scenario: Delete pet
    When I DELETE /pets/1
    Then http response code should be 200

  Scenario: Delete non-existent pet
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Verify deletion and cleanup
    When I GET /pets/1
    Then http response code should be 404
    When I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    And I DELETE /pets/4
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
