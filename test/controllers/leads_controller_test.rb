require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should create lead" do
    assert_difference("Lead.count") do
      post leads_url, params: { lead: { email: "newlead@example.com" } }
    end
    assert_redirected_to root_url
  end
end
