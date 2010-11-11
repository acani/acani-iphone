Feature: user edits profile

  As a user
  I want to edit my profile
  So that I can update my information

  Background:
    Given "Lovers.xcodeproj" is loaded in the iphone simulator

  Scenario: edit profile
    When I tap "Profile"
    Then I should see "Edit Profile"
