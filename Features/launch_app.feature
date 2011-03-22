Feature: launch app

  As a user
  I want to launch the app
  So that I can use it

  Scenario: not logged in
    Given I'm not logged in
    Then I should see "Connect with Facebook"

  Scenario: logged in
    Given I'm logged in
    Then I should see "Logout"
