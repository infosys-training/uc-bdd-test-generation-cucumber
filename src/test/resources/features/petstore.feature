Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":"3"}
    And I POST /pets
    Then http response code should be 201
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet successfully
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":"5"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat
    And http response body path $.breed should be Siamese
    And http response body path $.age should be 5

  Scenario: Create a third pet for pagination tests
    When I set http body to {"id":"3","name":"Rex","species":"Dog","breed":"German Shepherd","age":"2"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Rex

  Scenario: Create pet with missing name returns validation error
    When I set http body to {"id":"99","species":"Dog","breed":"Poodle","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required

  Scenario: Create pet with missing species returns validation error
    When I set http body to {"id":"99","name":"NoSpecies","breed":"Unknown","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body path $.fields.species should be Species is required

  Scenario: Create pet with all required fields missing returns validation error
    When I set http body to {"id":"99","breed":"Unknown","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required
    And http response body path $.fields.species should be Species is required

  Scenario: Read a pet by id
    When I GET /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.age should be 3

  Scenario: Read a non-existent pet returns 404
    When I GET /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"Dog","breed":"Golden Retriever","age":"4"}
    And I PUT /pets/1
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.age should be 4
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 4

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"999","name":"Ghost","species":"Cat","breed":"Unknown","age":"1"}
    And I PUT /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a pet with missing required fields returns validation error
    When I set http body to {"id":"1","breed":"Golden Retriever","age":"4"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body path $.fields.name should be Name is required
    And http response body path $.fields.species should be Species is required

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be `$petId`
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].name should be Rex

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
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Rex

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 5
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 0

  Scenario: Delete a pet successfully
    When I DELETE /pets/1
    Then http response code should be 200
    When I GET /pets/1
    Then http response code should be 404

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete remaining pets and verify empty list
    When I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
