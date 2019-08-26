Feature: Group stubs into sessions

  Scenario: Return response matching declared in session
    Given a file to describe "/matching/example" path
    And in session "example-session"
    When this path "/matching/example" is accessed throught tshield
    Then response should be equal "matching-example-response-in-session"

  Scenario: Return response matching into global if not defined in session
    Given a file to describe "/matching/example" path only for method "POST"
    And in session "example-session"
    When this path "/matching/example" is accessed throught tshield via "post"
    Then response should be equal "matching-example-response-with-post"

