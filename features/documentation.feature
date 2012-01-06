Feature: Documentation built to HTML
  In order to be useful
  The documentation should be complete and accurate

  Scenario: Following an external link in the documentation
    Given each external link in the documentation
    When the link is followed
    Then it should resolve to a valid resource
