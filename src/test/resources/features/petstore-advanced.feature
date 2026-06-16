@petstore
Feature: Petstore advanced scenario tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Bulk setup and verify pets via data table
    Given the following pets exist:
      | id  | name     | species | breed          | age | status    |
      | 10  | Luna     | Cat     | Persian        | 2   | available |
      | 11  | Rocky    | Dog     | German Shepherd| 4   | available |
      | 12  | Nemo     | Fish    | Clownfish      | 1   | sold      |
    Then the petstore should contain 3 pets
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Luna
    And http response body path $.content.[1].name should be Rocky
    And http response body path $.content.[2].name should be Nemo

  Scenario: Verify pet status after patch
    Given the petstore is empty
    And the following pets exist:
      | id  | name     | species | breed    | age | status    |
      | 20  | Charlie  | Dog     | Beagle   | 3   | available |
    When I set http body to {"status":"sold"}
    And I PATCH /pets/20
    Then http response code should be 200
    And pet with id 20 should have status sold

  Scenario: Create duplicate pet should fail
    Given the petstore is empty
    When I set http body to {"id":"30","name":"Bella","species":"Cat","breed":"Maine Coon","age":"5","status":"available"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"id":"30","name":"Bella","species":"Cat","breed":"Maine Coon","age":"5","status":"available"}
    And I POST /pets
    Then http response code should be 400

  Scenario: Pet defaults to available status when not specified
    Given the petstore is empty
    When I set http body to {"id":"40","name":"Coco","species":"Parrot","breed":"Macaw","age":"10"}
    And I POST /pets
    Then http response code should be 201
    And http response body path $.status should be available
    And pet with id 40 should have status available

  Scenario: Pagination with filtered status
    Given the petstore is empty
    And the following pets exist:
      | id  | name     | species | breed           | age | status    |
      | 50  | Daisy    | Dog     | Poodle          | 2   | available |
      | 51  | Milo     | Cat     | Ragdoll         | 1   | sold      |
      | 52  | Oscar    | Dog     | Bulldog         | 5   | available |
      | 53  | Lily     | Cat     | British Shorthair| 3  | available |
    And I set http query parameter status to available
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2
    And http response body path $.content.[0].name should be Daisy
    And http response body path $.content.[1].name should be Oscar
