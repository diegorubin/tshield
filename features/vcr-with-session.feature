Feature: Save request on first call and returns saved on second grouped by session

  Scenario: Save response body
    Given a valid api "/users"
    And in session "vcr-session"
    When this api is accessed throught tshield
    Then response should be saved in "users/get/0.content" in session "vcr-session"

  Scenario: Consider call count parameters within a session
    Given a valid api "/users"
    And in session "vcr-session"
    When this api is accessed throught tshield with param "t" and value "0"
    And this api is accessed throught tshield with param "t" and value "1"
    Then response should be saved in "users?t=0/get/0.content" in session "vcr-session"
    And response should be saved in "users?t=1/get/0.content" in session "vcr-session"

  Scenario: Recover response from main-session
    Given a valid api "/fake"
    And saved vcr session called "main-session"
    And saved vcr session called "second-session"
    When start session "main-session"
    And append session "second-session"
    And this api is accessed throught tshield with param "t" and value "saved-in-main-session"
    Then should get response saved into session "main-session"

  Scenario: Recover response from second-session
    Given a valid api "/fake"
    And saved vcr session called "main-session"
    And saved vcr session called "second-session"
    When start session "main-session"
    And append session "second-session"
    And this api is accessed throught tshield with param "t" and value "saved-in-second-session"
    Then should get response saved into session "second-session"

  Scenario: Not use number of call in secundary sessions
    Given a valid api "/fake"
    And saved vcr session called "main-session"
    And saved vcr session called "second-session"
    When start session "main-session"
    And append session "second-session"
    And this api is accessed throught tshield with param "t" and value "saved-in-main-session"
    And this api is accessed throught tshield with param "t" and value "saved-in-second-session"
    Then should get response saved into session "second-session"
