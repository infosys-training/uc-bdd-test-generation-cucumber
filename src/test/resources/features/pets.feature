@pet
Feature: Petstore API tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ==========================================
  # Successful CRUD Operations
  # ==========================================

  Scenario: Create a new pet - Max the Labrador
    When I set http body to {"id":"1","name":"Max","species":"dog","breed":"Labrador","age":"5","status":"available","tags":["friendly","vaccinated"]}
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

  Scenario: Create a second pet - Whiskers the Cat
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"3","status":"available","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.breed should be Siamese
    And http response body path $.age should be 3
    And http response body path $.status should be available

  Scenario: Create a pet using a fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.tags should be ["friendly","trained"]

  Scenario: Create a pet with pending status
    When I set http body to {"id":"4","name":"Tweety","species":"bird","breed":"Canary","age":"1","status":"pending","tags":["singing"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.status should be pending

  Scenario: Create a pet with default status
    When I set http body to {"id":"5","name":"Nemo","species":"fish","breed":"Clownfish","age":"2"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.status should be available

  Scenario: Read a pet by ID
    When I GET /pets/`$petId`
    Then http response code should be 200
    And http response header Content-Type should be application/json
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Max
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5

  Scenario: Read the second pet by ID
    When I GET /pets/2
    Then http response code should be 200
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat

  Scenario: Update a pet
    When I set http body with file fixtures/updated-pet.json
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.name should be Max Senior
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 8
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["senior","calm"]

  Scenario: Verify updated pet is persisted
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Max Senior
    And http response body path $.age should be 8
    And http response body path $.status should be adopted

  Scenario: Delete a pet
    When I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets/3
    Then http response code should be 404

  # ==========================================
  # Validation Errors (Missing Required Fields)
  # ==========================================

  Scenario: Create a pet without name should fail validation
    When I set http body to {"id":"100","species":"dog","breed":"Poodle","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.field should be name
    And http response body path $.message should be Name is required

  Scenario: Create a pet without species should fail validation
    When I set http body to {"id":"101","name":"Rex","breed":"Shepherd","age":"4"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.field should be species
    And http response body path $.message should be Species is required

  Scenario: Create a pet with empty name should fail validation
    When I set http body to {"id":"102","name":"","species":"cat","breed":"Persian","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.field should be name
    And http response body path $.message should be Name is required

  Scenario: Create a pet with duplicate ID should return conflict
    When I set http body to {"id":"2","name":"Duplicate","species":"dog","breed":"Beagle","age":"1"}
    And I POST /pets
    Then http response code should be 409
    And http response body path $.field should be id
    And http response body path $.message should be Pet with this ID already exists

  Scenario: Update a pet without name should fail validation
    When I set http body to {"id":"2","species":"cat","breed":"Siamese","age":"4"}
    And I PUT /pets/2
    Then http response code should be 400
    And http response body path $.field should be name
    And http response body path $.message should be Name is required

  # ==========================================
  # Not-Found Cases
  # ==========================================

  Scenario: Get a non-existent pet should return 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Update a non-existent pet should return 404
    When I set http body to {"id":"99999","name":"Ghost","species":"cat","breed":"Unknown","age":"1"}
    And I PUT /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  Scenario: Delete a non-existent pet should return 404
    When I DELETE /pets/99999
    Then http response code should be 404

  # ==========================================
  # List and Pagination
  # ==========================================

  Scenario: List all pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.totalElements should be 4
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalPages should be 1
    And http response body is typed as array for path $.content
    And http response body is typed as array using path $.content with length 4

  Scenario: List pets with pagination - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: List pets with pagination - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 4
    And http response body path $.content.[1].id should be 5

  Scenario: List pets with pagination - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 4
    And http response body path $.totalPages should be 2
    And http response body is typed as array using path $.content with length 0

  Scenario: Filter pets by status
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body path $.content.[0].status should be available

  Scenario: Filter pets by non-existent status
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0

  # ==========================================
  # Cleanup
  # ==========================================

  Scenario: Cleanup - Delete remaining pets
    When I DELETE /pets/1
    Then http response code should be 200
    When I DELETE /pets/2
    Then http response code should be 200
    When I DELETE /pets/4
    Then http response code should be 200
    When I DELETE /pets/5
    Then http response code should be 200
    When I GET /pets
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
