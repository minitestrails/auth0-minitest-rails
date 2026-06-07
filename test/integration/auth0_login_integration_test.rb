require "test_helper"

class Auth0LoginIntegrationTest < ActionDispatch::IntegrationTest
  test "logs in the user" do
    user = users(:alice)
    load_omniauth_mock(
      auth0_uid: user.auth0_uid,
      email: user.email,
      name: user.name
    )

    assert_no_difference "User.count" do
      get "/auth/auth0/callback"
    end

    follow_redirect!
    assert_response :success
    assert_equal user.id, session[:user_id]
    assert_equal "auth0|test-user-1", session[:userinfo]["sub"]
  end

  test "creates a user and logs them in" do
    load_omniauth_mock(
      auth0_uid: "auth0|test-user-2",
      email: "bob@example.com",
      name: "Bob Example"
    )

    assert_difference "User.count", 1 do
      get "/auth/auth0/callback"
    end

    user = User.find_by(email: "bob@example.com")
    assert_equal "auth0|test-user-2", user.auth0_uid

    follow_redirect!
    assert_response :success
    assert_equal user.id, session[:user_id]
  end

  test "failure redirects with a message" do
    OmniAuth.config.mock_auth[:auth0] = :invalid_credentials

    post "/auth/auth0"
    follow_redirect! # OmniAuth failure redirect (redirected from Auth0)
    follow_redirect! # /auth/failure

    assert_response :success
    assert_match(/authentication failed/i, response.body)
  end
end
