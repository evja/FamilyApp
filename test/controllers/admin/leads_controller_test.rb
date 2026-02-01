require "test_helper"

class Admin::LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    get admin_leads_url
    assert_response :success
  end

  test "should redirect non-admin" do
    sign_in users(:one)
    get admin_leads_url
    assert_redirected_to root_url
  end
end
