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
  # module_unlocked? tests - NEW TIER ORDER
  # Stabilize (Plug the holes)  → Members + Issues
  # Orient (Organize the ship)  → Rhythms + Relationships
  # Operate (Set sail)          → Vision + Responsibilities + Rituals
  # ============================================================================

  test "members module is always unlocked" do
    assert module_unlocked?(:members)
  end

  test "issues module unlocks with 1+ members beyond admin" do
    # Family one has multiple members in fixtures
    assert @family.members.count > 1
    assert module_unlocked?(:issues)
  end

  test "issues module locked without members beyond admin" do
    @family = Family.new(name: "Empty Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    refute module_unlocked?(:issues)
    @family.destroy
  end

  test "relationships module unlocks with 1+ member beyond admin" do
    # Family one has multiple members in fixtures
    assert @family.members.count > 1
    assert module_unlocked?(:relationships)
  end

  test "relationships module locked without members beyond admin" do
    @family = Family.new(name: "Solo Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    refute module_unlocked?(:relationships)
    @family.destroy
  end

  test "rhythms module unlocks when issues exist and issues module is unlocked" do
    # Ensure issues module is unlocked (needs 2+ members)
    assert @family.members.count > 1
    # Ensure issues exist (fixture already has one)
    assert @family.issues.count >= 1
    assert module_unlocked?(:rhythms)
  end

  test "rhythms module locked without issues" do
    @family = Family.new(name: "No Issues Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    refute module_unlocked?(:rhythms)
    @family.destroy
  end

  test "vision module unlocks when a rhythm is completed" do
    # Create a rhythm with a completed completion
    rhythm = @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    rhythm.completions.create!(status: "completed")
    assert module_unlocked?(:vision)
  end

  test "vision module locked without completed rhythm" do
    @family = Family.new(name: "No Rhythm Complete Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    # Create a rhythm but don't complete it
    @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    refute module_unlocked?(:vision)
    @family.destroy
  end

  test "responsibilities module unlocks when vision is complete" do
    # Create completed rhythm first to unlock vision module
    rhythm = @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    rhythm.completions.create!(status: "completed")
    # Complete the vision
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    assert module_unlocked?(:responsibilities)
  end

  test "rituals module unlocks when vision is complete" do
    # Create completed rhythm first to unlock vision module
    rhythm = @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    rhythm.completions.create!(status: "completed")
    # Complete the vision
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family believes in love and growth together.")
    assert module_unlocked?(:rituals)
  end

  test "responsibilities module locked when vision incomplete" do
    @family = Family.new(name: "No Vision Complete Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    refute module_unlocked?(:responsibilities)
    @family.destroy
  end

  test "admin bypasses all unlock requirements" do
    @show_admin_features_value = true
    @family = Family.new(name: "Empty Admin Family")
    @family.save!
    assert module_unlocked?(:members)
    assert module_unlocked?(:issues)
    assert module_unlocked?(:relationships)
    assert module_unlocked?(:rhythms)
    assert module_unlocked?(:vision)
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
  # next_unlockable_module tests - NEW ORDER
  # Order: members, issues, relationships, rhythms, vision, responsibilities, rituals
  # ============================================================================

  test "next_unlockable_module returns issues for new family with no members beyond admin" do
    @family = Family.new(name: "Brand New Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    assert_equal :issues, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns rhythms after members added but no issues" do
    @family = Family.new(name: "Has Members")
    @family.save!
    @family.members.create!(name: "Parent", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    # Issues and Relationships unlocked, but no issues yet for rhythms
    assert_equal :rhythms, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns vision after issues created but no rhythm completed" do
    @family = Family.new(name: "Has Issues")
    @family.save!
    @family.members.create!(name: "Parent", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    @family.issues.create!(description: "Test issue", list_type: "family", status: "new")
    assert_equal :vision, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns responsibilities after vision module unlocked but not complete" do
    @family = Family.new(name: "Has Rhythm Complete")
    @family.save!
    @family.members.create!(name: "Parent", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    @family.issues.create!(description: "Test issue", list_type: "family", status: "new")
    rhythm = @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    rhythm.completions.create!(status: "completed")
    # Vision is unlocked but not complete, so responsibilities is next
    assert_equal :responsibilities, next_unlockable_module
    @family.destroy
  end

  test "next_unlockable_module returns nil when all unlocked" do
    # Complete vision for responsibilities/rituals unlock
    rhythm = @family.rhythms.create!(name: "Test Rhythm", frequency_type: "weekly", rhythm_category: "family_huddle")
    rhythm.completions.create!(status: "completed")
    vision = @family.vision || @family.create_vision!
    vision.update!(mission_statement: "Our family mission statement is complete.")
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
    # Issues is unlocked (family has 2+ members) but hidden by admin
    refute module_visible_to_user?(:issues)
  end

  # ============================================================================
  # module_unlock_message tests
  # ============================================================================

  test "module_unlock_message returns message for known modules" do
    assert_equal "Every family needs a shared direction.", module_unlock_message(:vision)
    assert_equal "Problems don't go away when ignored - they grow.", module_unlock_message(:issues)
    assert_equal "What you don't schedule, you drift from.", module_unlock_message(:rhythms)
    assert_equal "Connection requires intention.", module_unlock_message(:relationships)
  end

  # ============================================================================
  # module_unlock_condition tests
  # ============================================================================

  test "module_unlock_condition returns condition for known modules" do
    assert_equal "Complete a rhythm meeting to unlock Vision", module_unlock_condition(:vision)
    assert_equal "Add your family members to start capturing issues", module_unlock_condition(:issues)
    assert_equal "Create your first issue to unlock Rhythms", module_unlock_condition(:rhythms)
    assert_equal "Add your family members to track relationships", module_unlock_condition(:relationships)
  end

  # ============================================================================
  # module_unlock_progress tests
  # ============================================================================

  test "module_unlock_progress returns numeric progress for issues" do
    progress = module_unlock_progress(:issues)
    assert_equal :numeric, progress[:type]
    assert_equal 1, progress[:required]
    assert_equal "members (beyond you)", progress[:label]
  end

  test "module_unlock_progress returns numeric progress for relationships" do
    progress = module_unlock_progress(:relationships)
    assert_equal :numeric, progress[:type]
    assert_equal 1, progress[:required]
    assert_equal "members (beyond you)", progress[:label]
  end

  test "module_unlock_progress returns boolean progress for vision" do
    progress = module_unlock_progress(:vision)
    assert_equal :boolean, progress[:type]
    assert_equal "rhythm completed", progress[:label]
  end

  test "module_unlock_progress returns blocked for rhythms when issues locked" do
    @family = Family.new(name: "No Members")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    progress = module_unlock_progress(:rhythms)
    assert_equal :blocked, progress[:type]
    assert_equal "Unlock Issues first", progress[:prerequisite]
    @family.destroy
  end

  test "module_unlock_progress returns numeric for rhythms when issues unlocked" do
    @family = Family.new(name: "Progress Test Family")
    @family.save!
    @family.members.create!(name: "Admin", role: "admin_parent")
    @family.members.create!(name: "Child", role: "child")
    # Family has 2+ members, so issues unlocked but count is 0
    progress = module_unlock_progress(:rhythms)
    assert_equal :numeric, progress[:type]
    assert_equal 1, progress[:required]
    assert_equal "issues", progress[:label]
    @family.destroy
  end
end
