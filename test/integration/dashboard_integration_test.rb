require "test_helper"

class DashboardIntegrationTest < ActionDispatch::IntegrationTest
  test "signed-in user can access the dashboard" do
    sign_in_as(user: users(:alice))

    get dashboard_path
    assert_response :success
  end

  test "guest cannot access the dashboard" do
    get dashboard_path
    assert_redirected_to root_path
  end
end
