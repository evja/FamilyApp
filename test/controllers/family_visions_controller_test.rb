require "test_helper"

class FamilyVisionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get family_visions_show_url
    assert_response :success
  end

  test "should get edit" do
    get family_visions_edit_url
    assert_response :success
  end

  test "should get update" do
    get family_visions_update_url
    assert_response :success
  end
end
