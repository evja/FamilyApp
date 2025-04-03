require "test_helper"

class Admin::LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_leads_index_url
    assert_response :success
  end
end
