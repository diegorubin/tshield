Feature: Save request on first call and returns saved on second

  Scenario: Save response body
    Given a valid api "/users"
    When this api is accessed throught tshield
    Then response should be saved in "users/get/0.content"

  Scenario: Not Save Specific Query Param
    Given a valid api "/resources?a=1&b=2&c=3"
    When this api is accessed throught tshield
    Then response should be saved in directory "resources/get"

  Scenario: Not Save Specific Query Param In Any Order
    Given a valid api "/resources?b=2&c=3&a=1"
    When this api is accessed throught tshield
    Then response should be saved in directory "resources/get"
