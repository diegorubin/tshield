Feature: Accept regex in stubs definition

  Scenario: Accept regex in url path
    Given a file to describe "/matching/\d+" path
    When this path "/matching/1234" is accessed throught tshield
    Then response should be equal "matching-with-regex"
