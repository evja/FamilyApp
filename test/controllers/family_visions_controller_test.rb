require "test_helper"

class FamilyVisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    sign_in @user
  end

  test "should show vision" do
    get family_vision_url(@family)
    assert_response :success
  end

  test "should get edit" do
    get edit_family_vision_url(@family)
    assert_response :success
  end

  test "should update vision" do
    patch family_vision_url(@family), params: { family_vision: { mission_statement: "Updated mission" } }
    assert_redirected_to family_vision_url(@family)
  end
end
