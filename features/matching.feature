Feature: Recover response with pattern matching

  Scenario: Return response matching only path
    Given a file to describe "/matching/example" path
    When this path "/matching/example" is accessed throught tshield
    Then response should be equal "matching-example-response"

  Scenario: Return response matching path and method
    Given a file to describe "/matching/example" path only for method "POST"
    When this path "/matching/example" is accessed throught tshield via "post"
    Then response should be equal "matching-example-response-with-post"

  Scenario: Return response matching path and method and headers
    Given a file to describe "/matching/example" path only for method "POST"
    And header "user" with value "123"
    When this path "/matching/example" is accessed throught tshield via "post"
    Then response should be equal "matching-example-response-with-headers"

  Scenario: Return response matching path and method and query params
    Given a file to describe "/matching/example" path only for method "GET"
    And query "user" with value "123"
    When this path "/matching/example" is accessed throught tshield via "get"
    Then response should be equal "matching-example-response-with-query"
