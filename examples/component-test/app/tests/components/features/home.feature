@home
Feature: Show search result

  Scenario: search with success
    Given a "valid" session
    When visit home page
    And do search with "hulk"
    Then show result
      | name | first_comic         | gif_url                                                                   |
      | Hulk | 5 Ronin (Hardcover) | https://media.tenor.com/images/19d4d328b2c52637286686223d1d6464/tenor.gif |

  Scenario: search with no result
    Given a "empty" session
    When visit home page
    And do search with "ironman"
    Then show result
      | name                | first_comic           | gif_url                                                                   |
      | Character not found | First Comic not found | https://media.tenor.com/images/33d80c2f47424356a5b214ce41527c38/tenor.gif |

  Scenario: search with error on marvel API
    Given a "error on marvel" session
    When visit home page
    And do search with "some"
    Then show error
      | title           | message                             |
      | Error on search | Request failed with status code 500 |

  Scenario: search with error on tenor API
    Given a "error on tenor" session
    When visit home page
    And do search with "some"
    Then show error
      | title           | message                             |
      | Error on search | Request failed with status code 500 |
