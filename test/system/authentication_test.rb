require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    load_omniauth_mock(auth0_uid: "auth0|test-user-1")
  end

  test "visitor signs in to the app" do
    visit root_path
    click_on "Login"

    assert_text "Signed in as alice@example.com"
  end
end
