Feature: Save request on first call and returns saved on second

  Scenario: Save response body
    Given a valid api "/users"
    When this api is accessed throught tshield
    Then response should be saved in "users/get/0.content"

  Scenario: Not Save Specific Query Param Because 'b' Should be Ignored
    Given a valid api "/resources?a=1&b=2&c=3"
    When this api is accessed throught tshield
    Then response should be saved in directory "resources?a=1&c=3"

  Scenario: Not Save Specific Query Param In Any Order Because 'b' Should be Ignored
    Given a valid api "/resources?b=2&c=3&a=1"
    When this api is accessed throught tshield
    Then response should be saved in directory "resources?c=3&a=1"

  Scenario: Recover Content of Specific Query Param Because 'b' Should be Ignored
    Given a valid content saved in "/resources?a=1&c=3" with content "{1: true, 2: false}"
    When this path "/resources?a=1&b=2&c=3" is accessed throught tshield
    Then response should be equal "{1: true, 2: false}"
