require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    @member = members(:one)
    @admin_parent = members(:admin_parent_one)
    @parent = members(:parent_one)
    @teen = members(:teen_one)
    @child = members(:child_one)
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

  test "should create member with role" do
    assert_difference("Member.count") do
      post family_members_url(@family), params: { member: { name: "New Member", age: 10, role: "child" } }
    end
    assert_redirected_to family_members_path(@family)
    assert_equal "child", Member.last.role
  end

  test "should create parent member with email" do
    assert_difference("Member.count") do
      post family_members_url(@family), params: { member: { name: "New Parent", age: 35, role: "parent", email: "newparent@example.com" } }
    end
    assert_equal "parent", Member.last.role
    assert_equal "newparent@example.com", Member.last.email
    assert Member.last.is_parent
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

  test "should update member role" do
    patch family_member_url(@family, @child), params: { member: { role: "teen", email: "teen@test.com" } }
    assert_redirected_to family_member_url(@family, @child)
    @child.reload
    assert_equal "teen", @child.role
  end

  test "should destroy non-admin_parent member" do
    assert_difference("Member.count", -1) do
      delete family_member_url(@family, @child)
    end
    assert_redirected_to family_members_path(@family)
  end

  test "should not destroy admin_parent member" do
    assert_no_difference("Member.count") do
      delete family_member_url(@family, @admin_parent)
    end
    assert_redirected_to family_members_path(@family)
    assert_match /Cannot delete/, flash[:alert]
  end

  test "should invite member with email" do
    @teen.update(email: "teen@example.com")

    assert_difference("FamilyInvitation.count") do
      post invite_family_member_url(@family, @teen)
    end

    @teen.reload
    assert @teen.invited?
    assert_redirected_to family_members_path(@family)
  end

  test "should not invite member without email" do
    @teen.update(email: nil)

    assert_no_difference("FamilyInvitation.count") do
      post invite_family_member_url(@family, @teen)
    end

    assert_redirected_to edit_family_member_path(@family, @teen)
    assert_match /add an email/, flash[:alert]
  end

  test "should not invite child member" do
    assert_no_difference("FamilyInvitation.count") do
      post invite_family_member_url(@family, @child)
    end

    assert_redirected_to family_members_path(@family)
    assert_match /cannot receive an invitation/, flash[:alert]
  end

  test "should resend invite for pending member" do
    @parent.update(invited_at: 7.days.ago)

    assert_difference("FamilyInvitation.count") do
      post resend_invite_family_member_url(@family, @parent)
    end

    assert_redirected_to family_members_path(@family)
  end

  test "index groups members by role" do
    get family_members_url(@family)

    assert_response :success
    # Verify the page renders with role-based sections
    assert_select "h3", /Parents/
    assert_select "h3", /Teens/
    assert_select "h3", /Children/
  end
end
