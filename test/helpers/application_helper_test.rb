require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  setup do
    @family = families(:one)
    # Stub controller methods that helpers depend on
    def show_admin_features?
      @show_admin_features_value || false
    end

    def session
      @mock_session ||= {}
    end
  end

  # ============================================================================
  # module_unlocked? tests
  # ============================================================================

  test "members module is always unlocked" do
    assert module_unlocked?(:members)
  end

  test "vision module unlocks with 1+ members" do
    # Family one has multiple members in fixtures
    assert @family.members.count >= 1
    assert module_unlocked?(:vision)
  end

  test "vision module locked without members" do
    @family = Family.new(name: "Empty Family")
    @family.save!
    refute module_unlocked?(:vision)
    @family.destroy
  end

  test "issues module unlocks when vision is complete" do
    # Create a complete vision
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    assert module_unlocked?(:issues)
  end

  test "issues module locked when vision is incomplete" do
    @family = Family.new(name: "No Vision Family")
    @family.save!
    @family.members.create!(name: "Test Member", role: "parent")
    refute module_unlocked?(:issues)
    @family.destroy
  end

  test "issues module locked when mission statement is too short" do
    @family = Family.new(name: "Short Vision Family")
    @family.save!
    @family.members.create!(name: "Test Member", role: "parent")
    @family.create_vision!(mission_statement: "Short")
    refute module_unlocked?(:issues)
    @family.destroy
  end

  test "rhythms module unlocks when issues exist and issues module is unlocked" do
    # Ensure vision is complete
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    # Ensure issues exist (fixture already has one)
    assert @family.issues.count >= 1
    assert module_unlocked?(:rhythms)
  end

  test "rhythms module locked without issues" do
    @family = Family.new(name: "No Issues Family")
    @family.save!
    @family.members.create!(name: "Test Member", role: "parent")
    @family.create_vision!(mission_statement: "Our family believes in love and growth together.")
    refute module_unlocked?(:rhythms)
    @family.destroy
  end

  test "relationships module unlocks with issues module" do
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    assert module_unlocked?(:relationships)
  end

  test "responsibilities module unlocks with rhythms module" do
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    assert module_unlocked?(:responsibilities)
  end

  test "rituals module unlocks with rhythms module" do
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    assert module_unlocked?(:rituals)
  end

  test "admin bypasses all unlock requirements" do
    @show_admin_features_value = true
    @family = Family.new(name: "Empty Admin Family")
    @family.save!
    assert module_unlocked?(:members)
    assert module_unlocked?(:vision)
    assert module_unlocked?(:issues)
    assert module_unlocked?(:rhythms)
    assert module_unlocked?(:relationships)
    assert module_unlocked?(:responsibilities)
    assert module_unlocked?(:rituals)
    @family.destroy
  end

  # ============================================================================
  # vision_complete? tests
  # ============================================================================

  test "vision_complete? returns false when no vision exists" do
    @family = Family.new(name: "No Vision")
    @family.save!
    refute vision_complete?
    @family.destroy
  end

  test "vision_complete? returns false when mission statement is nil" do
    @family = Family.new(name: "Nil Mission")
    @family.save!
    @family.create_vision!(mission_statement: nil)
    refute vision_complete?
    @family.destroy
  end

  test "vision_complete? returns false when mission statement is too short" do
    @family = Family.new(name: "Short Mission")
    @family.save!
    @family.create_vision!(mission_statement: "Too short")
    refute vision_complete?
    @family.destroy
  end

  test "vision_complete? returns true when mission statement is 10+ chars" do
    @family = Family.new(name: "Complete Mission")
    @family.save!
    @family.create_vision!(mission_statement: "This is a complete mission statement.")
    assert vision_complete?
    @family.destroy
  end

  # ============================================================================
  # next_unlockable_module tests
  # ============================================================================

  test "next_unlockable_module returns vision for new family with no members" do
    @family = Family.new(name: "Brand New Family")
    @family.save!
    assert_equal :vision, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns vision after one member added (need 2+)" do
    @family = Family.new(name: "Has One Member")
    @family.save!
    @family.members.create!(name: "Test", role: "parent")
    # Vision requires > 1 members, so vision is still next to unlock
    assert_equal :vision, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns issues after 2+ members added but no vision" do
    @family = Family.new(name: "Has Members")
    @family.save!
    @family.members.create!(name: "Parent", role: "parent")
    @family.members.create!(name: "Child", role: "child")
    assert_equal :issues, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns rhythms after vision complete but no issues" do
    @family = Family.new(name: "Has Vision")
    @family.save!
    @family.members.create!(name: "Parent", role: "parent")
    @family.members.create!(name: "Child", role: "child")
    @family.create_vision!(mission_statement: "Our family mission statement is complete.")
    assert_equal :rhythms, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns nil when all unlocked" do
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family mission statement is complete.")
    @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    assert_nil next_unlockable_module
  end

  test "next_unlockable_module returns nil for admin" do
    @show_admin_features_value = true
    @family = Family.new(name: "Admin Family")
    @family.save!
    assert_nil next_unlockable_module
    @family.destroy
  end

  # ============================================================================
  # module_visible_to_user? tests
  # ============================================================================

  test "module_visible_to_user? returns true when unlocked and not hidden" do
    assert module_visible_to_user?(:members)
  end

  test "module_visible_to_user? returns false when hidden by admin" do
    @mock_session = { hidden_modules: ["Members"] }
    refute module_visible_to_user?(:members)
  end

  test "module_visible_to_user? returns false when locked" do
    @family = Family.new(name: "Empty")
    @family.save!
    refute module_visible_to_user?(:vision)
    @family.destroy
  end

  test "module_visible_to_user? respects both unlock and admin hidden" do
    @mock_session = { hidden_modules: ["Issues"] }
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family mission statement is complete.")
    # Issues is unlocked but hidden by admin
    refute module_visible_to_user?(:issues)
  end

  # ============================================================================
  # module_unlock_message tests
  # ============================================================================

  test "module_unlock_message returns message for known modules" do
    assert_equal "Every family needs a shared direction.", module_unlock_message(:vision)
    assert_equal "Problems don't go away when ignored - they grow.", module_unlock_message(:issues)
    assert_equal "What you don't schedule, you drift from.", module_unlock_message(:rhythms)
  end

  # ============================================================================
  # module_unlock_condition tests
  # ============================================================================

  test "module_unlock_condition returns condition for known modules" do
    assert_equal "Add your family members to unlock", module_unlock_condition(:vision)
    assert_equal "Complete your family vision to start capturing issues", module_unlock_condition(:issues)
    assert_equal "Create your first issue to unlock Rhythms", module_unlock_condition(:rhythms)
  end

  # ============================================================================
  # module_unlock_progress tests
  # ============================================================================

  test "module_unlock_progress returns numeric progress for vision" do
    progress = module_unlock_progress(:vision)
    assert_equal :numeric, progress[:type]
    assert_equal 1, progress[:required]
    assert_equal "members", progress[:label]
  end

  test "module_unlock_progress returns boolean progress for issues" do
    progress = module_unlock_progress(:issues)
    assert_equal :boolean, progress[:type]
    assert_equal "vision complete", progress[:label]
  end

  test "module_unlock_progress returns blocked for rhythms when issues locked" do
    @family = Family.new(name: "No Vision")
    @family.save!
    progress = module_unlock_progress(:rhythms)
    assert_equal :blocked, progress[:type]
    assert_equal "Unlock Issues first", progress[:prerequisite]
    @family.destroy
  end

  test "module_unlock_progress returns numeric for rhythms when issues unlocked" do
    @family = Family.new(name: "Progress Test Family")
    @family.save!
    @family.members.create!(name: "Test Member", role: "parent")
    @family.create_vision!(mission_statement: "Our family mission statement is complete.")
    # Family has no issues, so issues unlocked but count is 0
    progress = module_unlock_progress(:rhythms)
    assert_equal :numeric, progress[:type]
    assert_equal 1, progress[:required]
    assert_equal "issues", progress[:label]
    @family.destroy
  end
end
