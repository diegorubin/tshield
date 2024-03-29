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

  Scenario: In conflicts between vcr config and matching config matching will be used
    Given a file to describe "/conflicts/path" path only for method "GET"
    When this path "/conflicts/path" is accessed throught tshield via "get"
    Then response should be equal "matching"

  Scenario: Return response json path
    Given a file to describe "/matching/example.json" path
    When this path "/matching/example.json" is accessed throught tshield
    Then response should be equal "{\"attribute\":\"value\"}"
    And response should have header "content-type" with value "application/json"

  Scenario: Return response from file
    Given a file to describe "/matching/file.txt" path
    When this path "/matching/file.txt" is accessed throught tshield
    Then response should be equal "{\n  \"message\": \"content of file\"\n}\n"

