require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    @member = members(:one)
    sign_in @user
  end

  test "should get index" do
    get family_members_url(@family)
    assert_response :success
  end

  test "should get new" do
    get new_family_member_url(@family)
    assert_response :success
  end

  test "should create member" do
    assert_difference("Member.count") do
      post family_members_url(@family), params: { member: { name: "New Member", age: 10 } }
    end
  end

  test "should show member" do
    get family_member_url(@family, @member)
    assert_response :success
  end

  test "should get edit" do
    get edit_family_member_url(@family, @member)
    assert_response :success
  end

  test "should update member" do
    patch family_member_url(@family, @member), params: { member: { name: "Updated Name" } }
    assert_redirected_to family_member_url(@family, @member)
  end
end
