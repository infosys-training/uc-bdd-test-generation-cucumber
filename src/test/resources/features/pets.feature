@pet
Feature: Petstore API - Pets CRUD operations

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ---------- Create ----------

  Scenario: Create a pet successfully
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"5","tags":["friendly","vaccinated"]}
    And I POST /pets
    Then http response code should be 201
    And http response body should be valid json
    And http response body path $.id should be 1
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5
    And http response body path $.status should be available
    And http response body path $.tags should be ["friendly","vaccinated"]
    And I store the value of http body path $.id as petId in scenario scope

  Scenario: Create a second pet
    When I set http body to {"id":"2","name":"Whiskers","species":"cat","breed":"Siamese","age":"3","status":"adopted","tags":["indoor"]}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 2
    And http response body path $.name should be Whiskers
    And http response body path $.species should be cat
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["indoor"]

  Scenario: Create a pet from fixture file
    When I set http body with file fixtures/golden-retriever.pet.json
    And I POST /pets
    Then http response code should be 201
    And http response body path $.id should be 3
    And http response body path $.name should be Charlie
    And http response body path $.species should be dog
    And http response body path $.breed should be Golden Retriever
    And http response body path $.tags should be ["friendly","trained"]

  # ---------- Validation Errors ----------

  Scenario: Create a pet without name should fail
    When I set http body to {"id":"99","species":"dog","breed":"Poodle","age":"2"}
    And I POST /pets
    Then http response code should be 400
    And http response body should be valid json
    And http response body path $.error should be name is required

  Scenario: Create a pet without species should fail
    When I set http body to {"id":"98","name":"NoSpecies","breed":"Unknown","age":"1"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be species is required

  Scenario: Create a duplicate pet should fail
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"5"}
    And I POST /pets
    Then http response code should be 400
    And http response body path $.error should be pet with this id already exists

  # ---------- Read ----------

  Scenario: Get a pet by id
    When I GET /pets/1
    Then http response code should be 200
    And http response body should be valid json
    And http response header Content-Type should be application/json
    And http response body path $.id should be `$petId`
    And http response body path $.name should be Buddy
    And http response body path $.species should be dog
    And http response body path $.breed should be Labrador
    And http response body path $.age should be 5

  # ---------- Not Found ----------

  Scenario: Get a non-existent pet returns 404
    When I GET /pets/99999
    Then http response code should be 404
    And http response body path $ should not have content

  # ---------- List ----------

  Scenario: List all pets
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array for path $
    And http response body is typed as array using path $ with length 3
    And http response body path $.[0].id should be 1
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].id should be 2
    And http response body path $.[1].name should be Whiskers
    And http response body path $.[2].id should be 3
    And http response body path $.[2].name should be Charlie

  Scenario: Filter pets by status
    And I set http query parameter status to adopted
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 1
    And http response body path $.[0].name should be Whiskers
    And http response body path $.[0].status should be adopted

  Scenario: Filter pets by species
    And I set http query parameter species to dog
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 2
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].name should be Charlie

  Scenario: Filter with no matching results
    And I set http query parameter status to sold
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content

  # ---------- Pagination ----------

  Scenario: Paginate pets - first page
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 2
    And http response body path $.[0].name should be Buddy
    And http response body path $.[1].name should be Whiskers
    And http response header X-Total-Count should be 3
    And http response header X-Page should be 0
    And http response header X-Page-Size should be 2

  Scenario: Paginate pets - second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 1
    And http response body path $.[0].name should be Charlie
    And http response header X-Total-Count should be 3
    And http response header X-Page should be 1

  Scenario: Paginate pets - beyond last page
    And I set http query parameter page to 5
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
    And http response header X-Total-Count should be 3

  # ---------- Update ----------

  Scenario: Update a pet
    When I set http body to {"id":"1","name":"Buddy","species":"dog","breed":"Labrador","age":"6","status":"adopted","tags":["friendly","senior"]}
    And I PUT /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be adopted
    And http response body path $.tags should be ["friendly","senior"]
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.age should be 6
    And http response body path $.status should be adopted

  Scenario: Update a pet without name should fail
    When I set http body to {"id":"1","species":"dog","breed":"Labrador","age":"6"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be name is required

  Scenario: Update a pet without species should fail
    When I set http body to {"id":"1","name":"Buddy","breed":"Labrador","age":"6"}
    And I PUT /pets/1
    Then http response code should be 400
    And http response body path $.error should be species is required

  Scenario: Update a non-existent pet returns 404
    When I set http body to {"id":"99999","name":"Ghost","species":"dog","breed":"Unknown","age":"1"}
    And I PUT /pets/99999
    Then http response code should be 404

  # ---------- Patch ----------

  Scenario: Patch a pet name
    When I set http body to {"name":"Buddy Jr."}
    And I PATCH /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr.
    And http response body path $.species should be dog
    When I GET /pets/1
    Then http response code should be 200
    And http response body path $.name should be Buddy Jr.

  Scenario: Patch a pet status
    When I set http body to {"status":"sold"}
    And I PATCH /pets/2
    Then http response code should be 200
    And http response body path $.status should be sold

  Scenario: Patch a non-existent pet returns 404
    When I set http body to {"name":"Ghost"}
    And I PATCH /pets/99999
    Then http response code should be 404

  # ---------- Delete ----------

  Scenario: Delete a non-existent pet returns 404
    When I DELETE /pets/99999
    Then http response code should be 404

  Scenario: Delete all pets
    When I DELETE /pets/1
    Then http response code should be 200
    And I DELETE /pets/2
    Then http response code should be 200
    And I DELETE /pets/3
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $ with length 0
    And http response body path $ should not have content
