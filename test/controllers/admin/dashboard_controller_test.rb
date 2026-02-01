require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    get admin_dashboard_url
    assert_response :success
  end

  test "should redirect non-admin" do
    sign_in users(:one)
    get admin_dashboard_url
    assert_redirected_to root_url
  end
end
