# Sample app for testing Auth0 with Minitest Rails

Sample Rails app for a [blog post](https://minitestrails.com/blog/testing-auth0-login-rails-minitest) on testing Auth0 login with Minitest. Authentication follows the [Auth0 Rails quickstart](https://auth0.com/docs/quickstart/webapp/rails).

## Prerequisites

- Ruby 4.0.2 (see `.ruby-version`)
- Rails 8.1.3
- An [Auth0](https://auth0.com/) account

## Auth0 application setup

1. Create a **Regular Web Application** in the [Auth0 Dashboard](https://manage.auth0.com/#/applications).
2. Note your **Domain**, **Client ID**, and **Client Secret** from Application Settings.
3. Under **Application URIs**, configure:
   - **Allowed Callback URLs**: `http://localhost:3000/auth/auth0/callback`
   - **Allowed Logout URLs**: `http://localhost:3000`

## Local setup

```bash
git clone git@github.com:minitestrails/auth0-minitest-rails.git
cd auth0-minitest-rails
bin/setup --skip-server
```

`bin/setup` copies `config/auth0.yml.example` to `config/auth0.yml` if it does not exist.

Edit `config/auth0.yml` with your Auth0 credentials:

```yaml
development:
  auth0_domain: your-tenant.auth0.com
  auth0_client_id: your_client_id
  auth0_client_secret: your_client_secret
```

Start the server:

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000), click **Login**, and complete Auth0 sign-in. You are redirected to `/dashboard` with your profile from the ID token.

## Routes

| Path | Description |
|------|-------------|
| `/` | Home page with login button |
| `/auth/auth0` | Starts Auth0 login (POST via login button) |
| `/auth/auth0/callback` | Auth0 callback after login |
| `/auth/logout` | Logs out locally and from Auth0 |
| `/dashboard` | Protected page showing user profile |

## How it works

- `omniauth-auth0` handles the OAuth flow via middleware in `config/initializers/auth0.rb`.
- `Auth0Controller#callback` finds or creates a local `User` from the Auth0 response, then stores `session[:user_id]` and `session[:userinfo]`.
- `Secured` redirects unauthenticated users away from protected controllers.
- `Auth0Controller#logout` clears the session and redirects to Auth0's `/v2/logout` endpoint.

## Tests

The test suite exercises Auth0 login **without calling Auth0**. OmniAuth test mode posts a fake auth hash to your callback route so CI stays fast and deterministic.

See the [blog post](https://minitestrails.com/blog/testing-auth0-login-rails-minitest) for the full walkthrough. This repo is the companion sample app.

### Setup

`config/environments/test.rb` enables OmniAuth test mode:

```ruby
OmniAuth.config.test_mode = true
```

`test/test_helper.rb` defines a default mock Auth0 response (reused across tests):

```ruby
OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
  provider: "auth0",
  uid: "auth0|test-user-1",
  info: { email: "alice@example.com", name: "Alice Example" },
  extra: {
    raw_info: {
      "sub" => "auth0|test-user-1",
      "email" => "alice@example.com",
      "name" => "Alice Example"
    }
  }
)
```

`test/support/auth0_test_helper.rb` provides `sign_in_as` so other tests can log in without duplicating the callback POST and redirect flow.

### What is covered

| File | What it proves |
|------|----------------|
| `test/integration/auth0_login_integration_test.rb` | Existing fixture user logs in; first-time login creates a `User`; failed auth lands on the failure page |
| `test/integration/dashboard_integration_test.rb` | Signed-in users reach `/dashboard`; guests are redirected to `/` |
| `test/system/authentication_test.rb` | Optional smoke test: Login button works in a real browser with OmniAuth stubbed |

`test/fixtures/users.yml` defines `alice` with `auth0_uid: auth0|test-user-1` to match the default OmniAuth mock. Integration tests assert on `session[:user_id]`, `User` records, and redirect behavior.

### Run tests

```bash
# Full suite
bin/rails test

# Integration tests only
bin/rails test test/integration/

# Optional system smoke test (requires Chrome)
bin/rails test:system test/system/authentication_test.rb
```

No Auth0 credentials are required in test. Keep real domain, client ID, and client secret out of the test path — test mode short-circuits the OAuth request phase.
