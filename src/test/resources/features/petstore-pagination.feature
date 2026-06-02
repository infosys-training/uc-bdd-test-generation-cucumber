@petstore
Feature: Petstore pagination tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
      | Accept        | application/json  |
      | Content-Type  | application/json  |
    And the petstore has the following pets:
      | id | name     | status    | category |
      | 1  | Buddy    | available | dog      |
      | 2  | Whiskers | sold      | cat      |
      | 3  | Tweety   | available | bird     |
      | 4  | Goldie   | pending   | fish     |
      | 5  | Rex      | available | dog      |

  Scenario: First page of pets
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body path $.content.[0].name should be Buddy
    And http response body path $.content.[1].name should be Whiskers

  Scenario: Second page of pets
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.page should be 1
    And http response body path $.totalPages should be 3
    And http response body path $.content.[0].name should be Tweety
    And http response body path $.content.[1].name should be Goldie

  Scenario: Last page of pets with partial results
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 1
    And http response body path $.page should be 2
    And http response body path $.totalPages should be 3
    And http response body path $.content.[0].name should be Rex

  Scenario: Page beyond available data returns empty content
    And I set http query parameter page to 10
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 0
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3

  Scenario: Pagination combined with status filter
    And I set http query parameter status to available
    And I set http query parameter page to 0
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 2
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 2

  Scenario: Single large page returns all pets
    And I set http query parameter page to 0
    And I set http query parameter size to 100
    When I GET /pets
    Then http response code should be 200
    And http response body is typed as array using path $.content with length 5
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 1
