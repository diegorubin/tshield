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

  Scenario: Return different answer for same stub
    Given a file to describe "/matching/twice" path
    And in session "multiples-responses"
    When this path "/matching/twice" is accessed throught tshield twice
    Then first response should be equal "{\"attribute\":\"value1\"}"
    Then second response should be equal "{\"attribute\":\"value2\"}"
