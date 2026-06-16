Feature: Petstore pagination tests

  Background:
    Given http baseUri is /api/
    And I set http headers to:
    | Accept        | application/json  |
    | Content-Type  | application/json  |

  Scenario: Seed pets for pagination
    When I DELETE /pets
    Then http response code should be 200
    When I set http body to {"name":"Pet-01","status":"available","category":"dog"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"name":"Pet-02","status":"available","category":"cat"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"name":"Pet-03","status":"pending","category":"bird"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"name":"Pet-04","status":"sold","category":"dog"}
    And I POST /pets
    Then http response code should be 201
    When I set http body to {"name":"Pet-05","status":"available","category":"cat"}
    And I POST /pets
    Then http response code should be 201

  Scenario: List pets with default pagination
    When I GET /pets
    Then http response code should be 200
    And http response body should be valid json
    And http response body path $.page should be 0
    And http response body path $.size should be 10
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 1
    And http response body is typed as array using path $.content with length 5

  Scenario: List pets with custom page size
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 0
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Pet-01
    And http response body path $.content.[1].name should be Pet-02

  Scenario: Navigate to second page
    And I set http query parameter page to 1
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 1
    And http response body path $.size should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 2
    And http response body path $.content.[0].name should be Pet-03
    And http response body path $.content.[1].name should be Pet-04

  Scenario: Navigate to last page with partial results
    And I set http query parameter page to 2
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.page should be 2
    And http response body path $.totalElements should be 5
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 1
    And http response body path $.content.[0].name should be Pet-05

  Scenario: Request page beyond available data returns empty content
    And I set http query parameter page to 10
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 5
    And http response body is typed as array using path $.content with length 0

  Scenario: Filter pets by status with pagination
    And I set http query parameter status to available
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 3
    And http response body is typed as array using path $.content with length 3
    And http response body path $.content.[0].name should be Pet-01

  Scenario: Filter pets by status with page size
    And I set http query parameter status to available
    And I set http query parameter size to 1
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 3
    And http response body path $.totalPages should be 3
    And http response body is typed as array using path $.content with length 1

  Scenario: Filter by status with no matches returns empty
    And I set http query parameter status to sold
    And I set http query parameter size to 2
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 1
    And http response body is typed as array using path $.content with length 1

  Scenario: Clean up pagination test data
    When I DELETE /pets
    Then http response code should be 200
    When I GET /pets
    Then http response code should be 200
    And http response body path $.totalElements should be 0
    And http response body is typed as array using path $.content with length 0
