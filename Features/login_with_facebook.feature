Feature: login

  As a user
  I want to login
  So that I can use the app

  Background:
    Given I'm not logged in

  Scenario: login to Facebook
    Given I'm not logged into Facebook
    When I login to Facebook
      When I tap "Login with Facebook"
      And I enter "test@email.com" for "Email or Phone:"
      And I enter "test_password" for "Password:"
      And I tap "Login"
    Then my acani account should be created
    And I should be logged in
    And I should see "Logout"

  Scenario: login with Facebook
    Given I'm logged into Facebook
    When I login to Facebook
      When I tap "Login with Facebook"
      And I enter "test@email.com" for "Email or Phone:"
      And I enter "test_password" for "Password:"
      And I tap "Login"
    Then my acani account should be created
    And I should be logged in
    And I should see "Logout"

    Then I should see "Published"

  Scenario:
    Then I should see "acani"

  # Scenario: create account
  #   Given I am not yet signed up for acani
  #   When I start acani
  #   Then, I should see
  #   Then I should see a JSON array of users
