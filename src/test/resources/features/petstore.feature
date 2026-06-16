Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ---------------------
  # Successful CRUD
  # ---------------------

  Scenario: Create a new pet
    When I set http body to {"id":"1","name":"Max","species":"Dog","breed":"Labrador","age":"5","status":"available","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be Dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"Cat","breed":"Siamese","age":"3","status":"available","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be Cat

  Scenario: Create a pet from fixture file
    And I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.species should be Dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Read a single pet by ID
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be Dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Max
    And http response body path $.content.[1].name should be Whiskers
    And http response body path $.content.[2].name should be Buddy
    And http response body path $.totalElements should be 3

  Scenario: Update a pet
    When I set http body to {"id":"1","name":"Max","species":"Dog","breed":"Labrador","age":"6","status":"pending","tags":["friendly","vaccinated"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be pending
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be pending

  Scenario: Patch a pet (partial update)
    When I set http body to {"name":"MaxUpdated","status":"sold"}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.name should be MaxUpdated
    And http response body path $.status should be sold
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be MaxUpdated
    And http response body path $.status should be sold

  Scenario: Delete a pet
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 2

  # ---------------------
  # Validation errors
  # ---------------------

  Scenario: Create pet without name should fail validation
    When I set http body to {"id":"90","species":"Dog","breed":"Poodle","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body is typed as array for path $.messages
    And http response body should contain name is required

  Scenario: Create pet without species should fail validation
    When I set http body to {"id":"91","name":"Rex","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body should contain species is required

  Scenario: Create pet without name and species should fail with multiple errors
    When I set http body to {"id":"92","breed":"Unknown","age":"4"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be Validation failed
    And http response body is typed as array using path $.messages with length 2
    And http response body should contain name is required
    And http response body should contain species is required

  Scenario: Update pet without required fields should fail validation
    When I set http body to {"id":"1","breed":"Labrador","age":"7"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be Validation failed
    And http response body should contain name is required
    And http response body should contain species is required

  # ---------------------
  # Not-found cases
  # ---------------------

  Scenario: Get non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","species":"Unknown","breed":"None","age":"0"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Patch non-existent pet returns 404
    When I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ---------------------
  # Pagination
  # ---------------------

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be MaxUpdated
    And http response body path $.page should be 0
    And http response body path $.size should be 1
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Whiskers
    And http response body path $.page should be 1
    And http response body path $.size should be 1
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 2

  Scenario: List pets with pagination - beyond last page returns empty
    And I set http query parameter page to 5
    And I set http query parameter size to 10
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content
    And http response body path $.totalElements should be 2
    And http response body path $.totalPages should be 1

  Scenario: Filter pets by status
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be MaxUpdated
    And http response body path $.content.[0].status should be sold

  # ---------------------
  # Cleanup
  # ---------------------

  Scenario: Cleanup - delete all remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I GET /pets
    And http response body is typed as array using path $.content with length 0
    And http response body path $.content should not have content
    And http response body path $.totalElements should be 0
