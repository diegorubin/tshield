Feature: Save request on first call and returns saved on second grouped by session

  Scenario: Save response body
    Given a valid api "/users"
    And in session "vcr-session"
    When this api is accessed throught tshield
    Then response should be saved in "users/get/0.content" in session "vcr-session"

