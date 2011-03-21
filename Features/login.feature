Feature: login

  As a user
  I want to login
  So that I can use the app

  Background:
    Given "acani.xcodeproj" is loaded in the iphone simulator

  # Scenario: launch app
  #   When I tap "New post"
  #     And I type "My post" in "Title"
  #     And I type "Interesting things" in "Body"
  #     And I tap "Post"
  #   Then I should see "Published"

  Scenario:
    Then I should see "acani"

  # Scenario: create account
  #   Given I am not yet signed up for acani
  #   When I start acani
  #   Then, I should see
  #   Then I should see a JSON array of users
