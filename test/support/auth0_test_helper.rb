module Auth0TestHelper
  def default_auth0_user
    OmniAuth::AuthHash.new(
      provider: "auth0",
      uid: "auth0|test-user-1",
      info: {
        email: "alice@example.com",
        name: "Alice Example"
      },
      extra: {
        raw_info: {
          "sub" => "auth0|test-user-1",
          "email" => "alice@example.com",
          "name" => "Alice Example"
        }
      }
    )
  end

  def load_omniauth_mock(auth0_uid:, email: nil, name: nil)
    email ||= default_auth0_user.info["email"]
    name ||= default_auth0_user.info["name"]

    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
      "provider" => "auth0",
      "uid" => auth0_uid,
      "info" => {
        "email" => email,
        "name" => name
      },
      :extra => {
        raw_info: {
          "sub" => auth0_uid,
          "email" => email,
          "name" => name
        }
      }
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[
      :auth0
    ]
  end

  def sign_in_as(user: nil, email: nil)
    if user.nil? && email.nil?
      raise ArgumentError, "Pass user: or email:"
    end

    if user
      load_omniauth_mock(
        auth0_uid: user.auth0_uid,
        email: user.email,
        name: user.name
      )
    else
      load_omniauth_mock(
        auth0_uid: "auth0|#{email.parameterize}",
        email: email,
        name: email.split("@").first.titleize
      )
    end

    get "/auth/auth0/callback"
    follow_redirect!
  end
end
