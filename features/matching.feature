Feature: Recover response with pattern matching

  Scenario: Return response matching only path
    Given a file to describe "/matching/example" path
    When this path "/matching/example" is accessed throught tshield
    Then response should be equal "matching-example-response"
