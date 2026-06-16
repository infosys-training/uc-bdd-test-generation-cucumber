@pet
Feature: Petstore advanced scenarios

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  # ==========================================
  # Scenarios using domain-specific steps
  # ==========================================

  Scenario: List pets when store is empty
    Given the pet store is empty
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0

  Scenario: List pets with pre-populated store
    Given the pet store has 5 pets
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 5
    And http response body is typed as array using path $.content with length 5
    And http response body path $.content.[0].name should be Pet-1
    And http response body path $.content.[4].name should be Pet-5

  Scenario: Paginate through pre-populated store
    Given the pet store has 5 pets
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].id should be 1
    And http response body path $.content.[1].id should be 2

  Scenario: Get last page of paginated results
    Given the pet store has 5 pets
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].id should be 5

  Scenario: Filter by status in pre-populated store
    Given the pet store has 5 pets
    And I set http query parameter status to pending
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 1
    And http response body path $.content.[0].id should be 3

  Scenario: Create and verify pet exists in store
    Given the pet store is empty
    When I set http body to {"id":"10","name":"Luna","species":"cat","breed":"Maine Coon","age":"2","status":"available","tags":["fluffy"]}
    And I POST /pets
    Then http response code should be 201
    And the pet store should contain 1 pets
    And the pet store should contain a pet with id 10

  Scenario: Delete and verify pet removed from store
    Given the pet store is empty
    And the pet store has a pet with id 20 and name Rocky
    When I DELETE /pets/20
    Then http response code should be 200
    And the pet store should contain 0 pets
    And the pet store should not contain a pet with id 20

  Scenario: Combined pagination and status filter
    Given the pet store has 5 pets
    And I set http query parameter status to available
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].status should be available
    And http response body path $.content.[1].status should be available

  Scenario: Cleanup after advanced tests
    Given the pet store is empty
    Then the pet store should contain 0 pets
