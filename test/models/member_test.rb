require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "valid roles" do
    member = members(:one)
    Member::ROLES.each do |role|
      member.role = role
      assert member.valid?, "#{role} should be valid"
    end
  end

  test "invalid role" do
    member = members(:one)
    member.role = "invalid_role"
    assert_not member.valid?
    assert_includes member.errors[:role], "is not included in the list"
  end

  test "can_have_account? returns true for admin_parent, parent, teen" do
    assert members(:admin_parent_one).can_have_account?
    assert members(:parent_one).can_have_account?
    assert members(:teen_one).can_have_account?
  end

  test "can_have_account? returns false for child" do
    assert_not members(:child_one).can_have_account?
  end

  test "invited? returns true when invited_at is present" do
    member = members(:parent_one)
    assert member.invited?
  end

  test "invited? returns false when invited_at is nil" do
    member = members(:teen_one)
    assert_not member.invited?
  end

  test "joined? returns true when user_id is present" do
    member = members(:admin_parent_one)
    assert member.joined?
  end

  test "joined? returns true when joined_at is present" do
    member = Member.new(joined_at: Time.current)
    assert member.joined?
  end

  test "joined? returns false when neither user_id nor joined_at" do
    member = members(:teen_one)
    assert_not member.joined?
  end

  test "display_status returns correct status" do
    assert_equal 'admin_parent', members(:admin_parent_one).display_status
    assert_equal 'pending', members(:parent_one).display_status
    assert_equal 'not_invited', members(:teen_one).display_status
    assert_equal 'child', members(:child_one).display_status
  end

  test "admin_parent? returns true for admin_parent role" do
    assert members(:admin_parent_one).admin_parent?
    assert_not members(:parent_one).admin_parent?
  end

  test "parent_or_above? returns true for admin_parent and parent" do
    assert members(:admin_parent_one).parent_or_above?
    assert members(:parent_one).parent_or_above?
    assert_not members(:teen_one).parent_or_above?
    assert_not members(:child_one).parent_or_above?
  end

  test "sync_is_parent_with_role sets is_parent based on role" do
    member = Member.new(family: families(:one), name: "Test", role: "parent")
    member.save
    assert member.is_parent

    member.role = "teen"
    member.save
    assert_not member.is_parent

    member.role = "admin_parent"
    member.save
    assert member.is_parent
  end

  test "display_role returns human-readable role" do
    assert_equal 'Admin Parent', members(:admin_parent_one).display_role
    assert_equal 'Parent', members(:parent_one).display_role
    assert_equal 'Teen', members(:teen_one).display_role
    assert_equal 'Child', members(:child_one).display_role
  end

  test "email validation format" do
    member = members(:parent_one)
    member.email = "invalid-email"
    assert_not member.valid?
    assert_includes member.errors[:email], "is invalid"
  end

  test "email can be blank for child" do
    member = members(:child_one)
    member.email = nil
    assert member.valid?
  end

  test "scopes return correct members" do
    family = families(:one)

    assert_includes family.members.admin_parents, members(:admin_parent_one)
    assert_includes family.members.invitable, members(:teen_one)
    assert_not_includes family.members.invitable, members(:admin_parent_one)
    assert_includes family.members.with_accounts, members(:admin_parent_one)
  end

  # Birthdate and age calculation tests
  test "calculates age from birthdate" do
    member = Member.new(birthdate: 10.years.ago.to_date)
    assert_equal 10, member.calculated_age
  end

  test "calculates age correctly when birthday has not occurred this year" do
    # Set birthdate to 10 years ago plus 6 months in the future
    future_birthday = 10.years.ago.to_date + 6.months
    member = Member.new(birthdate: future_birthday)
    assert_equal 9, member.calculated_age
  end

  test "auto-assigns child role when age under 13" do
    member = Member.new(family: families(:one), name: "Young", birthdate: 8.years.ago.to_date)
    member.valid?
    assert_equal "child", member.role
    assert_equal 8, member.age
  end

  test "auto-assigns teen role when age 13 or over" do
    member = Member.new(family: families(:one), name: "Teen", birthdate: 15.years.ago.to_date)
    member.valid?
    assert_equal "teen", member.role
    assert_equal 15, member.age
  end

  test "auto-assigns teen role at exactly 13" do
    member = Member.new(family: families(:one), name: "Just Teen", birthdate: 13.years.ago.to_date)
    member.valid?
    assert_equal "teen", member.role
    assert_equal 13, member.age
  end

  test "does not change parent role based on birthdate" do
    member = Member.new(family: families(:one), name: "Parent", role: "parent", birthdate: 35.years.ago.to_date)
    member.valid?
    assert_equal "parent", member.role
    assert_equal 35, member.age
  end

  test "does not change admin_parent role based on birthdate" do
    # First create a family without an admin_parent
    family = Family.create!(name: "New Family")
    member = Member.new(family: family, name: "Admin", role: "admin_parent", birthdate: 40.years.ago.to_date)
    member.valid?
    assert_equal "admin_parent", member.role
    assert_equal 40, member.age
  end

  test "allows manual age and role when birthdate is nil" do
    member = Member.new(family: families(:one), name: "Manual", age: 10, role: "teen")
    member.valid?
    assert_equal "teen", member.role
    assert_equal 10, member.age
  end

  test "role_for_age returns child for age under 13" do
    member = Member.new
    assert_equal "child", member.role_for_age(12)
    assert_equal "child", member.role_for_age(0)
    assert_equal "child", member.role_for_age(5)
  end

  test "role_for_age returns teen for age 13 and over" do
    member = Member.new
    assert_equal "teen", member.role_for_age(13)
    assert_equal "teen", member.role_for_age(17)
    assert_equal "teen", member.role_for_age(99)
  end

  test "role_for_age returns nil for nil age" do
    member = Member.new
    assert_nil member.role_for_age(nil)
  end

  test "calculated_age returns nil when birthdate is nil" do
    member = Member.new
    assert_nil member.calculated_age
  end

  test "updating birthdate recalculates age and role" do
    member = members(:child_one)
    original_age = member.age

    # Update birthdate to make member a teen
    member.birthdate = 15.years.ago.to_date
    member.valid?

    assert_equal 15, member.age
    assert_equal "teen", member.role
  end
end
