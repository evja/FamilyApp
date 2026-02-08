require "test_helper"

class FamiliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    sign_in @user
  end

  test "should get new when user has no family" do
    @user.update!(family: nil)
    get new_family_url
    assert_response :success
  end

  test "should allow new family creation when user already has a family (multi-family support)" do
    get new_family_url
    assert_response :success
  end

  test "should create family" do
    @user.update!(family: nil)
    assert_difference("Family.count") do
      post families_url, params: { family: { name: "New Family" } }
    end
    assert_redirected_to family_url(Family.last)
  end

  test "should show family" do
    get family_url(@family)
    assert_response :success
  end
end
