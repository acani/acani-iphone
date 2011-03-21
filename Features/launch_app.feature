Feature: launch app

  As a user
  I want to launch acani
  So that I can meet people nearby with similar interests

  Background:
    Given "acani.xcodeproj" is loaded in the iphone simulator

  # Scenario: launch app
  #   When I tap "New post"
  #     And I type "My post" in "Title"
  #     And I type "Interesting things" in "Body"
  #     And I tap "Post"
  #   Then I should see "Published"

  Scenario: launch app
    Then I should see "acani"

  # Scenario: create account
  #   Given I am not yet signed up for acani
  #   When I start acani
  #   Then, I should see
  #   Then I should see a JSON array of users
